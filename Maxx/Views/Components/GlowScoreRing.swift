import SwiftUI

struct GlowScoreRing: View {
    let score: Double
    var size: CGFloat = 120
    @State private var animatedScore: Double = 0

    private var scoreColor: Color {
        switch score {
        case 0..<30: .maxxError
        case 30..<60: .maxxWarning
        case 60..<80: .maxxPrimary
        default: .maxxSuccess
        }
    }

    private var scoreLabel: String {
        switch score {
        case 0..<30: "Getting Started"
        case 30..<60: "On Track"
        case 60..<80: "Looking Good"
        default: "Glowing"
        }
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.maxxSurfaceLight, lineWidth: size * 0.08)
                .frame(width: size, height: size)

            // Score ring
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(
                        colors: [scoreColor.opacity(0.5), scoreColor],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedScore / 100)
                    ),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Glow effect
            Circle()
                .trim(from: max(0, animatedScore / 100 - 0.01), to: animatedScore / 100)
                .stroke(scoreColor, lineWidth: size * 0.04)
                .blur(radius: 8)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 2) {
                Text("\(Int(animatedScore))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                Text(scoreLabel)
                    .font(.system(size: size * 0.08))
                    .fontWeight(.medium)
                    .foregroundColor(.maxxTextSecondary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(response: 0.6)) {
                animatedScore = newValue
            }
        }
    }
}
