import SwiftUI

// MARK: - Neon Particle Data

private struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    let duration: Double
    let delay: Double
    let driftX: CGFloat
    let driftY: CGFloat
}

// MARK: - Neon Particle Layer

/// Drop-in reusable animated neon particle background.
/// Usage: `ZStack { NeonParticleLayer(); content }`
struct NeonParticleLayer: View {
    var count: Int = 22
    var opacity: Double = 1.0

    @State private var particles: [Particle] = []
    @State private var animating = false

    private let neonColors: [Color] = [
        Color(hex: "8B00FF"), // violet
        Color(hex: "00F0FF"), // cyan
        Color(hex: "FFD700"), // gold
        Color(hex: "FF3CAC"), // pink
        Color(hex: "B040FF"), // light violet
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .blur(radius: p.size * 0.6)
                        .shadow(color: p.color, radius: p.size)
                        .position(
                            x: animating ? p.x + p.driftX : p.x,
                            y: animating ? p.y + p.driftY : p.y
                        )
                        .opacity(animating ? 0.7 * opacity : 0.0)
                        .animation(
                            .easeInOut(duration: p.duration)
                                .repeatForever(autoreverses: true)
                                .delay(p.delay),
                            value: animating
                        )
                }
            }
            .onAppear {
                spawnParticles(in: geo.size)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animating = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnParticles(in size: CGSize) {
        particles = (0..<count).map { i in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...6),
                color: neonColors[i % neonColors.count],
                duration: Double.random(in: 2.5...5.0),
                delay: Double.random(in: 0...3.0),
                driftX: CGFloat.random(in: -30...30),
                driftY: CGFloat.random(in: -30...30)
            )
        }
    }
}

// MARK: - Neon Screen Background

/// Full-screen dark background with ambient glows + particles.
struct NeonScreenBackground: View {
    var particleCount: Int = 20

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            // Ambient violet glow top-left
            RadialGradient(
                colors: [Color.maxxPrimary.opacity(0.20), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()

            // Ambient cyan glow bottom-right
            RadialGradient(
                colors: [Color.maxxCyan.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            // Floating particles
            NeonParticleLayer(count: particleCount, opacity: 0.9)
                .ignoresSafeArea()
        }
    }
}
