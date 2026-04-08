import SwiftUI

struct LevelUpAnimationView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    let level: JawlineLevel

    var body: some View {
        VStack(spacing: 20) {
            Text(level.emoji)
                .font(.system(size: 80))
                .scaleEffect(scale)
                .opacity(opacity)

            VStack(spacing: 8) {
                Text("Level Up!")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)

                Text("Reached \(level.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextSecondary)
            }
            .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Color.maxxBackground.ignoresSafeArea()

                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(
                            [Color(hex: "6C5CE7"), Color(hex: "00CEC9"), Color(hex: "FDCB6E")]
                                .randomElement() ?? Color.maxxPrimary
                        )
                        .frame(width: CGFloat.random(in: 4...12))
                        .offset(
                            x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -200...200)
                        )
                        .opacity(opacity)
                }
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1
                opacity = 1
            }
        }
    }
}
