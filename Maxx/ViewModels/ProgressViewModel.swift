import SwiftUI
import SwiftData
import PhotosUI

@Observable
@MainActor
final class ProgressViewModel {
    var selectedCategory: GlowUpCategory?
    var selectedPhotoItem: PhotosPickerItem?
    var showCamera = false
    var showPhotoPicker = false
    var showPhotoDetail = false
    var selectedPhoto: ProgressPhoto?
    var compareMode = false
    var comparePhotoA: ProgressPhoto?
    var comparePhotoB: ProgressPhoto?
    var newPhotoNote = ""
    var selectedAngle: PhotoAngle = .front

    func savePhoto(
        imageData: Data,
        category: GlowUpCategory,
        modelContext: ModelContext
    ) {
        let compressed = PhotoStorageService.shared.compressImage(imageData) ?? imageData
        let thumbnail = PhotoStorageService.shared.generateThumbnail(imageData)

        let photo = ProgressPhoto(
            imageData: compressed,
            thumbnailData: thumbnail,
            category: category.rawValue,
            note: newPhotoNote,
            angleTag: selectedAngle.rawValue
        )

        modelContext.insert(photo)
        try? modelContext.save()

        newPhotoNote = ""
        HapticService.success()
    }

    func deletePhoto(_ photo: ProgressPhoto, modelContext: ModelContext) {
        modelContext.delete(photo)
        try? modelContext.save()
        HapticService.impact(.medium)
    }

    func toggleFavorite(_ photo: ProgressPhoto, modelContext: ModelContext) {
        photo.isFavorite.toggle()
        try? modelContext.save()
        HapticService.selection()
    }

    func photosForCategory(_ category: GlowUpCategory?, allPhotos: [ProgressPhoto]) -> [ProgressPhoto] {
        guard let category else { return allPhotos }
        return allPhotos.filter { $0.category == category.rawValue }
    }

    func photosGroupedByMonth(_ photos: [ProgressPhoto]) -> [(String, [ProgressPhoto])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: photos) { photo in
            formatter.string(from: photo.capturedAt)
        }

        return grouped.sorted { pair1, pair2 in
            guard let date1 = pair1.value.first?.capturedAt,
                  let date2 = pair2.value.first?.capturedAt else { return false }
            return date1 > date2
        }
    }

    func processPickerItem() async -> Data? {
        guard let item = selectedPhotoItem else { return nil }
        return await PhotoStorageService.shared.loadImage(from: item)
    }
}
