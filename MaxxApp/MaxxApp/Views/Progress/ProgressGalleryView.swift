import SwiftUI
import SwiftData
import PhotosUI

struct ProgressGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subManager
    @Query(sort: \ProgressPhoto.capturedAt, order: .reverse) private var photos: [ProgressPhoto]
    @State private var viewModel = ProgressViewModel()
    @State private var showAddSheet = false
    @State private var showMirrorMode = false
    @State private var showPremiumGate = false
    @State private var premiumGateFeature: PremiumGateView.ProFeature = .photos

    /// Shared across all tabs — created in ContentView
    var gamificationVM: GamificationViewModel?

    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                NeonScreenBackground(particleCount: 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Mirror Mode banner
                        mirrorModeBanner

                        // Category filter
                        categoryFilter

                        // Photo grid
                        let filtered = viewModel.photosForCategory(viewModel.selectedCategory, allPhotos: photos)

                        if filtered.isEmpty {
                            emptyState
                        } else {
                            photoGrid(filtered)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button {
                            if subManager.isPremium {
                                viewModel.showCompare = true
                            } else {
                                premiumGateFeature = .photoCompare
                                showPremiumGate = true
                            }
                        } label: {
                            Image(systemName: "rectangle.on.rectangle")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        Button {
                            if !subManager.isPremium && photos.count >= FreeTierLimits.maxPhotos {
                                premiumGateFeature = .photos
                                showPremiumGate = true
                            } else {
                                showAddSheet = true
                            }
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPhotoSheet(viewModel: viewModel, gamificationVM: gamificationVM)
            }
            .fullScreenCover(isPresented: $showMirrorMode) {
                MirrorModeView()
            }
            .sheet(isPresented: $showPremiumGate) {
                PremiumGateView(feature: premiumGateFeature)
            }
            .navigationDestination(isPresented: $viewModel.showCompare) {
                PhotoCompareView(photos: photos)
            }
            .sheet(item: $viewModel.selectedPhoto) { photo in
                PhotoDetailSheet(photo: photo, viewModel: viewModel)
            }
        }
    }

    // MARK: - Mirror Mode Banner

    private var mirrorModeBanner: some View {
        Button {
            if subManager.isPremium {
                showMirrorMode = true
            } else {
                premiumGateFeature = .mirrorMode
                showPremiumGate = true
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.maxxPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .neonGlow(color: .maxxPrimary, radius: 8)

                    Image(systemName: "camera.filters")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxPrimary, .maxxCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Mirror Mode")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(.white)

                        Text(subManager.isPremium ? "NEW" : "PRO")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(subManager.isPremium ? Color.maxxGold : Color.maxxCyan)
                            .clipShape(Capsule())
                            .neonGlow(color: subManager.isPremium ? .maxxGold : .maxxCyan, radius: 4)
                    }

                    Text("Golden ratio grid • Real-time alignment")
                        .font(.caption)
                        .foregroundColor(.maxxTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.maxxTextMuted)
            }
            .padding(16)
            .neonCard(cornerRadius: 18, glowColor: .maxxPrimary)
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: String(localized: "filter.all", defaultValue: "All"), isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(GlowUpCategory.allCases) { category in
                    filterChip(
                        label: category.displayName,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .maxxTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        : AnyShapeStyle(Color.maxxSurface)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.maxxCyan.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.maxxPrimary.opacity(0.4) : .clear, radius: 6)
        }
    }

    // MARK: - Photo Grid

    private func photoGrid(_ filteredPhotos: [ProgressPhoto]) -> some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(filteredPhotos) { photo in
                Button {
                    viewModel.selectedPhoto = photo
                } label: {
                    photoThumbnail(photo)
                }
            }
        }
        .padding(.horizontal, 3)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.maxxPrimary.opacity(0.3), .maxxCyan.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 3)
    }

    private func photoThumbnail(_ photo: ProgressPhoto) -> some View {
        Group {
            // Decode once and cache (keyed by photo id) instead of re-decoding the JPEG
            // on every cell recycle / scroll pass on the main thread.
            if let uiImage = ThumbnailCache.shared.image(for: photo.id, data: photo.thumbnailData ?? photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.maxxSurface)
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.maxxTextMuted)
                    )
            }
        }
        .overlay(alignment: .bottomLeading) {
            if photo.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundColor(.maxxAccent)
                    .neonGlow(color: .maxxAccent, radius: 4)
                    .padding(6)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text(photo.capturedAt.shortFormatted)
                .font(.system(size: 8))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.black.opacity(0.55))
                .clipShape(Capsule())
                .padding(4)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.maxxPrimary.opacity(0.10))
                    .frame(width: 90, height: 90)
                    .neonGlow(color: .maxxPrimary, radius: 14)

                Image(systemName: "camera.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("No progress photos yet")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.maxxTextSecondary)

            Text("Take your first photo to start tracking your glow-up")
                .font(.subheadline)
                .foregroundColor(.maxxTextMuted)
                .multilineTextAlignment(.center)

            Button {
                showAddSheet = true
            } label: {
                Text("Add Photo")
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .neonGlow(color: .maxxPrimary, radius: 10)
            }
        }
        .padding(40)
    }
}

// MARK: - Add Photo Sheet

struct AddPhotoSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProgressViewModel
    let gamificationVM: GamificationViewModel?

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedCategory: GlowUpCategory = .skin
    @State private var note = ""
    @State private var selectedAngle: PhotoAngle = .front

    var body: some View {
        NavigationStack {
            ZStack {
                NeonScreenBackground(particleCount: 8)
                ScrollView {
                    VStack(spacing: 24) {
                        // Photo picker
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.maxxPrimary, .maxxCyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .neonGlow(color: .maxxPrimary, radius: 8)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 40))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.maxxPrimary, .maxxCyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .neonGlow(color: .maxxPrimary, radius: 10)

                                    Text("Select a Photo")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.maxxTextSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .neonCard(cornerRadius: 16, glowColor: .maxxPrimary)
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(GlowUpCategory.allCases) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            Text(category.displayName)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(selectedCategory == category ? .white : .maxxTextSecondary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedCategory == category
                                                        ? AnyShapeStyle(LinearGradient(
                                                            colors: [
                                                                Color.categoryColor(for: category),
                                                                Color.categoryColor(for: category).opacity(0.7),
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ))
                                                        : AnyShapeStyle(Color.maxxSurface)
                                                )
                                                .clipShape(Capsule())
                                                .neonGlow(
                                                    color: selectedCategory == category ? Color.categoryColor(for: category) : .clear,
                                                    radius: 5,
                                                    intensity: 0.6
                                                )
                                        }
                                    }
                                }
                            }
                        }

                        // Angle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Angle")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            HStack(spacing: 10) {
                                ForEach(PhotoAngle.allCases, id: \.self) { angle in
                                    Button {
                                        selectedAngle = angle
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: angle.icon)
                                            Text(angle.displayName)
                                                .font(.caption2)
                                        }
                                        .foregroundColor(selectedAngle == angle ? .white : .maxxTextSecondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedAngle == angle
                                                ? AnyShapeStyle(LinearGradient(
                                                    colors: [.maxxPrimary, .maxxCyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                : AnyShapeStyle(Color.maxxSurface)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .neonGlow(color: selectedAngle == angle ? .maxxPrimary : .clear, radius: 6)
                                    }
                                }
                            }
                        }

                        // Note
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note (optional)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            TextField("How are you feeling about your progress?", text: $note, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color.maxxSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.maxxPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Progress Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.maxxTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePhoto()
                    }
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(selectedImageData == nil)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func savePhoto() {
        guard let data = selectedImageData else { return }
        viewModel.newPhotoNote = note
        viewModel.selectedAngle = selectedAngle
        viewModel.savePhoto(imageData: data, category: selectedCategory, modelContext: modelContext, gamificationVM: gamificationVM)
        dismiss()
    }
}

// MARK: - Photo Detail Sheet

struct PhotoDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let photo: ProgressPhoto
    let viewModel: ProgressViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.maxxBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        if let uiImage = UIImage(data: photo.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.maxxPrimary.opacity(0.5), .maxxCyan.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                                .neonGlow(color: .maxxPrimary, radius: 10, intensity: 0.5)
                        }

                        HStack {
                            if let category = photo.parsedCategory {
                                Label(category.displayName, systemImage: category.icon)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.categoryColor(for: category))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.categoryColor(for: category).opacity(0.15))
                                    .clipShape(Capsule())
                            }

                            if let angle = photo.angle {
                                Label(angle.displayName, systemImage: angle.icon)
                                    .font(.caption)
                                    .foregroundColor(.maxxTextSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.maxxSurface)
                                    .clipShape(Capsule())
                            }

                            Spacer()

                            Text(photo.capturedAt.fullFormatted)
                                .font(.caption)
                                .foregroundColor(.maxxTextMuted)
                        }

                        if !photo.note.isEmpty {
                            Text(photo.note)
                                .font(.subheadline)
                                .foregroundColor(.maxxTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Photo Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.maxxTextMuted)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.toggleFavorite(photo, modelContext: modelContext)
                        } label: {
                            Image(systemName: photo.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(photo.isFavorite ? .maxxAccent : .maxxTextSecondary)
                                .neonGlow(color: photo.isFavorite ? .maxxAccent : .clear, radius: 6)
                        }

                        Button(role: .destructive) {
                            viewModel.deletePhoto(photo, modelContext: modelContext)
                            dismiss()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.maxxError)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
