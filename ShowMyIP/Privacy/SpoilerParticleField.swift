import Foundation

struct SpoilerParticle: Equatable, Sendable {
    var x: Double
    var y: Double
    var velocityX: Double
    var velocityY: Double
    var radius: Double
    var phase: Double
    var twinkleSpeed: Double
}

struct SpoilerParticleField<Generator: RandomNumberGenerator> {
    private static var areaPerParticle: Double { 9 }

    let width: Double
    let height: Double
    private(set) var particles: [SpoilerParticle] = []
    private var generator: Generator

    init(width: Double, height: Double, generator: Generator) {
        self.width = max(0, width)
        self.height = max(0, height)
        self.generator = generator
        let count = Int((self.width * self.height / Self.areaPerParticle).rounded())
        for _ in 0..<count {
            particles.append(makeParticle())
        }
    }

    static func opacity(of particle: SpoilerParticle, at time: Double) -> Double {
        0.35 + 0.65 * (0.5 + 0.5 * sin(particle.phase + time * particle.twinkleSpeed))
    }

    mutating func step(by interval: Double) {
        for index in particles.indices {
            particles[index].x += particles[index].velocityX * interval
            particles[index].y += particles[index].velocityY * interval
            if !isInside(particles[index]) {
                particles[index] = makeParticle()
            }
        }
    }

    private func isInside(_ particle: SpoilerParticle) -> Bool {
        (0...width).contains(particle.x) && (0...height).contains(particle.y)
    }

    private mutating func makeParticle() -> SpoilerParticle {
        SpoilerParticle(
            x: .random(in: 0...width, using: &generator),
            y: .random(in: 0...height, using: &generator),
            velocityX: .random(in: -3...3, using: &generator),
            velocityY: .random(in: -2...2, using: &generator),
            radius: .random(in: 0.45...1.05, using: &generator),
            phase: .random(in: 0...(2 * .pi), using: &generator),
            twinkleSpeed: .random(in: 1.5...4.5, using: &generator)
        )
    }
}
