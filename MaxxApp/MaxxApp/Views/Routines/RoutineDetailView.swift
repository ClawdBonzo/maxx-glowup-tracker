import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.categoryColor(for: routine.parsedCategory ?? .skin).opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: routine.icon)
                            .font(.title)
                            .foregroundColor(Color.categoryColor(for: routine.parsedCategory ?? .skin))
                    }

                    Text(routine.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let category = routine.parsedCategory {
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundColor(Color.categoryColor(for: category))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.categoryColor(for: category).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if !routine.routineDescription.isEmpty {
                    Text(routine.routineDescription)
                        .font(.body)
                        .foregroundColor(.maxxTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                // Stats
                HStack(spacing: 20) {
                    statItem(value: "\(routine.durationMinutes)", label: "Minutes", icon: "clock.fill")
                    statItem(value: "\(routine.currentStreak)", label: "Streak", icon: "flame.fill")
                    statItem(value: "\(routine.completedDates.count)", label: "Total", icon: "checkmark.seal.fill")
                }
                .padding(20)
                .maxxCard()

                // Active days
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Days")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        ForEach(Array(zip(RoutineViewModel.dayValues, RoutineViewModel.dayNames)), id: \.0) { value, name in
                            Text(String(name.prefix(1)))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(
                                    routine.daysOfWeek.contains(value)
                                    ? Color.maxxPrimary
                                    : Color.maxxSurfaceLight
                                )
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .maxxCard()

                // Tips
                if let category = routine.parsedCategory {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tips")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(category.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption)
                                    .foregroundColor(.maxxGold)

                                Text(tip)
                                    .font(.subheadline)
                                    .foregroundColor(.maxxTextSecondary)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .maxxCard()
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .background(Color.maxxBackground)
        .navigationTitle("Routine Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statItem(value: String, label: LocalizedStringKey, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.maxxPrimary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
