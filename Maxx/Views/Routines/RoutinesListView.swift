import SwiftUI
import SwiftData

struct RoutinesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.sortOrder) private var routines: [Routine]
    @State private var viewModel = RoutineViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Today's progress
                    todayProgressSection

                    // Category filter
                    categoryFilter

                    // Routines list
                    routinesList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .background(Color.maxxBackground)
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showAddRoutine = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.maxxPrimary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddRoutine) {
                AddRoutineSheet(viewModel: viewModel)
            }
        }
    }

    // MARK: - Today's Progress

    private var todayProgressSection: some View {
        let total = viewModel.totalTodayCount(routines)
        let completed = viewModel.completedTodayCount(routines)
        let percentage = total > 0 ? Double(completed) / Double(total) : 0

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(completed) of \(total) completed")
                        .font(.subheadline)
                        .foregroundColor(.maxxTextSecondary)
                }

                Spacer()

                Text("\(Int(percentage * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.maxxPrimary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.maxxSurfaceLight)
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.maxxGradient)
                        .frame(width: geo.size.width * percentage, height: 8)
                        .animation(.spring(response: 0.5), value: percentage)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .maxxCard()
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }

                ForEach(GlowUpCategory.allCases) { category in
                    filterChip(
                        label: category.rawValue,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .maxxTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.maxxPrimary : Color.maxxSurface)
                .clipShape(Capsule())
        }
    }

    // MARK: - Routines List

    private var routinesList: some View {
        let filtered = viewModel.routinesForCategory(viewModel.selectedCategory, allRoutines: routines)

        return VStack(spacing: 12) {
            ForEach(filtered) { routine in
                RoutineCardView(routine: routine) {
                    viewModel.toggleRoutineCompletion(routine, modelContext: modelContext)
                } onDelete: {
                    viewModel.deleteRoutine(routine, modelContext: modelContext)
                }
            }
        }
    }
}

// MARK: - Routine Card

struct RoutineCardView: View {
    let routine: Routine
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    onToggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(routine.isCompletedToday ? Color.maxxSuccess : Color.maxxSurfaceLight)
                        .frame(width: 44, height: 44)

                    Image(systemName: routine.isCompletedToday ? "checkmark" : routine.icon)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(routine.isCompletedToday ? .maxxTextSecondary : .white)
                    .strikethrough(routine.isCompletedToday)

                HStack(spacing: 8) {
                    if let category = routine.parsedCategory {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.categoryColor(for: category))
                                .frame(width: 6, height: 6)
                            Text(category.rawValue)
                                .font(.caption2)
                                .foregroundColor(.maxxTextSecondary)
                        }
                    }

                    Text("\(routine.durationMinutes) min")
                        .font(.caption2)
                        .foregroundColor(.maxxTextMuted)

                    if routine.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                            Text("\(routine.currentStreak)")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.maxxAccent)
                    }
                }
            }

            Spacer()

            if !routine.routineDescription.isEmpty {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.maxxTextMuted)
            }
        }
        .padding(16)
        .maxxCard()
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Routine Sheet

struct AddRoutineSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let viewModel: RoutineViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var category: GlowUpCategory = .skin
    @State private var duration = 10
    @State private var selectedDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Routine Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        TextField("e.g., Morning Skincare", text: $name)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Color.maxxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        TextField("What does this involve?", text: $description, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Color.maxxSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(GlowUpCategory.allCases) { cat in
                                    Button {
                                        category = cat
                                    } label: {
                                        Label(cat.rawValue, systemImage: cat.icon)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(category == cat ? .white : .maxxTextSecondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(category == cat ? Color.categoryColor(for: cat) : Color.maxxSurface)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Duration")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Spacer()

                            Text("\(duration) min")
                                .font(.subheadline)
                                .foregroundColor(.maxxPrimary)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(duration) },
                                set: { duration = Int($0) }
                            ),
                            in: 1...120,
                            step: 1
                        )
                        .tint(.maxxPrimary)
                    }

                    // Days of week
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active Days")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            ForEach(Array(zip(RoutineViewModel.dayValues, RoutineViewModel.dayNames)), id: \.0) { value, name in
                                Button {
                                    if selectedDays.contains(value) {
                                        selectedDays.remove(value)
                                    } else {
                                        selectedDays.insert(value)
                                    }
                                } label: {
                                    Text(String(name.prefix(1)))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(selectedDays.contains(value) ? Color.maxxPrimary : Color.maxxSurfaceLight)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.maxxBackground)
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.maxxTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addRoutine()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.maxxPrimary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func addRoutine() {
        viewModel.newRoutineName = name
        viewModel.newRoutineDescription = description
        viewModel.newRoutineCategory = category
        viewModel.newRoutineDuration = duration
        viewModel.newRoutineDays = selectedDays
        viewModel.addRoutine(modelContext: modelContext)
        dismiss()
    }
}
