import SwiftUI
import SwiftData
import Charts

struct AnalyticsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \Routine.sortOrder) private var routines: [Routine]
    // Only the count is needed here — fetch it instead of loading every full-res photo blob.
    @State private var photoCount: Int = 0
    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case threeMonths = "90D"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    timeRangeSelector
                    glowScoreChart
                    moodTrendChart
                    categoryBreakdown
                    statsGrid
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.maxxBackground)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .task {
                photoCount = (try? modelContext.fetchCount(FetchDescriptor<ProgressPhoto>())) ?? 0
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.maxxPrimary)
                }
            }
        }
    }

    // MARK: - Time Range

    private var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTimeRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTimeRange == range ? .white : .maxxTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTimeRange == range ? Color.maxxPrimary : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color.maxxSurface)
        .clipShape(Capsule())
    }

    // MARK: - Glow Score Chart

    private var filteredLogs: [DailyLog] {
        let days: Int
        switch selectedTimeRange {
        case .week: days = 7
        case .month: days = 30
        case .threeMonths: days = 90
        }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        return logs.filter { $0.date >= cutoff }.reversed()
    }

    private var glowScoreChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Glow Score Trend")
                .font(.headline)
                .foregroundColor(.white)

            if filteredLogs.isEmpty {
                Text("Check in daily to see trends")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextMuted)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(filteredLogs) { log in
                    LineMark(
                        x: .value("Date", log.date),
                        y: .value("Score", log.calculateGlowScore(totalRoutines: routines.count))
                    )
                    .foregroundStyle(Color.maxxPrimary)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", log.date),
                        y: .value("Score", log.calculateGlowScore(totalRoutines: routines.count))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.maxxPrimary.opacity(0.3), Color.maxxPrimary.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.maxxTextMuted)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.maxxTextMuted)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(20)
        .maxxCard()
    }

    // MARK: - Mood Trend

    private var moodTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood & Confidence")
                .font(.headline)
                .foregroundColor(.white)

            if filteredLogs.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundColor(.maxxTextMuted)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(filteredLogs) { log in
                        LineMark(
                            x: .value("Date", log.date),
                            y: .value("Mood", log.overallMood),
                            series: .value("Type", "Mood")
                        )
                        .foregroundStyle(Color.maxxAccent)

                        LineMark(
                            x: .value("Date", log.date),
                            y: .value("Confidence", log.confidenceRating),
                            series: .value("Type", "Confidence")
                        )
                        .foregroundStyle(Color.maxxGold)
                    }
                }
                .chartYScale(domain: 1...5)
                .chartForegroundStyleScale([
                    "Mood": Color.maxxAccent,
                    "Confidence": Color.maxxGold,
                ])
                .frame(height: 150)
            }
        }
        .padding(20)
        .maxxCard()
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Focus")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(GlowUpCategory.allCases) { category in
                let count = routines.filter { $0.category == category.rawValue && $0.isActive }.count
                let totalCompleted = routines
                    .filter { $0.category == category.rawValue }
                    .reduce(0) { $0 + $1.completedDates.count }

                if count > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundColor(Color.categoryColor(for: category))
                            .frame(width: 24)

                        Text(category.displayName)
                            .font(.subheadline)
                            .foregroundColor(.white)

                        Spacer()

                        Text("\(count) routines")
                            .font(.caption)
                            .foregroundColor(.maxxTextSecondary)

                        Text("\(totalCompleted) done")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.categoryColor(for: category))
                    }
                }
            }
        }
        .padding(20)
        .maxxCard()
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 14) {
            statCard(
                title: "Total Photos",
                value: "\(photoCount)",
                icon: "camera.fill",
                color: .maxxPrimary
            )
            statCard(
                title: "Logs",
                value: "\(logs.count)",
                icon: "doc.text.fill",
                color: .maxxAccent
            )
            statCard(
                title: "Avg Mood",
                value: String(format: "%.1f", logs.isEmpty ? 0 : Double(logs.map(\.overallMood).reduce(0, +)) / Double(logs.count)),
                icon: "face.smiling",
                color: .maxxGold
            )
            statCard(
                title: "Active Routines",
                value: "\(routines.filter(\.isActive).count)",
                icon: "checkmark.circle.fill",
                color: .maxxSuccess
            )
        }
    }

    private func statCard(title: LocalizedStringKey, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.maxxTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .maxxCard()
    }
}
