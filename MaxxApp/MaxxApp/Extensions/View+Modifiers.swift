import SwiftUI

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Maxx Card Modifier

struct MaxxCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(Color.maxxSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 300
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

    func maxxGradientForeground() -> some View {
        overlay(Color.maxxGradient)
            .mask(self)
    }

    func fadeInAnimation(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    // The animation is handled by the parent
                }
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
