import Testing

@testable import ShowMyIP

struct SpoilerParticleFieldTests {
    private func makeField(width: Double = 110, height: Double = 18) -> SpoilerParticleField<SeededGenerator> {
        SpoilerParticleField(width: width, height: height, generator: SeededGenerator(seed: 42))
    }

    private func isInside(_ particle: SpoilerParticle, width: Double, height: Double) -> Bool {
        (0...width).contains(particle.x) && (0...height).contains(particle.y)
    }

    @Test func particleCountFollowsArea() {
        #expect(makeField().particles.count == 220)
    }

    @Test func emptyAreaHasNoParticles() {
        #expect(makeField(width: 0, height: 18).particles.isEmpty)
    }

    @Test func particlesStartInsideBounds() {
        #expect(makeField().particles.allSatisfy { isInside($0, width: 110, height: 18) })
    }

    @Test func particlesStayInsideBoundsOverTime() {
        var field = makeField()
        for _ in 0..<1_000 {
            field.step(by: 1.0 / 30.0)
        }
        #expect(field.particles.allSatisfy { isInside($0, width: 110, height: 18) })
    }

    @Test func stepMovesParticles() {
        var field = makeField()
        let before = field.particles
        field.step(by: 1.0 / 30.0)
        #expect(field.particles != before)
    }

    @Test func opacityStaysVisible() {
        typealias Field = SpoilerParticleField<SeededGenerator>
        let times = Array(stride(from: 0.0, through: 10.0, by: 0.37))
        let opacities = makeField().particles.flatMap { particle in
            times.map { Field.opacity(of: particle, at: $0) }
        }
        #expect(opacities.allSatisfy { (0.35...1.0).contains($0) })
    }
}
