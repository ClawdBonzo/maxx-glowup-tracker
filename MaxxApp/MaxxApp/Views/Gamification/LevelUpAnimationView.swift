import SwiftUI

// MARK: - Confetti Particle

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let color: Color
    let size: CGFloat
    let rotationSpeed: Double
    let fallSpeed: Double
    let delay: Double
    let shape: Int // 0=circle, 1=rect, 2=star
}

// MARK: - Level Up Animation (Viral)

struct LevelUpAnimationView: View {
    let level: JawlineLevel

    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 0
    @State private var titleScale: CGFloat = 0.6
    @State private var flashOpacity: Double = 0
    @State private var glowRadius: CGFloat = 20
    @State private var emojiRotation: Double = -15
    @State private var confettiActive = false
    @State private var particleY: CGFloat = -100
    @State private var particles: [ConfettiParticle] = []
    @State private var showShare = false

    private let neonColors: [Color] = [
        Color(hex: "8B00FF"), Color(hex: "00F0FF"), Color(hex: "FFD700"),
        Color(hex: "FF3CAC"), Color(hex: "B040FF"), Color(hex: "00FFB2"),
    ]

    var body: some View {
        ZStack {
            // Screen flash
            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)

            // Deep dark background with violet ambient
            ZStack {
                Color(hex: "08080F").ignoresSafeArea()
                RadialGradient(
                    colors: [Color(hex: "8B00FF").opacity(0.35), .clear],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
            }

            // Confetti rain
            GeometryReader { geo in
                ZStack {
                    ForEach(particles) { p in
                        ConfettiPieceView(particle: p, screenHeight: geo.size.height)
                    }
                }
            }
            .ignoresSafeArea()

            // Neon particle glow dots
            NeonParticleLayer(count: 30, opacity: 1.0)
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 28) {
                // Neon glow ring behind emoji
                ZStack {
                    // Outer bloom
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "8B00FF").opacity(0.6), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 20)

                    // Ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "8B00FF"),
                                    Color(hex: "00F0FF"),
                                    Color(hex: "FFD700"),
                                    Color(hex: "8B00FF"),
                                ],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color(hex: "8B00FF"), radius: glowRadius)
                        .shadow(color: Color(hex: "00F0FF"), radius: glowRadius * 0.5)

                    // Level emoji
                    Text(level.emoji)
                        .font(.system(size: 72))
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(emojiRotation))
                        .shadow(color: Color(hex: "8B00FF").opacity(0.8), radius: 20)
                        .shadow(color: Color(hex: "00F0FF").opacity(0.5), radius: 40)
                }
                .opacity(opacity)

                // LEVEL UP text
                VStack(spacing: 10) {
                    Text("LEVEL UP!")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "8B00FF"),
                                    Color(hex: "00F0FF"),
                                    Color(hex: "FFD700"),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: "8B00FF").opacity(0.8), radius: 16)
                        .shadow(color: Color(hex: "00F0FF").opacity(0.5), radius: 30)
                        .scaleEffect(titleScale)

                    Text("PHOENIX RISING 🔥")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)

                    Text("Reached \(level.displayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "00F0FF"), Color(hex: "B040FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(opacity)
                }

                // Share button
                Button {
                    showShare = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        Text("Share My Level-Up")
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
                .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showShare) {
            ShareGlowUpView(
                title: "Leveled Up!",
                emoji: level.emoji,
                subtitle: "Reached \(level.displayName)",
                level: level.displayName
            )
        }
        .onAppear {
            spawnConfetti()
            triggerAnimation()
        }
    }

    private func triggerAnimation() {
        // Instant screen flash
        withAnimation(.easeOut(duration: 0.1)) { flashOpacity = 0.6 }
        withAnimation(.easeIn(duration: 0.3).delay(0.1)) { flashOpacity = 0 }

        // Haptics: layered
        HapticService.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { HapticService.impact(.heavy) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { HapticService.impact(.medium) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) { HapticService.success() }

        // Emoji pop in
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
            scale = 1.1
            opacity = 1
            emojiRotation = 8
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.35)) {
            scale = 1.0
            emojiRotation = 0
        }

        // Title burst
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.1)) {
            titleScale = 1.05
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7).delay(0.5)) {
            titleScale = 1.0
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.4)) {
            glowRadius = 40
        }

        // Confetti
        confettiActive = true
    }

    private func spawnConfetti() {
        particles = (0..<60).map { i in
            ConfettiParticle(
                x: CGFloat.random(in: 0...1),
                color: neonColors[i % neonColors.count],
                size: CGFloat.random(in: 6...14),
                rotationSpeed: Double.random(in: 180...720),
                fallSpeed: Double.random(in: 2.0...4.5),
                delay: Double.random(in: 0...1.5),
                shape: Int.random(in: 0...2)
            )
        }
    }
}

// MARK: - Confetti Piece

private struct ConfettiPieceView: View {
    let particle: ConfettiParticle
    let screenHeight: CGFloat

    @State private var yOffset: CGFloat = -60
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Group {
            if particle.shape == 0 {
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            } else if particle.shape == 1 {
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 0.5)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
            }
        }
        .shadow(color: particle.color, radius: 4)
        .opacity(opacity)
        .rotationEffect(.degrees(rotation))
        .position(
            x: UIScreen.main.bounds.width * particle.x,
            y: yOffset
        )
        .onAppear {
            withAnimation(
                .linear(duration: particle.fallSpeed)
                    .delay(particle.delay)
                    .repeatForever(autoreverses: false)
            ) {
                yOffset = screenHeight + 80
            }
            withAnimation(
                .linear(duration: particle.fallSpeed * 0.5)
                    .delay(particle.delay)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = particle.rotationSpeed
            }
        }
    }
}
