import SwiftUI
import AVFoundation

// MARK: - Mirror Mode View

struct MirrorModeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraVM = MirrorCameraViewModel()
    @State private var gridOpacity: Double = 0.4
    @State private var glowActive = false
    @State private var showGlowUp = false
    @State private var gridPulse = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Live camera preview (mirrored = front camera)
            CameraPreviewView(session: cameraVM.session)
                .ignoresSafeArea()
                .scaleEffect(x: -1) // Mirror effect

            // Golden ratio grid overlay
            GoldenRatioGridView(
                glowActive: cameraVM.faceDetected,
                opacity: gridOpacity
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: cameraVM.faceDetected)

            // "Glow-Up Detected" overlay
            if showGlowUp {
                GlowUpDetectedBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // UI overlay
            VStack {
                // Top bar
                HStack {
                    Button {
                        cameraVM.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 4)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("MIRROR MODE")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .tracking(3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Golden Ratio Overlay")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "C0B8D8"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                Spacer()

                // Status pill
                HStack(spacing: 8) {
                    Circle()
                        .fill(cameraVM.faceDetected ? Color(hex: "00FFB2") : Color(hex: "FFD700"))
                        .frame(width: 8, height: 8)
                        .shadow(color: cameraVM.faceDetected ? Color(hex: "00FFB2") : Color(hex: "FFD700"), radius: 4)

                    Text(cameraVM.faceDetected ? "Face Detected • Align Grid" : "Position Your Face")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.black.opacity(0.55))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            cameraVM.faceDetected
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                : AnyShapeStyle(Color.white.opacity(0.15)),
                            lineWidth: 1
                        )
                )

                // Bottom hints
                VStack(spacing: 8) {
                    Text("Golden ratio lines light up when your proportions align ✨")
                        .font(.caption2)
                        .foregroundColor(Color(hex: "C0B8D8").opacity(0.8))
                        .multilineTextAlignment(.center)

                    // Grid opacity slider
                    HStack(spacing: 12) {
                        Image(systemName: "circle.dotted")
                            .font(.caption)
                            .foregroundColor(Color(hex: "6B6890"))
                        Slider(value: $gridOpacity, in: 0.1...1.0)
                            .tint(Color(hex: "8B00FF"))
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundColor(Color(hex: "6B6890"))
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 44)
            }
        }
        .onAppear {
            cameraVM.start()
        }
        .onChange(of: cameraVM.faceAligned) { _, aligned in
            if aligned {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showGlowUp = true
                }
                HapticService.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation { showGlowUp = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Golden Ratio Grid

struct GoldenRatioGridView: View {
    let glowActive: Bool
    var opacity: Double

    // Golden ratio ≈ 1.618
    private let phi: CGFloat = 1.618

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Vertical golden ratio lines
            let vLine1 = w / phi          // ~61.8%
            let vLine2 = w - w / phi      // ~38.2%
            // Horizontal golden ratio lines
            let hLine1 = h / phi          // ~61.8%
            let hLine2 = h - h / phi      // ~38.2%

            let lineColor: Color = glowActive ? Color(hex: "FFD700") : Color(hex: "00F0FF")
            let baseOpacity: Double = glowActive ? 0.85 : 0.45

            ZStack {
                // Vertical lines
                Path { path in
                    path.move(to: CGPoint(x: vLine1, y: 0))
                    path.addLine(to: CGPoint(x: vLine1, y: h))
                    path.move(to: CGPoint(x: vLine2, y: 0))
                    path.addLine(to: CGPoint(x: vLine2, y: h))
                }
                .stroke(
                    lineColor.opacity(baseOpacity * opacity),
                    style: StrokeStyle(lineWidth: glowActive ? 1.5 : 1, dash: [8, 6])
                )
                .shadow(color: lineColor.opacity(glowActive ? 0.9 : 0.3), radius: glowActive ? 10 : 4)

                // Horizontal lines
                Path { path in
                    path.move(to: CGPoint(x: 0, y: hLine1))
                    path.addLine(to: CGPoint(x: w, y: hLine1))
                    path.move(to: CGPoint(x: 0, y: hLine2))
                    path.addLine(to: CGPoint(x: w, y: hLine2))
                }
                .stroke(
                    lineColor.opacity(baseOpacity * opacity),
                    style: StrokeStyle(lineWidth: glowActive ? 1.5 : 1, dash: [8, 6])
                )
                .shadow(color: lineColor.opacity(glowActive ? 0.9 : 0.3), radius: glowActive ? 10 : 4)

                // Face oval guide (centered in top 2/3)
                let ovalCX = w / 2
                let ovalCY = hLine1 * 0.48
                let ovalW: CGFloat = w * 0.52
                let ovalH: CGFloat = ovalW * 1.35

                Ellipse()
                    .stroke(
                        lineColor.opacity((baseOpacity * 0.7) * opacity),
                        style: StrokeStyle(lineWidth: glowActive ? 2 : 1, dash: [6, 5])
                    )
                    .frame(width: ovalW, height: ovalH)
                    .shadow(color: lineColor.opacity(glowActive ? 0.8 : 0.2), radius: glowActive ? 14 : 4)
                    .position(x: ovalCX, y: ovalCY)

                // Eye guide dots at golden intersection
                let eyeY = ovalCY - ovalH * 0.12
                let eyeLX = ovalCX - ovalW * 0.22
                let eyeRX = ovalCX + ovalW * 0.22

                Circle()
                    .fill(lineColor.opacity(0.7 * opacity))
                    .frame(width: 6, height: 6)
                    .shadow(color: lineColor, radius: 6)
                    .position(x: eyeLX, y: eyeY)

                Circle()
                    .fill(lineColor.opacity(0.7 * opacity))
                    .frame(width: 6, height: 6)
                    .shadow(color: lineColor, radius: 6)
                    .position(x: eyeRX, y: eyeY)

                // Center cross
                Path { path in
                    path.move(to: CGPoint(x: w/2 - 10, y: h/2))
                    path.addLine(to: CGPoint(x: w/2 + 10, y: h/2))
                    path.move(to: CGPoint(x: w/2, y: h/2 - 10))
                    path.addLine(to: CGPoint(x: w/2, y: h/2 + 10))
                }
                .stroke(Color(hex: "8B00FF").opacity(0.5 * opacity), lineWidth: 1)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Glow-Up Detected Banner

struct GlowUpDetectedBanner: View {
    @State private var scale: CGFloat = 0.8
    @State private var glowPulse = false

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Text("✨")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("GLOW-UP DETECTED")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "8B00FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Perfect proportions aligned!")
                        .font(.caption)
                        .foregroundColor(Color(hex: "C0B8D8"))
                }

                Text("🔥")
                    .font(.title2)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.black.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "8B00FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color(hex: "FFD700").opacity(glowPulse ? 0.7 : 0.3), radius: glowPulse ? 20 : 10)
            .scaleEffect(scale)
            .padding(.top, 80)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                scale = 1
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Camera Preview (AVFoundation)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK: - Mirror Camera ViewModel

@MainActor
final class MirrorCameraViewModel: ObservableObject {
    @Published var faceDetected = false
    @Published var faceAligned = false

    let session = AVCaptureSession()
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        let captureSession = session
        // Configure and start session on a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .high
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
               let input = try? AVCaptureDeviceInput(device: device),
               captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            captureSession.commitConfiguration()
            captureSession.startRunning()
            // Simulate face detection after short delay (production: use Vision)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.faceDetected = true
            }
        }
    }

    func stop() {
        let captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.stopRunning()
        }
        isRunning = false
    }
}
