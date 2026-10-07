import AppKit

@MainActor
final class SpoilerView: NSView {
    private static let frameInterval = 1.0 / 30.0

    var style = HiddenStyle.animated {
        didSet { updateAnimation() }
    }

    var color = NSColor.labelColor {
        didSet { needsDisplay = true }
    }

    private var field: SpoilerParticleField<SystemRandomNumberGenerator>?
    private var timer: Timer?
    private var isHovered = false
    private let startTime = Date()

    override var isFlipped: Bool { true }

    override var isHidden: Bool {
        didSet { updateAnimation() }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func setFrameSize(_ newSize: NSSize) {
        let sizeChanged = newSize != frame.size
        super.setFrameSize(newSize)
        if sizeChanged || field == nil {
            field = SpoilerParticleField(
                width: newSize.width,
                height: newSize.height,
                generator: SystemRandomNumberGenerator()
            )
            needsDisplay = true
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateAnimation()
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(
            NSTrackingArea(
                rect: .zero,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self
            )
        )
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
        updateAnimation()
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
        updateAnimation()
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let field else {
            return
        }
        let time = Date().timeIntervalSince(startTime)
        for particle in field.particles {
            let opacity = SpoilerParticleField<SystemRandomNumberGenerator>.opacity(of: particle, at: time)
            color.withAlphaComponent(opacity).setFill()
            let radius = particle.radius
            let dot = NSRect(x: particle.x - radius, y: particle.y - radius, width: radius * 2, height: radius * 2)
            NSBezierPath(ovalIn: dot).fill()
        }
    }

    private func updateAnimation() {
        let shouldAnimate = !isHidden && window != nil && style.animates(isHovered: isHovered)
        if shouldAnimate, timer == nil {
            let timer = Timer(timeInterval: Self.frameInterval, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.advance()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        } else if !shouldAnimate {
            timer?.invalidate()
            timer = nil
        }
    }

    private func advance() {
        field?.step(by: Self.frameInterval)
        needsDisplay = true
    }
}
