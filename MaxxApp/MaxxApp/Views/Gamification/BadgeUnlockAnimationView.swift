import SwiftUI

struct BadgeUnlockAnimationView: View {
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    let badge: Badge

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: badge.tier.color),
                                Color(hex: badge.tier.color).opacity(0),
                            ],
                            startPoint: .center,
                            endPoint: .topLeading
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 160, height: 160)
                    .opacity(opacity)
                    .scaleEffect(scale)

                // Badge icon
                Text(badge.icon)
                    .font(.system(size: 60))
                    .scaleEffect(scale)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            }

            VStack(spacing: 12) {
                Text("Badge Unlocked!")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)

                Text(badge.name)
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: badge.tier.color), Color(hex: badge.tier.color).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text(badge.details)
                    .font(.caption)
                    .foregroundColor(.maxxTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.maxxBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                scale = 1
                opacity = 1
            }
            withAnimation(
                .easeInOut(duration: 1.5)
                    .repeatCount(2, autoreverses: true)
            ) {
                rotation = 360
            }
        }
    }
}

#Preview {
    BadgeUnlockAnimationView(
        badge: Badge(
            name: "Jawline God",
            description: "Reach Diamond Jawline level",
            icon: "💎",
            tier: .diamond,
            requirement: .levelReached(20)
        )
    )
}
