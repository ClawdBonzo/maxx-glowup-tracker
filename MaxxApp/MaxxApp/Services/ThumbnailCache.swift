import UIKit

/// In-memory cache for decoded photo thumbnails.
///
/// Decoding `UIImage(data:)` in a SwiftUI view body re-decodes the JPEG on every
/// cell recycle / scroll pass — the main jank source in the gallery. This caches
/// the decoded `UIImage` keyed by the photo's stable id so each image decodes once.
@MainActor
final class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSUUID, UIImage>()

    private init() {
        cache.countLimit = 300
    }

    /// Returns a decoded thumbnail for the given photo id, decoding + caching on first access.
    /// Pass the thumbnail data (preferred) or full-image data as a fallback.
    func image(for id: UUID, data: Data?) -> UIImage? {
        let key = id as NSUUID
        if let cached = cache.object(forKey: key) { return cached }
        guard let data, let img = UIImage(data: data) else { return nil }
        cache.setObject(img, forKey: key)
        return img
    }

    func clear() {
        cache.removeAllObjects()
    }
}
