import SwiftUI
import SwiftData
import PhotosUI

struct ProgressGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProgressPhoto.capturedAt, order: .reverse) private var photos: [ProgressPhoto]
    @State private var viewModel = ProgressViewModel()
    @State private var gamificationVM: GamificationViewModel?
    @State private var showAddSheet = false

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
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
            .background(Color.maxxBackground)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            PhotoCompareView(photos: photos)
                        } label: {
                            Image(systemName: "rectangle.on.rectangle")
                                .foregroundColor(.maxxPrimary)
                        }

                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.maxxPrimary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPhotoSheet(viewModel: viewModel, gamificationVM: gamificationVM)
            }
            .onAppear {
                if gamificationVM == nil {
                    gamificationVM = GamificationViewModel(modelContext: modelContext)
                }
            }
            .sheet(item: $viewModel.selectedPhoto) { photo in
                PhotoDetailSheet(photo: photo, viewModel: viewModel)
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(GlowUpCategory.allCases) { category in
                    filterChip(
                        label: category.rawValue,
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
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .maxxTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.maxxPrimary : Color.maxxSurface)
                .clipShape(Capsule())
        }
    }

    // MARK: - Photo Grid

    private func photoGrid(_ filteredPhotos: [ProgressPhoto]) -> some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(filteredPhotos) { photo in
                Button {
                    viewModel.selectedPhoto = photo
                } label: {
                    photoThumbnail(photo)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func photoThumbnail(_ photo: ProgressPhoto) -> some View {
        Group {
            if let thumbnailData = photo.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } else if let uiImage = UIImage(data: photo.imageData) {
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
                    .padding(6)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text(photo.capturedAt.shortFormatted)
                .font(.system(size: 8))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.black.opacity(0.5))
                .clipShape(Capsule())
                .padding(4)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.maxxTextMuted)

            Text("No progress photos yet")
                .font(.headline)
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
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.maxxGradient)
                    .clipShape(Capsule())
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
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.maxxPrimary)

                                Text("Select a Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.maxxTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color.maxxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }

                    // Category picker
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
                                        Text(category.rawValue)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(selectedCategory == category ? .white : .maxxTextSecondary)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? Color.categoryColor(for: category) : Color.maxxSurface)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    // Angle picker
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
                                        Text(angle.rawValue)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(selectedAngle == angle ? .white : .maxxTextSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedAngle == angle ? Color.maxxPrimary : Color.maxxSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    }
                }
                .padding(20)
            }
            .background(Color.maxxBackground)
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
                    .fontWeight(.bold)
                    .foregroundColor(.maxxPrimary)
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
            ScrollView {
                VStack(spacing: 20) {
                    if let uiImage = UIImage(data: photo.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    HStack {
                        if let category = photo.parsedCategory {
                            Label(category.rawValue, systemImage: category.icon)
                                .font(.caption)
                                .foregroundColor(Color.categoryColor(for: category))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.categoryColor(for: category).opacity(0.15))
                                .clipShape(Capsule())
                        }

                        if let angle = photo.angle {
                            Label(angle.rawValue, systemImage: angle.icon)
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
            .background(Color.maxxBackground)
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
