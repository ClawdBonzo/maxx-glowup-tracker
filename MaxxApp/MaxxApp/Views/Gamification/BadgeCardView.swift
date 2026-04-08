import SwiftUI

struct BadgeCardView: View {
    let badge: Badge
    let showUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        badge.isUnlocked
                            ? Color(hex: badge.tier.color).opacity(0.2)
                            : Color.maxxSurface
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                badge.isUnlocked
                                    ? Color(hex: badge.tier.color)
                                    : Color.white.opacity(0.1),
                                lineWidth: 2
                            )
                    )

                if badge.isUnlocked {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: badge.tier.color))
                        .padding(12)
                }

                VStack(spacing: 12) {
                    Text(badge.icon)
                        .font(.system(size: 44))

                    VStack(spacing: 4) {
                        Text(badge.name)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(badge.details)
                            .font(.caption)
                            .foregroundColor(.maxxTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    if !badge.isUnlocked {
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
            .frame(height: 180)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        BadgeCardView(
            badge: Badge(
                name: "First Step",
                description: "Complete your first daily routine",
                icon: "👣",
                tier: .bronze,
                requirement: .routinesCompleted(1)
            ),
            showUnlocked: true
        )
        BadgeCardView(
            badge: Badge(
                name: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "⚔️",
                tier: .silver,
                requirement: .streakDays(7)
            ),
            showUnlocked: false
        )
    }
    .padding(.horizontal, 20)
    .background(Color.maxxBackground)
}
