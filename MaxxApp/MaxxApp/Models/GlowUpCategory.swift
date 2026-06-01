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

    /// Localized, user-facing name. `rawValue` stays the stable persisted key.
    var displayName: String {
        switch self {
        case .skin:          String(localized: "category.skin", defaultValue: "Skin")
        case .hair:          String(localized: "category.hair", defaultValue: "Hair")
        case .fitness:       String(localized: "category.fitness", defaultValue: "Fitness")
        case .faceStructure: String(localized: "category.faceStructure", defaultValue: "Face Structure")
        case .style:         String(localized: "category.style", defaultValue: "Style")
        case .grooming:      String(localized: "category.grooming", defaultValue: "Grooming")
        case .posture:       String(localized: "category.posture", defaultValue: "Posture")
        case .teeth:         String(localized: "category.teeth", defaultValue: "Teeth")
        }
    }

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
            [String(localized: "tip.skin.1", defaultValue: "Cleanse twice daily"),
             String(localized: "tip.skin.2", defaultValue: "Apply SPF 30+ every morning"),
             String(localized: "tip.skin.3", defaultValue: "Use retinol at night"),
             String(localized: "tip.skin.4", defaultValue: "Stay hydrated — 8 glasses/day")]
        case .hair:
            [String(localized: "tip.hair.1", defaultValue: "Use sulfate-free shampoo"),
             String(localized: "tip.hair.2", defaultValue: "Condition every wash"),
             String(localized: "tip.hair.3", defaultValue: "Get trims every 6-8 weeks"),
             String(localized: "tip.hair.4", defaultValue: "Minimize heat styling")]
        case .fitness:
            [String(localized: "tip.fitness.1", defaultValue: "Lift weights 4x/week"),
             String(localized: "tip.fitness.2", defaultValue: "Hit 10k steps daily"),
             String(localized: "tip.fitness.3", defaultValue: "Prioritize protein intake"),
             String(localized: "tip.fitness.4", defaultValue: "Sleep 7-9 hours")]
        case .faceStructure:
            [String(localized: "tip.face.1", defaultValue: "Practice mewing daily"),
             String(localized: "tip.face.2", defaultValue: "Do jaw exercises"),
             String(localized: "tip.face.3", defaultValue: "Chew mastic gum"),
             String(localized: "tip.face.4", defaultValue: "Maintain proper tongue posture")]
        case .style:
            [String(localized: "tip.style.1", defaultValue: "Build a capsule wardrobe"),
             String(localized: "tip.style.2", defaultValue: "Learn your color season"),
             String(localized: "tip.style.3", defaultValue: "Invest in tailoring"),
             String(localized: "tip.style.4", defaultValue: "Accessorize intentionally")]
        case .grooming:
            [String(localized: "tip.grooming.1", defaultValue: "Maintain brow shape"),
             String(localized: "tip.grooming.2", defaultValue: "Keep nails clean"),
             String(localized: "tip.grooming.3", defaultValue: "Find your signature scent"),
             String(localized: "tip.grooming.4", defaultValue: "Develop a morning routine")]
        case .posture:
            [String(localized: "tip.posture.1", defaultValue: "Stretch hip flexors daily"),
             String(localized: "tip.posture.2", defaultValue: "Strengthen rear delts"),
             String(localized: "tip.posture.3", defaultValue: "Use standing desk"),
             String(localized: "tip.posture.4", defaultValue: "Practice chin tucks")]
        case .teeth:
            [String(localized: "tip.teeth.1", defaultValue: "Brush twice daily"),
             String(localized: "tip.teeth.2", defaultValue: "Floss every night"),
             String(localized: "tip.teeth.3", defaultValue: "Use whitening strips"),
             String(localized: "tip.teeth.4", defaultValue: "See dentist every 6 months")]
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"

    var displayName: String {
        switch self {
        case .male:           String(localized: "gender.male", defaultValue: "Male")
        case .female:         String(localized: "gender.female", defaultValue: "Female")
        case .nonBinary:      String(localized: "gender.nonBinary", defaultValue: "Non-binary")
        case .preferNotToSay: String(localized: "gender.preferNotToSay", defaultValue: "Prefer not to say")
        }
    }

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

    var displayName: String {
        switch self {
        case .totalTransformation: String(localized: "goal.totalTransformation.title", defaultValue: "Total Transformation")
        case .subtleEnhancements:  String(localized: "goal.subtleEnhancements.title", defaultValue: "Subtle Enhancements")
        case .maintenanceMode:     String(localized: "goal.maintenanceMode.title", defaultValue: "Maintenance Mode")
        case .specificArea:        String(localized: "goal.specificArea.title", defaultValue: "Fix Specific Area")
        case .buildConfidence:     String(localized: "goal.buildConfidence.title", defaultValue: "Build Confidence")
        }
    }

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
        case .totalTransformation: String(localized: "goal.totalTransformation.subtitle", defaultValue: "Complete glow-up across all areas")
        case .subtleEnhancements:  String(localized: "goal.subtleEnhancements.subtitle", defaultValue: "Small tweaks for big impact")
        case .maintenanceMode:     String(localized: "goal.maintenanceMode.subtitle", defaultValue: "Keep your current look sharp")
        case .specificArea:        String(localized: "goal.specificArea.subtitle", defaultValue: "Focus on one thing at a time")
        case .buildConfidence:     String(localized: "goal.buildConfidence.subtitle", defaultValue: "Look good, feel unstoppable")
        }
    }
}

enum CommitmentLevel: String, Codable, CaseIterable {
    case casual = "Casual"
    case consistent = "Consistent"
    case dedicated = "Dedicated"
    case obsessed = "Obsessed"

    var displayName: String {
        switch self {
        case .casual:     String(localized: "commitment.casual", defaultValue: "Casual")
        case .consistent: String(localized: "commitment.consistent", defaultValue: "Consistent")
        case .dedicated:  String(localized: "commitment.dedicated", defaultValue: "Dedicated")
        case .obsessed:   String(localized: "commitment.obsessed", defaultValue: "Obsessed")
        }
    }

    var minutesPerDay: String {
        switch self {
        case .casual:     String(localized: "commitment.casual.minutes", defaultValue: "5-10 min/day")
        case .consistent: String(localized: "commitment.consistent.minutes", defaultValue: "15-30 min/day")
        case .dedicated:  String(localized: "commitment.dedicated.minutes", defaultValue: "30-60 min/day")
        case .obsessed:   String(localized: "commitment.obsessed.minutes", defaultValue: "60+ min/day")
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
