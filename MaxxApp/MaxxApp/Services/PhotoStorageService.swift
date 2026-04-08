import SwiftUI
import PhotosUI

@MainActor
final class PhotoStorageService {
    static let shared = PhotoStorageService()

    private init() {}

    func compressImage(_ imageData: Data, maxSizeKB: Int = 500) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        var compression: CGFloat = 0.8
        var compressed = uiImage.jpegData(compressionQuality: compression)

        while let data = compressed, data.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            compressed = uiImage.jpegData(compressionQuality: compression)
        }

        return compressed
    }

    func generateThumbnail(_ imageData: Data, size: CGSize = CGSize(width: 200, height: 200)) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        let thumbnail = renderer.image { _ in
            uiImage.draw(in: CGRect(origin: .zero, size: size))
        }

        return thumbnail.jpegData(compressionQuality: 0.6)
    }

    func loadImage(from item: PhotosPickerItem) async -> Data? {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        return compressImage(data)
    }

    func imageFromData(_ data: Data) -> Image? {
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    func uiImageFromData(_ data: Data) -> UIImage? {
        UIImage(data: data)
    }
}
