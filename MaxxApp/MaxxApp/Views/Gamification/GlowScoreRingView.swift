import SwiftUI

struct GlowScoreRingView: View {
    let level: JawlineLevel
    let progress: Double
    let totalXP: Int

    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animated = false

    // New neon palette — matches global theme
    private let gradientColors: [Color] = [
        Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700")
    ]

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.maxxSurface, lineWidth: 12)
                    .accessibilityHidden(true)

                // Bloom layer — glow behind the sharp ring
                Circle()
                    .trim(from: 0, to: animated ? progress : 0)
                    .stroke(
                        AngularGradient(colors: gradientColors, center: .center),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: contrast == .increased ? 0 : 14)
                    .opacity(contrast == .increased ? 0 : 0.55)
                    .accessibilityHidden(true)

                // Sharp progress ring on top
                Circle()
                    .trim(from: 0, to: animated ? progress : 0)
                    .stroke(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.8),
                        value: animated
                    )
                    .accessibilityHidden(true)

                // Center content
                VStack(spacing: 8) {
                    Image(systemName: level.iconName)
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .accessibilityHidden(true)

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
            // Single Metal compositing pass
            .drawingGroup()
            // Unified accessibility element for the whole ring
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(level.displayName), \(totalXP) XP, \(Int(progress * 100)) percent progress to next level"))

            Text("Level \(JawlineLevel.allCases.firstIndex(of: level) ?? 0) of \(JawlineLevel.allCases.count)")
                .font(.caption)
                .foregroundColor(.maxxTextMuted)
                .accessibilityLabel(Text("Level \(JawlineLevel.allCases.firstIndex(of: level) ?? 0) of \(JawlineLevel.allCases.count)"))
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.8).delay(0.1)) {
                    animated = true
                }
            } else {
                animated = true
            }
        }
    }
}

#Preview {
    GlowScoreRingView(level: .goldJawline, progress: 0.65, totalXP: 1250)
        .background(Color.maxxBackground)
}
