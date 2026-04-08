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

    // Neon violet → cyan → gold gradient matching the brand contour
    private var neonGradientColors: [Color] {
        [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")]
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.maxxSurfaceLight, lineWidth: size * 0.08)
                .frame(width: size, height: size)

            // Neon glow behind the ring
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(
                        colors: neonGradientColors,
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.06, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .blur(radius: 10)
                .opacity(0.6)

            // Score ring
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(
                        colors: neonGradientColors,
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 2) {
                Text("\(Int(animatedScore))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "A29BFE")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
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
