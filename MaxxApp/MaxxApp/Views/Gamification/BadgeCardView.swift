import SwiftUI

struct BadgeCardView: View {
    let badge: Badge
    let showUnlocked: Bool
    @State private var glowPulse = false

    var tierColor: Color { Color(hex: badge.tier.color) }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                // Card background
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        badge.isUnlocked
                            ? AnyShapeStyle(LinearGradient(
                                colors: [tierColor.opacity(0.18), Color.maxxSurface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(Color.maxxSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                badge.isUnlocked
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [tierColor, tierColor.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    : AnyShapeStyle(Color.white.opacity(0.08)),
                                lineWidth: badge.isUnlocked ? 1.5 : 1
                            )
                    )
                    .shadow(
                        color: badge.isUnlocked ? tierColor.opacity(glowPulse ? 0.35 : 0.15) : .clear,
                        radius: glowPulse ? 16 : 8
                    )
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glowPulse)

                // Unlocked star badge (top-right corner)
                if badge.isUnlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tierColor, tierColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .neonGlow(color: tierColor, radius: 5)
                        .padding(10)
                }

                // Content
                VStack(spacing: 10) {
                    // Badge emoji with glow
                    Text(badge.icon)
                        .font(.system(size: 44))
                        .shadow(color: badge.isUnlocked ? tierColor.opacity(0.7) : .clear, radius: 12)
                        .shadow(color: badge.isUnlocked ? tierColor.opacity(0.3) : .clear, radius: 22)
                        .grayscale(badge.isUnlocked ? 0 : 0.9)
                        .opacity(badge.isUnlocked ? 1 : 0.5)

                    VStack(spacing: 5) {
                        Text(badge.name)
                            .font(.subheadline)
                            .fontWeight(.black)
                            .foregroundColor(badge.isUnlocked ? .white : .maxxTextMuted)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text(badge.details)
                            .font(.caption2)
                            .foregroundColor(badge.isUnlocked ? .maxxTextSecondary : .maxxTextMuted)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }

                    if badge.isUnlocked {
                        Text(badge.tier.rawValue.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.5)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [tierColor, tierColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(tierColor.opacity(0.15))
                            .clipShape(Capsule())
                            .neonGlow(color: tierColor, radius: 4, intensity: 0.5)
                    } else {
                        Text(badge.requirement.displayName)
                            .font(.caption2)
                            .foregroundColor(.maxxTextMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
            }
            .frame(height: 190)
        }
        .onAppear {
            if badge.isUnlocked { glowPulse = true }
        }
    }
}
