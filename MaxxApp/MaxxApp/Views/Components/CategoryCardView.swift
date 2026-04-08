import SwiftUI

struct CategoryCardView: View {
    let category: GlowUpCategory
    let routineCount: Int
    let completedToday: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(Color.categoryColor(for: category))

                Spacer()

                if completedToday > 0 {
                    Text("\(completedToday)/\(routineCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color.categoryColor(for: category))
                }
            }

            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("\(routineCount) routine\(routineCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.maxxSurfaceLight)
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.categoryColor(for: category))
                        .frame(
                            width: routineCount > 0
                                ? geo.size.width * (Double(completedToday) / Double(routineCount))
                                : 0,
                            height: 4
                        )
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color.categoryColor(for: category).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.categoryColor(for: category).opacity(0.2), lineWidth: 1)
        )
    }
}
