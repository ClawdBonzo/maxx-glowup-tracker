import SwiftUI

struct GlowScoreRingView: View {
    let level: JawlineLevel
    let progress: Double
    let totalXP: Int

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.maxxSurface, lineWidth: 12)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "6C5CE7"), Color(hex: "00CEC9")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                VStack(spacing: 8) {
                    Text(level.emoji)
                        .font(.system(size: 48))

                    Text(level.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(totalXP) XP")
                        .font(.caption)
                        .foregroundColor(.maxxTextMuted)
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 24)

            // XP progress text
            Text("Level \(JawlineLevel.allCases.firstIndex(of: level) ?? 0) / \(JawlineLevel.allCases.count)")
                .font(.caption)
                .foregroundColor(.maxxTextMuted)
        }
    }
}

#Preview {
    GlowScoreRingView(level: .goldJawline, progress: 0.65, totalXP: 1250)
        .background(Color.maxxBackground)
}
