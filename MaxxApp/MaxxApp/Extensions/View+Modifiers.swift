import SwiftUI

// MARK: - Neon Glow Modifier

struct NeonGlowModifier: ViewModifier {
    var color: Color = .maxxPrimary
    var radius: CGFloat = 12
    var intensity: Double = 1.0

    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        // Reduce glow intensity in high-contrast mode — keep it accessible but still branded
        let effectiveIntensity = contrast == .increased ? intensity * 0.25 : intensity
        content
            .shadow(color: color.opacity(0.8 * effectiveIntensity), radius: radius * 0.5)
            .shadow(color: color.opacity(0.5 * effectiveIntensity), radius: radius)
            .shadow(color: color.opacity(0.25 * effectiveIntensity), radius: radius * 2)
    }
}

// MARK: - Neon Card Modifier

struct NeonCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var glowColor: Color = .maxxPrimary
    var glowRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.maxxSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [glowColor.opacity(0.6), glowColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: glowColor.opacity(0.15), radius: glowRadius, y: 4)
            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.maxxSurface.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.maxxPrimary.opacity(0.3), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Maxx Card Modifier

struct MaxxCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.maxxSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.maxxPrimary.opacity(0.4), Color.maxxCyan.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.maxxPrimary.opacity(0.1), radius: 10, y: 4)
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -300

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.12), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

// MARK: - Neon Pulse Modifier

struct NeonPulseModifier: ViewModifier {
    @State private var pulsing = false
    var color: Color = .maxxPrimary

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        // Static shadow in reduce-motion or high-contrast — no animation
        let opacity = reduceMotion || contrast == .increased ? 0.4 : (pulsing ? 0.9 : 0.3)
        let shadowRadius: CGFloat = reduceMotion || contrast == .increased ? 8 : (pulsing ? 18 : 6)
        content
            .shadow(color: color.opacity(opacity), radius: shadowRadius)
            .shadow(color: color.opacity(opacity * 0.5), radius: shadowRadius * 2)
            .onAppear {
                guard !reduceMotion && contrast != .increased else { return }
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    func maxxCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(MaxxCardModifier(cornerRadius: cornerRadius))
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func neonGlow(color: Color = .maxxPrimary, radius: CGFloat = 12, intensity: Double = 1.0) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius, intensity: intensity))
    }

    func neonPulse(color: Color = .maxxPrimary) -> some View {
        modifier(NeonPulseModifier(color: color))
    }

    func neonCard(cornerRadius: CGFloat = 20, glowColor: Color = .maxxPrimary) -> some View {
        modifier(NeonCardModifier(cornerRadius: cornerRadius, glowColor: glowColor))
    }

    func maxxGradientForeground() -> some View {
        overlay(Color.maxxGradient)
            .mask(self)
    }

    func neonTriGradientForeground() -> some View {
        overlay(
            LinearGradient(
                colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .mask(self)
    }

    func fadeInAnimation(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {}
            }
    }
}

// MARK: - Animated Visibility

struct AnimatedVisibility: ViewModifier {
    let isVisible: Bool
    let delay: Double
    @State private var show = false

    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 30)
            .onAppear {
                guard isVisible else { return }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    show = true
                }
            }
            .onChange(of: isVisible) { _, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    show = newValue
                }
            }
    }
}

extension View {
    func animatedVisibility(_ isVisible: Bool, delay: Double = 0) -> some View {
        modifier(AnimatedVisibility(isVisible: isVisible, delay: delay))
    }
}

// MARK: - Neon Background Modifier

struct NeonAmbientBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.maxxBackground.ignoresSafeArea()
            // Violet ambient radial glow top-left
            RadialGradient(
                colors: [Color.maxxPrimary.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 10,
                endRadius: 320
            )
            .ignoresSafeArea()
            // Cyan ambient radial glow bottom-right
            RadialGradient(
                colors: [Color.maxxCyan.opacity(0.10), .clear],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func neonAmbientBackground() -> some View {
        modifier(NeonAmbientBackground())
    }
}
