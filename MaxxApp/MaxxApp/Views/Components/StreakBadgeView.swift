import SwiftUI

struct StreakBadgeView: View {
    let count: Int
    let label: LocalizedStringKey
    let icon: String
    let color: Color

    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(
                    color: color.opacity(contrast == .increased ? 0 : 0.7),
                    radius: 8
                )
                .accessibilityHidden(true)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .minimumScaleFactor(typeSize >= .accessibility1 ? 0.6 : 1.0)

            Text(label)
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .maxxCard()
        // Single accessibility element combining all child values
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label) + Text(": \(count)"))
    }
}
