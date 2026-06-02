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

    func generateThumbnail(_ imageData: Data, size: CGSize = CGSize(width: 400, height: 400)) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }

        // Aspect-fill into a square so portraits aren't stretched, then downsample.
        let target = uiImage.aspectFilled(to: size)
        return target.jpegData(compressionQuality: 0.6)
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

private extension UIImage {
    /// Scale-and-crop (aspect fill) into a square/target size without distorting.
    func aspectFilled(to target: CGSize) -> UIImage {
        let scale = max(target.width / size.width, target.height / size.height)
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(
            x: (target.width - scaledSize.width) / 2,
            y: (target.height - scaledSize.height) / 2
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
}
