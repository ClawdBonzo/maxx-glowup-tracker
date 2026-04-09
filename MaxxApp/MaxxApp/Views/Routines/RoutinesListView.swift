import SwiftUI
import SwiftData

struct RoutinesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.sortOrder) private var routines: [Routine]
    @State private var viewModel = RoutineViewModel()
    @State private var gamificationVM: GamificationViewModel?
    @State private var completionFlash: UUID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                NeonScreenBackground(particleCount: 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        todayProgressSection
                        categoryFilter
                        routinesList
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Routines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showAddRoutine = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.maxxPrimary.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .neonGlow(color: .maxxPrimary, radius: 8)
                            Image(systemName: "plus")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.maxxPrimary, .maxxCyan],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddRoutine) {
                AddRoutineSheet(viewModel: viewModel)
            }
            .onAppear {
                if gamificationVM == nil {
                    gamificationVM = GamificationViewModel(modelContext: modelContext)
                }
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
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(completed) of \(total) completed")
                        .font(.subheadline)
                        .foregroundColor(.maxxTextSecondary)
                }

                Spacer()

                Text("\(Int(percentage * 100))%")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .neonGlow(color: .maxxPrimary, radius: 8, intensity: 0.7)
            }

            // Neon progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.maxxSurfaceLight)
                        .frame(height: 10)

                    // Glow bloom
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * max(percentage, 0.03), height: 10)
                        .blur(radius: 8)
                        .opacity(0.65)

                    // Sharp bar
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.maxxPrimary, .maxxCyan, .maxxGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * max(percentage, 0.03), height: 10)
                        .animation(.spring(response: 0.5), value: percentage)
                }
            }
            .frame(height: 10)

            // Completion message
            if percentage >= 1.0 {
                HStack(spacing: 8) {
                    Text("🔥")
                    Text("ALL DONE! You're glowing today!")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxGold, .maxxCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.maxxGold.opacity(0.10))
                .clipShape(Capsule())
                .neonGlow(color: .maxxGold, radius: 8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .neonCard(cornerRadius: 20, glowColor: .maxxPrimary)
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
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .maxxTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        : AnyShapeStyle(Color.maxxSurface)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.maxxCyan.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: isSelected ? Color.maxxPrimary.opacity(0.4) : .clear, radius: 6)
        }
    }

    // MARK: - Routines List

    private var routinesList: some View {
        let filtered = viewModel.routinesForCategory(viewModel.selectedCategory, allRoutines: routines)

        return VStack(spacing: 12) {
            ForEach(filtered) { routine in
                RoutineCardView(
                    routine: routine,
                    gamificationVM: gamificationVM,
                    isFlashing: completionFlash == routine.id
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.toggleRoutineCompletion(routine, modelContext: modelContext)
                        if routine.isCompletedToday {
                            let xpReward = 25 + (routine.durationMinutes / 5)
                            gamificationVM?.addXP(xpReward, reason: "Routine: \(routine.name)")
                            // Flash animation
                            completionFlash = routine.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                completionFlash = nil
                            }
                        }
                    }
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
    let gamificationVM: GamificationViewModel?
    var isFlashing: Bool = false
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var checkScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                    checkScale = 1.4
                    onToggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        checkScale = 1.0
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            routine.isCompletedToday
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [.maxxPrimary, .maxxCyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color.maxxSurfaceLight)
                        )
                        .frame(width: 44, height: 44)
                        .neonGlow(
                            color: routine.isCompletedToday ? .maxxCyan : .clear,
                            radius: 10,
                            intensity: routine.isCompletedToday ? 0.8 : 0
                        )

                    Image(systemName: routine.isCompletedToday ? "checkmark" : routine.icon)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .scaleEffect(checkScale)
            }

            // Text
            VStack(alignment: .leading, spacing: 5) {
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
                                .neonGlow(color: Color.categoryColor(for: category), radius: 3)
                            Text(category.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
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
                                .neonGlow(color: .maxxAccent, radius: 4)
                            Text("\(routine.currentStreak)")
                                .font(.caption2)
                                .fontWeight(.black)
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.maxxAccent, .maxxGold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }

            Spacer()

            // XP badge when completed
            if routine.isCompletedToday {
                Text("+\(25 + routine.durationMinutes / 5) XP")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxGold, .maxxCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.maxxGold.opacity(0.12))
                    .clipShape(Capsule())
                    .neonGlow(color: .maxxGold, radius: 6, intensity: 0.7)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    routine.isCompletedToday
                        ? Color.maxxPrimary.opacity(0.08)
                        : Color.maxxSurface
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            routine.isCompletedToday
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [.maxxPrimary.opacity(0.7), .maxxCyan.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                : AnyShapeStyle(Color.white.opacity(0.06)),
                            lineWidth: routine.isCompletedToday ? 1.5 : 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: routine.isCompletedToday ? Color.maxxPrimary.opacity(0.20) : Color.black.opacity(0.2), radius: 10, y: 4)
        .overlay(
            // Completion flash
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.maxxCyan.opacity(isFlashing ? 0.15 : 0))
                .animation(.easeOut(duration: 0.4), value: isFlashing)
        )
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
            ZStack {
                NeonScreenBackground(particleCount: 8)
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Routine Name", systemImage: "pencil")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            TextField("e.g., Morning Skincare", text: $name)
                                .textFieldStyle(.plain)
                                .padding(14)
                                .background(Color.maxxSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.maxxPrimary.opacity(0.3), lineWidth: 1)
                                )
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.maxxPrimary.opacity(0.2), lineWidth: 1)
                                )
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
                                                .background(
                                                    category == cat
                                                        ? AnyShapeStyle(LinearGradient(
                                                            colors: [
                                                                Color.categoryColor(for: cat),
                                                                Color.categoryColor(for: cat).opacity(0.7),
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ))
                                                        : AnyShapeStyle(Color.maxxSurface)
                                                )
                                                .clipShape(Capsule())
                                                .neonGlow(
                                                    color: category == cat ? Color.categoryColor(for: cat) : .clear,
                                                    radius: 5,
                                                    intensity: 0.6
                                                )
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
                                    .fontWeight(.black)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.maxxPrimary, .maxxCyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            Slider(
                                value: Binding(get: { Double(duration) }, set: { duration = Int($0) }),
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
                                ForEach(Array(zip(RoutineViewModel.dayValues, RoutineViewModel.dayNames)), id: \.0) { value, dayName in
                                    Button {
                                        if selectedDays.contains(value) {
                                            selectedDays.remove(value)
                                        } else {
                                            selectedDays.insert(value)
                                        }
                                    } label: {
                                        Text(String(dayName.prefix(1)))
                                            .font(.caption)
                                            .fontWeight(.black)
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(
                                                selectedDays.contains(value)
                                                    ? AnyShapeStyle(LinearGradient(
                                                        colors: [.maxxPrimary, .maxxCyan],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ))
                                                    : AnyShapeStyle(Color.maxxSurfaceLight)
                                            )
                                            .clipShape(Circle())
                                            .neonGlow(color: selectedDays.contains(value) ? .maxxPrimary : .clear, radius: 6)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
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
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.maxxPrimary, .maxxCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
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
