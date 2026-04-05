import SwiftUI

struct StreakBadgeView: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .maxxCard()
    }
}
