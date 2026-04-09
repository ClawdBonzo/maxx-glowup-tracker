import SwiftUI

struct PhotoCompareView: View {
    let photos: [ProgressPhoto]
    @State private var photoA: ProgressPhoto?
    @State private var photoB: ProgressPhoto?
    @State private var sliderPosition: CGFloat = 0.5
    @State private var isDragging = false

    var body: some View {
        ZStack {
            NeonScreenBackground(particleCount: 10)

            VStack(spacing: 20) {
                if let a = photoA, let b = photoB {
                    // Neon comparison view
                    GeometryReader { geo in
                        ZStack {
                            // Photo B (behind)
                            if let imageB = UIImage(data: b.imageData) {
                                Image(uiImage: imageB)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            }

                            // Photo A (clipped to slider)
                            if let imageA = UIImage(data: a.imageData) {
                                Image(uiImage: imageA)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                                    .mask(
                                        HStack {
                                            Rectangle()
                                                .frame(width: geo.size.width * sliderPosition)
                                            Spacer(minLength: 0)
                                        }
                                    )
                            }

                            // Neon glow divider line
                            ZStack {
                                // Bloom
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: isDragging ? 3 : 2)
                                    .blur(radius: isDragging ? 12 : 6)
                                    .opacity(0.8)

                                // Sharp line
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 2)
                            }
                            .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)
                            .frame(height: geo.size.height)

                            // Drag handle
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.maxxPrimary.opacity(0.6), .clear],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 28
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .blur(radius: 8)

                                // Handle circle
                                Circle()
                                    .fill(Color.maxxBackground)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.maxxPrimary, .maxxCyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: .maxxPrimary.opacity(0.7), radius: isDragging ? 14 : 8)
                                    .shadow(color: .maxxCyan.opacity(0.4), radius: isDragging ? 22 : 12)

                                Image(systemName: "arrow.left.and.right")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.maxxPrimary, .maxxCyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .scaleEffect(isDragging ? 1.15 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
                            .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        isDragging = true
                                        withAnimation(.interactiveSpring()) {
                                            sliderPosition = max(0.05, min(0.95, value.location.x / geo.size.width))
                                        }
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                    }
                            )

                            // Date labels
                            VStack {
                                HStack {
                                    Text("BEFORE")
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.maxxPrimary, .maxxCyan],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.black.opacity(0.65))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.maxxPrimary.opacity(0.5), lineWidth: 1)
                                        )
                                        .shadow(color: .maxxPrimary.opacity(0.4), radius: 6)

                                    Spacer()

                                    Text("AFTER")
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.maxxCyan, .maxxGold],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.black.opacity(0.65))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.maxxCyan.opacity(0.5), lineWidth: 1)
                                        )
                                        .shadow(color: .maxxCyan.opacity(0.4), radius: 6)
                                }
                                .padding(12)

                                Spacer()

                                // Date labels below
                                HStack {
                                    Text(a.capturedAt.shortFormatted)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(.black.opacity(0.5))
                                        .clipShape(Capsule())

                                    Spacer()

                                    Text(b.capturedAt.shortFormatted)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(.black.opacity(0.5))
                                        .clipShape(Capsule())
                                }
                                .padding(12)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                LinearGradient(
                                    colors: [.maxxPrimary.opacity(0.7), .maxxCyan.opacity(0.4), .maxxGold.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .maxxPrimary.opacity(0.3), radius: 16)
                    .shadow(color: .maxxCyan.opacity(0.15), radius: 28)
                    .padding(.horizontal, 20)
                    .frame(maxHeight: 400)

                } else {
                    // Selection prompt
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.maxxPrimary.opacity(0.10))
                                .frame(width: 80, height: 80)
                                .neonGlow(color: .maxxPrimary, radius: 14)

                            Image(systemName: "rectangle.on.rectangle")
                                .font(.system(size: 32))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        Text("Select two photos to compare")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.maxxTextSecondary)

                        Text("Tap to select Before, then After")
                            .font(.caption)
                            .foregroundColor(.maxxTextMuted)
                    }
                    .frame(height: 300)
                }

                // Photo selection strip
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Photos")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(photos) { photo in
                                Button {
                                    selectPhoto(photo)
                                } label: {
                                    photoSelectionThumbnail(photo)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func photoSelectionThumbnail(_ photo: ProgressPhoto) -> some View {
        let isSelectedA = photoA?.id == photo.id
        let isSelectedB = photoB?.id == photo.id

        return Group {
            if let data = photo.thumbnailData ?? Optional(photo.imageData),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelectedA
                                    ? AnyShapeStyle(LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    : isSelectedB
                                        ? AnyShapeStyle(LinearGradient(
                                            colors: [.maxxCyan, .maxxGold],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        : AnyShapeStyle(Color.clear),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: isSelectedA ? .maxxPrimary.opacity(0.6) : isSelectedB ? .maxxCyan.opacity(0.6) : .clear, radius: 8)
                    .overlay(alignment: .topTrailing) {
                        if isSelectedA {
                            Text("A")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        } else if isSelectedB {
                            Text("B")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.black)
                                .padding(5)
                                .background(
                                    LinearGradient(
                                        colors: [.maxxCyan, .maxxGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
            }
        }
    }

    private func selectPhoto(_ photo: ProgressPhoto) {
        HapticService.selection()
        if photoA == nil {
            photoA = photo
        } else if photoB == nil && photo.id != photoA?.id {
            photoB = photo
        } else {
            photoA = photo
            photoB = nil
        }
    }
}
