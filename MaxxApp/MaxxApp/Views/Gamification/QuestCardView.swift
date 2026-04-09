import SwiftUI

struct QuestCardView: View {
    let quest: Quest
    let isCompleted: Bool
    var onComplete: () -> Void
    @State private var pressed = false

    var body: some View {
        HStack(spacing: 14) {
            // Quest Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        isCompleted
                            ? AnyShapeStyle(LinearGradient(
                                colors: [.maxxPrimary.opacity(0.3), .maxxCyan.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            : AnyShapeStyle(Color.maxxSurfaceLight)
                    )
                    .frame(width: 44, height: 44)
                    .neonGlow(color: isCompleted ? .maxxPrimary : .clear, radius: 6, intensity: 0.5)

                Text(quest.icon)
                    .font(.title3)
            }

            // Quest Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(quest.title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(isCompleted ? .maxxTextSecondary : .white)

                    if quest.type == .daily {
                        Text("DAILY")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    colors: [.maxxPrimary, .maxxCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .neonGlow(color: .maxxCyan, radius: 4, intensity: 0.6)
                    }
                }

                Text(quest.details)
                    .font(.caption)
                    .foregroundColor(.maxxTextMuted)
            }

            Spacer()

            // Complete button / XP badge
            if isCompleted {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.maxxCyan)
                        .neonGlow(color: .maxxCyan, radius: 5)
                    Text("+\(quest.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxCyan, .maxxGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            } else {
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        pressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation { pressed = false }
                        onComplete()
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text("\(quest.xpReward)")
                            .font(.caption2)
                            .fontWeight(.black)
                    }
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .neonGlow(color: .maxxPrimary, radius: 10)
                    .scaleEffect(pressed ? 0.88 : 1.0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .neonCard(cornerRadius: 16, glowColor: isCompleted ? .maxxCyan : .maxxPrimary)
        .padding(.horizontal, 20)
        .opacity(isCompleted ? 0.65 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}
