import SwiftUI

struct PhotoCompareView: View {
    let photos: [ProgressPhoto]
    @State private var photoA: ProgressPhoto?
    @State private var photoB: ProgressPhoto?
    @State private var sliderPosition: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 20) {
            if let a = photoA, let b = photoB {
                // Comparison view
                GeometryReader { geo in
                    ZStack {
                        // Photo B (full width behind)
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

                        // Slider line
                        Rectangle()
                            .fill(.white)
                            .frame(width: 3)
                            .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)
                            .shadow(radius: 4)

                        // Drag handle
                        Circle()
                            .fill(.white)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "arrow.left.and.right")
                                    .font(.caption)
                                    .foregroundColor(.maxxBackground)
                            )
                            .shadow(radius: 4)
                            .position(x: geo.size.width * sliderPosition, y: geo.size.height / 2)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        sliderPosition = max(0.05, min(0.95, value.location.x / geo.size.width))
                                    }
                            )

                        // Date labels
                        VStack {
                            HStack {
                                Text(a.capturedAt.shortFormatted)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.6))
                                    .clipShape(Capsule())

                                Spacer()

                                Text(b.capturedAt.shortFormatted)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.black.opacity(0.6))
                                    .clipShape(Capsule())
                            }
                            .padding(12)

                            Spacer()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .frame(maxHeight: 400)
            } else {
                // Selection prompt
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.on.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.maxxTextMuted)

                    Text("Select two photos to compare")
                        .font(.headline)
                        .foregroundColor(.maxxTextSecondary)
                }
                .frame(height: 300)
            }

            // Photo selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Photos")
                    .font(.headline)
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
        .background(Color.maxxBackground)
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
                                isSelectedA ? Color.maxxPrimary :
                                    isSelectedB ? Color.maxxAccent :
                                    Color.clear,
                                lineWidth: 3
                            )
                    )
                    .overlay(alignment: .topTrailing) {
                        if isSelectedA {
                            Text("A")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.maxxPrimary)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        } else if isSelectedB {
                            Text("B")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.maxxAccent)
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
