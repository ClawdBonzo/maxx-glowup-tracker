import SwiftUI

struct BadgeUnlockAnimationView: View {
    let badge: Badge

    @State private var scale: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var flashOpacity: Double = 0
    @State private var glowPulse = false
    @State private var confettiActive = false
    @State private var confettiParticles: [BadgeConfetti] = []
    @State private var showShare = false

    private let neonColors: [Color] = [
        Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700"),
        Color(hex: "FF3CAC"), Color(hex: "B040FF"),
    ]

    private var tierColor: Color { Color(hex: badge.tier.color) }

    var body: some View {
        ZStack {
            // Flash
            Color.white.ignoresSafeArea().opacity(flashOpacity)

            // Background
            ZStack {
                Color(hex: "08080F").ignoresSafeArea()
                RadialGradient(
                    colors: [tierColor.opacity(0.30), Color(hex: "8B00FF").opacity(0.15), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 380
                )
                .ignoresSafeArea()
            }

            // Confetti
            GeometryReader { geo in
                ForEach(confettiParticles) { p in
                    BadgeConfettiView(particle: p, screenHeight: geo.size.height)
                }
            }
            .ignoresSafeArea()

            NeonParticleLayer(count: 25, opacity: 0.9)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Badge display
                ZStack {
                    // Outer glow bloom
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [tierColor.opacity(0.5), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .blur(radius: 22)
                        .scaleEffect(glowPulse ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)

                    // Animated neon ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    tierColor,
                                    Color(hex: "00F0FF"),
                                    Color(hex: "FFD700"),
                                    tierColor,
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 4])
                        )
                        .frame(width: 170, height: 170)
                        .scaleEffect(ringScale)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: tierColor, radius: 12)
                        .shadow(color: Color(hex: "00F0FF"), radius: 20)

                    // Second ring (counter-rotate)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "8B00FF").opacity(0.6), Color(hex: "FFD700").opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 6])
                        )
                        .frame(width: 148, height: 148)
                        .rotationEffect(.degrees(-rotation * 0.7))

                    // Badge icon
                    Text(badge.icon)
                        .font(.system(size: 72))
                        .scaleEffect(scale)
                        .shadow(color: tierColor.opacity(0.9), radius: 18)
                        .shadow(color: Color(hex: "00F0FF").opacity(0.5), radius: 32)
                }
                .opacity(opacity)

                // Text
                VStack(spacing: 10) {
                    Text("BADGE UNLOCKED!")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "8B00FF").opacity(0.8), radius: 12)
                        .scaleEffect(opacity > 0 ? 1 : 0.7)

                    Text(badge.name)
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tierColor, tierColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: tierColor.opacity(0.6), radius: 8)

                    Text(badge.details)
                        .font(.subheadline)
                        .foregroundColor(.maxxTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(opacity)

                // Share button
                Button {
                    showShare = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        Text("Share My Badge")
                            .font(.headline)
                            .fontWeight(.black)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FF8C00")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "FFD700").opacity(0.6), radius: 14)
                }
                .opacity(opacity)
                .scaleEffect(opacity > 0 ? 1 : 0.8)
            }
        }
        .sheet(isPresented: $showShare) {
            ShareGlowUpView(title: "Badge Unlocked: \(badge.name)", emoji: badge.icon, subtitle: badge.details)
        }
        .onAppear {
            spawnConfetti()
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        // Screen flash
        withAnimation(.easeOut(duration: 0.08)) { flashOpacity = 0.5 }
        withAnimation(.easeIn(duration: 0.25).delay(0.08)) { flashOpacity = 0 }

        // Layered haptics
        HapticService.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { HapticService.impact(.heavy) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { HapticService.impact(.medium) }

        // Badge pop
        withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
            scale = 1.1
            opacity = 1
            ringScale = 1
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.4)) {
            scale = 1.0
        }

        // Continuous ring spin
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.3)) {
            rotation = 360
        }

        // Glow pulse
        glowPulse = true
    }

    private func spawnConfetti() {
        confettiParticles = (0..<50).map { i in
            BadgeConfetti(
                x: CGFloat.random(in: 0...1),
                color: neonColors[i % neonColors.count],
                size: CGFloat.random(in: 5...12),
                delay: Double.random(in: 0...1.0),
                speed: Double.random(in: 2.0...4.0)
            )
        }
    }
}

// MARK: - Badge Confetti

struct BadgeConfetti: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let delay: Double
    let speed: Double
}

struct BadgeConfettiView: View {
    let particle: BadgeConfetti
    let screenHeight: CGFloat
    @State private var yOffset: CGFloat = -40
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .shadow(color: particle.color, radius: 4)
            .rotationEffect(.degrees(rotation))
            .position(
                x: UIScreen.main.bounds.width * particle.x,
                y: yOffset
            )
            .onAppear {
                withAnimation(.linear(duration: particle.speed).delay(particle.delay).repeatForever(autoreverses: false)) {
                    yOffset = screenHeight + 60
                    rotation = 360
                }
            }
    }
}

// MARK: - Share Glow-Up View

struct ShareGlowUpView: View {
    @Environment(\.dismiss) private var dismiss
    var title: String
    var emoji: String
    var subtitle: String
    var level: String = ""
    var streak: Int = 0

    @State private var rendered: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "08080F").ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Your Shareable Card")
                        .font(.headline)
                        .foregroundColor(.maxxTextSecondary)

                    // The shareable card preview
                    shareCard
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: Color(hex: "8B00FF").opacity(0.5), radius: 24)
                        .shadow(color: Color(hex: "00F0FF").opacity(0.25), radius: 40)
                        .padding(.horizontal, 28)

                    Text("Share to Instagram Stories, TikTok, or anywhere ✨")
                        .font(.caption)
                        .foregroundColor(.maxxTextMuted)
                        .multilineTextAlignment(.center)

                    Button {
                        renderAndShare()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                            Text("Share My Glow-Up")
                                .font(.headline)
                                .fontWeight(.black)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "8B00FF").opacity(0.6), radius: 16)
                    }
                    .padding(.horizontal, 28)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.maxxTextSecondary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = rendered {
                ShareSheet(items: [img])
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Share Card (Renders to image)

    private var shareCard: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0D0020"), Color(hex: "001830"), Color(hex: "08080F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient glows
            RadialGradient(
                colors: [Color(hex: "8B00FF").opacity(0.4), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 250
            )
            RadialGradient(
                colors: [Color(hex: "00F0FF").opacity(0.25), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 200
            )

            // Neon frame border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "8B00FF"),
                            Color(hex: "00F0FF"),
                            Color(hex: "FFD700"),
                            Color(hex: "8B00FF"),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )

            VStack(spacing: 20) {
                // MAXX watermark
                Text("MAXX")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(0.7)

                Text(emoji)
                    .font(.system(size: 68))
                    .shadow(color: Color(hex: "8B00FF").opacity(0.8), radius: 16)
                    .shadow(color: Color(hex: "00F0FF").opacity(0.4), radius: 28)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "C0B8D8"))
                        .multilineTextAlignment(.center)
                }

                if !level.isEmpty || streak > 0 {
                    HStack(spacing: 20) {
                        if !level.isEmpty {
                            VStack(spacing: 2) {
                                Text(level)
                                    .font(.caption)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                Text("LEVEL")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: "6B6890"))
                            }
                        }
                        if streak > 0 {
                            VStack(spacing: 2) {
                                Text("\(streak) 🔥")
                                    .font(.caption)
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                                Text("DAY STREAK")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color(hex: "6B6890"))
                            }
                        }
                    }
                }

                Text("maxx.app • Your Glow-Up Starts Here")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "6B6890"))
            }
            .padding(32)
        }
        .frame(width: 320, height: 420)
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareCard)
        renderer.scale = 3.0
        if let img = renderer.uiImage {
            rendered = img
            showShareSheet = true
        }
    }
}

// MARK: - UIKit Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
