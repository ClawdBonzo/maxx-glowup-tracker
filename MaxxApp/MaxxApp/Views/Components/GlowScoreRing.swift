import SwiftUI

struct GlowScoreRing: View {
    let score: Double
    var size: CGFloat = 120
    @State private var animatedScore: Double = 0
    @State private var outerPulse = false

    private var neonGradientColors: [Color] {
        [Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700")]
    }

    private var scoreLabel: String {
        switch score {
        case 0..<30:  "Getting Started"
        case 30..<60: "On Track"
        case 60..<80: "Looking Good"
        default:      "GLOWING 🔥"
        }
    }

    var body: some View {
        ZStack {
            // Outer ambient pulse ring
            Circle()
                .stroke(
                    AngularGradient(colors: neonGradientColors, center: .center),
                    style: StrokeStyle(lineWidth: size * 0.015, lineCap: .round)
                )
                .frame(width: size * 1.35, height: size * 1.35)
                .blur(radius: outerPulse ? 18 : 10)
                .opacity(outerPulse ? 0.25 : 0.10)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: outerPulse)

            // Track ring
            Circle()
                .stroke(Color.maxxSurfaceLight, lineWidth: size * 0.08)
                .frame(width: size, height: size)

            // Bloom layer (blurred duplicate for glow)
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(colors: neonGradientColors, center: .center),
                    style: StrokeStyle(lineWidth: size * 0.10, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .blur(radius: 16)
                .opacity(0.70)

            // Sharp ring on top
            Circle()
                .trim(from: 0, to: animatedScore / 100)
                .stroke(
                    AngularGradient(colors: neonGradientColors, center: .center),
                    style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center score
            VStack(spacing: 2) {
                Text("\(Int(animatedScore))")
                    .font(.system(size: size * 0.30, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(hex: "B040FF")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "8B00FF").opacity(0.8), radius: 8)
                    .contentTransition(.numericText())

                Text(scoreLabel)
                    .font(.system(size: size * 0.09))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "00F0FF"), Color(hex: "8B00FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.2)) {
                animatedScore = score
            }
            outerPulse = true
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(response: 0.7)) {
                animatedScore = newValue
            }
        }
    }
}
