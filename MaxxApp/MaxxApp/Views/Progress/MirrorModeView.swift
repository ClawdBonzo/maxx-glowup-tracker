import SwiftUI
import AVFoundation

// MARK: - Mirror Mode View

struct MirrorModeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var cameraVM = MirrorCameraViewModel()
    @State private var gridOpacity: Double = 0.4
    @State private var showGlowUp = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch cameraVM.authStatus {
            case .authorized:
                cameraContent

            case .notDetermined:
                permissionRequestView

            case .denied, .restricted:
                permissionDeniedView

            @unknown default:
                permissionDeniedView
            }
        }
        .onAppear { cameraVM.checkAuthorization() }
        .onChange(of: cameraVM.faceAligned) { _, aligned in
            guard aligned else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showGlowUp = true }
            HapticService.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { showGlowUp = false }
            }
        }
        .preferredColorScheme(.dark)
        .accessibilityLabel("Mirror Mode — golden ratio face alignment tool")
    }

    // MARK: - Camera Content

    @ViewBuilder
    private var cameraContent: some View {
        // Live preview (mirrored)
        CameraPreviewView(session: cameraVM.session)
            .ignoresSafeArea()
            .scaleEffect(x: -1)
            .accessibilityHidden(true) // decorative video — VoiceOver reads status pill instead

        // Golden ratio grid
        if !reduceMotion {
            GoldenRatioGridView(
                glowActive: cameraVM.faceDetected,
                opacity: gridOpacity
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: cameraVM.faceDetected)
            .accessibilityHidden(true)
        }

        // Glow-Up Detected banner
        if showGlowUp {
            GlowUpDetectedBanner()
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(10)
        }

        // UI overlay
        VStack {
            topBar
            Spacer()
            statusPill
            bottomHints
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
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
            .accessibilityLabel("Close Mirror Mode")

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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mirror Mode with Golden Ratio Overlay")
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
    }

    // MARK: - Status Pill

    private var statusPill: some View {
        let detected = cameraVM.faceDetected
        return HStack(spacing: 8) {
            Circle()
                .fill(detected ? Color(hex: "00FFB2") : Color(hex: "FFD700"))
                .frame(width: 8, height: 8)
                .shadow(color: detected ? Color(hex: "00FFB2") : Color(hex: "FFD700"), radius: 4)
                .accessibilityHidden(true)

            Text(detected ? "Face Detected • Align Grid" : "Position Your Face")
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
                    detected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        : AnyShapeStyle(Color.white.opacity(0.15)),
                    lineWidth: 1
                )
        )
        .accessibilityLabel(detected ? "Face detected, align to the golden ratio grid" : "Position your face in frame")
    }

    // MARK: - Bottom Hints

    private var bottomHints: some View {
        VStack(spacing: 8) {
            Text("Golden ratio lines light up when your proportions align ✨")
                .font(.caption2)
                .foregroundColor(Color(hex: "C0B8D8").opacity(0.8))
                .multilineTextAlignment(.center)
                .accessibilityLabel("Golden ratio lines light up when your facial proportions align")

            HStack(spacing: 12) {
                Image(systemName: "circle.dotted")
                    .font(.caption)
                    .foregroundColor(Color(hex: "6B6890"))
                    .accessibilityHidden(true)

                Slider(value: $gridOpacity, in: 0.1...1.0)
                    .tint(Color(hex: "8B00FF"))
                    .accessibilityLabel("Grid opacity")
                    .accessibilityValue("\(Int(gridOpacity * 100)) percent")

                Image(systemName: "circle")
                    .font(.caption)
                    .foregroundColor(Color(hex: "6B6890"))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 40)
        }
        .padding(.bottom, 44)
    }

    // MARK: - Permission Views

    private var permissionRequestView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("Camera Access Required")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)

                Text("Mirror Mode uses your front camera to show a live golden ratio overlay for perfect face alignment.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "C0B8D8"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                cameraVM.requestAccess()
            } label: {
                Text("Allow Camera Access")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "8B00FF"), Color(hex: "00F0FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "8B00FF").opacity(0.5), radius: 14)
            }
            .accessibilityHint("Opens a system dialog to grant camera access")

            Button("Not Now") { dismiss() }
                .font(.subheadline)
                .foregroundColor(Color(hex: "6B6890"))
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "FF3860"))

            VStack(spacing: 8) {
                Text("Camera Access Denied")
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundColor(.white)

                Text("Enable camera access in Settings to use Mirror Mode.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "C0B8D8"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color(hex: "8B00FF"))
                    .clipShape(Capsule())
            }
            .accessibilityHint("Opens iOS Settings to allow camera access")

            Button("Dismiss") { dismiss() }
                .font(.subheadline)
                .foregroundColor(Color(hex: "6B6890"))
        }
    }
}

// MARK: - Golden Ratio Grid

struct GoldenRatioGridView: View {
    let glowActive: Bool
    var opacity: Double

    private let phi: CGFloat = 1.618

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let vLine1 = w / phi
            let vLine2 = w - w / phi
            let hLine1 = h / phi
            let hLine2 = h - h / phi

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

                // Face oval guide
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

                // Eye guide dots
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
            }
            .drawingGroup() // flatten grid into single Metal pass
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Glow-Up Detected Banner

struct GlowUpDetectedBanner: View {
    @State private var glowPulse = false

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Text("✨")
                    .font(.title2)
                    .accessibilityHidden(true)

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
                    .accessibilityHidden(true)
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
            .padding(.top, 80)
            .accessibilityLabel("Glow-Up Detected — perfect proportions aligned!")
            .accessibilityAddTraits(.updatesFrequently)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        // Disable UIView accessibility — this is a visual-only camera preview
        view.isAccessibilityElement = false
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
    @Published var authStatus: AVAuthorizationStatus = .notDetermined
    @Published var faceDetected = false
    @Published var faceAligned = false

    let session = AVCaptureSession()
    private var sessionRunning = false

    // MARK: Authorization

    func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        authStatus = status
        if status == .authorized { startSession() }
    }

    func requestAccess() {
        Task {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            authStatus = granted ? .authorized : .denied
            if granted { startSession() }
        }
    }

    // MARK: Session Lifecycle

    func startSession() {
        guard !sessionRunning else { return }
        sessionRunning = true
        let captureSession = session
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
            // Simulate face detection onset (production: use Vision VNDetectFaceRectanglesRequest)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.faceDetected = true
            }
        }
    }

    func stop() {
        let captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.stopRunning()
        }
        sessionRunning = false
        faceDetected = false
        faceAligned = false
    }
}
