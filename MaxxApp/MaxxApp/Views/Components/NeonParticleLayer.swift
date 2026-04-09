import SwiftUI

// MARK: - Device Tier

/// Classify device performance tier to throttle particle count automatically.
private enum DeviceTier {
    case high   // iPhone 14 Pro, 15, 16
    case mid    // iPhone 12, 13, 14
    case low    // iPhone 11 and older

    static var current: DeviceTier {
        // ProcessInfo.processInfo.processorCount is a reliable proxy for chip generation
        let cores = ProcessInfo.processInfo.processorCount
        if cores >= 6 { return .high }
        if cores >= 4 { return .mid }
        return .low
    }

    func cappedCount(_ requested: Int) -> Int {
        switch self {
        case .high: return min(requested, 22)
        case .mid:  return min(requested, 14)
        case .low:  return min(requested, 8)
        }
    }
}

// MARK: - Neon Particle Data

private struct Particle: Identifiable {
    let id: Int          // stable Int ID — cheaper than UUID
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let colorIndex: Int  // index into fixed palette — avoids Color heap alloc per particle
    let duration: Double
    let delay: Double
    let driftX: CGFloat
    let driftY: CGFloat
}

// MARK: - Neon Particle Layer

/// Drop-in animated neon particle background.
/// - Automatically disables when `accessibilityReduceMotion` is on.
/// - Throttles particle count by device tier (8 / 14 / 22 max).
/// - Uses `.drawingGroup()` to flatten all particles into a single Metal layer.
/// - Zero hit-testing impact — fully non-interactive.
struct NeonParticleLayer: View {
    /// Requested particle count — will be capped by DeviceTier.
    var count: Int = 22
    var opacity: Double = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animating = false
    @State private var particles: [Particle] = []

    // Fixed palette avoids repeated Color(hex:) allocations per frame
    private static let palette: [Color] = [
        Color(hex: "8B00FF"), // violet
        Color(hex: "00F0FF"), // cyan
        Color(hex: "FFD700"), // gold
        Color(hex: "FF3CAC"), // pink
        Color(hex: "B040FF"), // light violet
    ]

    var body: some View {
        // If accessibility reduce motion is on, show simple static gradient only
        if reduceMotion {
            LinearGradient(
                colors: [Color(hex: "8B00FF").opacity(0.08), Color(hex: "00F0FF").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .allowsHitTesting(false)
        } else {
            particleCanvas
        }
    }

    // MARK: Particle Canvas

    @ViewBuilder
    private var particleCanvas: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    let color = Self.palette[p.colorIndex]
                    Circle()
                        .fill(color.opacity(0.75 * opacity))
                        .frame(width: p.size, height: p.size)
                        .blur(radius: p.size * 0.55)
                        .position(
                            x: animating ? p.x + p.driftX : p.x,
                            y: animating ? p.y + p.driftY : p.y
                        )
                        .opacity(animating ? 1 : 0)
                        .animation(
                            .easeInOut(duration: p.duration)
                                .repeatForever(autoreverses: true)
                                .delay(p.delay),
                            value: animating
                        )
                        .accessibilityHidden(true) // decorative — hide from VoiceOver
                }
            }
            // Flatten all circles into one Metal compositing pass
            .drawingGroup()
            .onAppear {
                let capped = DeviceTier.current.cappedCount(count)
                spawnParticles(in: geo.size, count: capped)
                // Small delay lets layout settle before kicking off animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    animating = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: Spawn

    private func spawnParticles(in size: CGSize, count: Int) {
        particles = (0..<count).map { i in
            Particle(
                id: i,
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...5),
                colorIndex: i % Self.palette.count,
                duration: Double.random(in: 2.5...5.0),
                delay: Double.random(in: 0...2.5),
                driftX: CGFloat.random(in: -28...28),
                driftY: CGFloat.random(in: -28...28)
            )
        }
    }
}

// MARK: - Neon Screen Background

/// Full-screen dark background with ambient glows + particle layer.
/// Particles are automatically disabled for accessibility (reduce motion).
struct NeonScreenBackground: View {
    var particleCount: Int = 20
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()

            // Ambient violet glow — reduced in high-contrast mode
            RadialGradient(
                colors: [Color.maxxPrimary.opacity(contrast == .increased ? 0.08 : 0.20), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            // Ambient cyan glow — reduced in high-contrast mode
            RadialGradient(
                colors: [Color.maxxCyan.opacity(contrast == .increased ? 0.05 : 0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            // Particle layer (auto-disables for reduce motion)
            NeonParticleLayer(count: particleCount, opacity: 0.9)
                .ignoresSafeArea()
        }
    }
}
