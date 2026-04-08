import SwiftUI

struct QuestCardView: View {
    let quest: Quest
    let isCompleted: Bool
    var onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Quest Icon
            Text(quest.icon)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(Color.maxxSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Quest Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quest.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if quest.type == .daily {
                        Text("Daily")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: "00CEC9").opacity(0.3))
                            .clipShape(Capsule())
                    }
                }

                Text(quest.details)
                    .font(.caption)
                    .foregroundColor(.maxxTextSecondary)
            }

            Spacer()

            // Complete Button or XP Badge
            if isCompleted {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "00CEC9"))
                    Text("\(quest.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "00CEC9"))
                }
            } else {
                Button {
                    onComplete()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("\(quest.xpReward)")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.maxxSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(isCompleted ? 0.6 : 1)
    }
}

#Preview {
    VStack(spacing: 12) {
        QuestCardView(
            quest: Quest(
                type: .daily,
                title: "Morning Routine",
                description: "Complete any morning habit",
                icon: "🌅",
                xpReward: 50,
                targetDate: .now
            ),
            isCompleted: false,
            onComplete: {}
        )
        QuestCardView(
            quest: Quest(
                type: .daily,
                title: "Progress Photo",
                description: "Take a progress photo",
                icon: "📸",
                xpReward: 75,
                targetDate: .now
            ),
            isCompleted: true,
            onComplete: {}
        )
    }
    .padding(.horizontal, 20)
    .background(Color.maxxBackground)
}
