import Foundation
import SwiftData

@Model
final class ProgressPhoto {
    var id: UUID
    var imageData: Data
    var thumbnailData: Data?
    var category: String
    var note: String
    var capturedAt: Date
    var isFavorite: Bool
    var angleTag: String?

    init(
        imageData: Data,
        thumbnailData: Data? = nil,
        category: String,
        note: String = "",
        angleTag: String? = nil
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.category = category
        self.note = note
        self.capturedAt = .now
        self.isFavorite = false
        self.angleTag = angleTag
    }

    var parsedCategory: GlowUpCategory? {
        GlowUpCategory(rawValue: category)
    }

    var angle: PhotoAngle? {
        guard let angleTag else { return nil }
        return PhotoAngle(rawValue: angleTag)
    }
}

enum PhotoAngle: String, Codable, CaseIterable {
    case front = "Front"
    case side = "Side"
    case threeQuarter = "3/4"
    case profile = "Profile"

    var displayName: String {
        switch self {
        case .front:        String(localized: "angle.front", defaultValue: "Front")
        case .side:         String(localized: "angle.side", defaultValue: "Side")
        case .threeQuarter: String(localized: "angle.threeQuarter", defaultValue: "3/4")
        case .profile:      String(localized: "angle.profile", defaultValue: "Profile")
        }
    }

    var icon: String {
        switch self {
        case .front: "person.fill"
        case .side: "person.fill.turn.right"
        case .threeQuarter: "person.fill.turn.down.left"
        case .profile: "person.crop.circle"
        }
    }
}
