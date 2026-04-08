import Foundation

enum GlowUpCategory: String, Codable, CaseIterable, Identifiable {
    case skin = "Skin"
    case hair = "Hair"
    case fitness = "Fitness"
    case faceStructure = "Face Structure"
    case style = "Style"
    case grooming = "Grooming"
    case posture = "Posture"
    case teeth = "Teeth"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .skin: "drop.fill"
        case .hair: "comb.fill"
        case .fitness: "dumbbell.fill"
        case .faceStructure: "face.smiling.inverse"
        case .style: "tshirt.fill"
        case .grooming: "scissors"
        case .posture: "figure.stand"
        case .teeth: "mouth.fill"
        }
    }

    var color: String {
        switch self {
        case .skin: "SkinColor"
        case .hair: "HairColor"
        case .fitness: "FitnessColor"
        case .faceStructure: "FaceColor"
        case .style: "StyleColor"
        case .grooming: "GroomingColor"
        case .posture: "PostureColor"
        case .teeth: "TeethColor"
        }
    }

    var tips: [String] {
        switch self {
        case .skin:
            ["Cleanse twice daily", "Apply SPF 30+ every morning", "Use retinol at night", "Stay hydrated — 8 glasses/day"]
        case .hair:
            ["Use sulfate-free shampoo", "Condition every wash", "Get trims every 6-8 weeks", "Minimize heat styling"]
        case .fitness:
            ["Lift weights 4x/week", "Hit 10k steps daily", "Prioritize protein intake", "Sleep 7-9 hours"]
        case .faceStructure:
            ["Practice mewing daily", "Do jaw exercises", "Chew mastic gum", "Maintain proper tongue posture"]
        case .style:
            ["Build a capsule wardrobe", "Learn your color season", "Invest in tailoring", "Accessorize intentionally"]
        case .grooming:
            ["Maintain brow shape", "Keep nails clean", "Find your signature scent", "Develop a morning routine"]
        case .posture:
            ["Stretch hip flexors daily", "Strengthen rear delts", "Use standing desk", "Practice chin tucks"]
        case .teeth:
            ["Brush twice daily", "Floss every night", "Use whitening strips", "See dentist every 6 months"]
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"

    var icon: String {
        switch self {
        case .male: "figure.stand"
        case .female: "figure.stand.dress"
        case .nonBinary: "figure.2"
        case .preferNotToSay: "person.fill.questionmark"
        }
    }
}

enum GlowUpGoal: String, Codable, CaseIterable, Identifiable {
    case totalTransformation = "Total Transformation"
    case subtleEnhancements = "Subtle Enhancements"
    case maintenanceMode = "Maintenance Mode"
    case specificArea = "Fix Specific Area"
    case buildConfidence = "Build Confidence"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .totalTransformation: "sparkles"
        case .subtleEnhancements: "wand.and.stars"
        case .maintenanceMode: "checkmark.shield.fill"
        case .specificArea: "scope"
        case .buildConfidence: "star.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .totalTransformation: "Complete glow-up across all areas"
        case .subtleEnhancements: "Small tweaks for big impact"
        case .maintenanceMode: "Keep your current look sharp"
        case .specificArea: "Focus on one thing at a time"
        case .buildConfidence: "Look good, feel unstoppable"
        }
    }
}

enum CommitmentLevel: String, Codable, CaseIterable {
    case casual = "Casual"
    case consistent = "Consistent"
    case dedicated = "Dedicated"
    case obsessed = "Obsessed"

    var minutesPerDay: String {
        switch self {
        case .casual: "5-10 min/day"
        case .consistent: "15-30 min/day"
        case .dedicated: "30-60 min/day"
        case .obsessed: "60+ min/day"
        }
    }

    var icon: String {
        switch self {
        case .casual: "hare.fill"
        case .consistent: "figure.walk"
        case .dedicated: "flame.fill"
        case .obsessed: "bolt.fill"
        }
    }
}
