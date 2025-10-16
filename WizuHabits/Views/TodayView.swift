import SwiftUI

struct TodayView: View {
    @StateObject private var store = TaskStore()
    @State private var newTask: String = ""
    @State private var startTime: Date = Date()
    @State private var deadline: Date = Date().addingTimeInterval(3600)

    @State private var showAlert = false
    @State private var alertMessage = ""

    // Edit state
    @State private var selectedTask: HabitTask? = nil

    // Progress for ONLY today's tasks
    private var progress: Double {
        guard !todaysTasks.isEmpty else { return 0 }
        let completed = todaysTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(todaysTasks.count)
    }

    // Today’s tasks only
    private var todaysTasks: [HabitTask] {
        let calendar = Calendar.current
        return store.tasks.filter { task in
            calendar.isDate(task.startTime, inSameDayAs: Date())
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 🟦 Input section
                VStack(spacing: 10) {
                    TextField("Enter Task...", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    DatePicker("Start time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal)

                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                        .padding(.horizontal)

                    Button("Add Task") {
                        if validateTask() {
                            let task = HabitTask(name: newTask, startTime: startTime, deadline: deadline)
                            store.addTask(task)
                            NotificationService.shared.scheduleStartReminder(for: task)
                            NotificationService.shared.scheduleLazyNudge(for: task)
                            resetInputs()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .padding(.top, 4)
                }
                .padding(.top, 10)

                // 🟣 Progress bar
                VStack(alignment: .leading) {
                    Text("Today's Progress: \(Int(progress * 100))%")
                        .font(.subheadline)
                        .padding(.horizontal)

                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                }

                // 🟢 Task list
                VStack(spacing: 10) {
                    ForEach(todaysTasks) { task in
                        taskRow(task)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Today")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Task"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(item: $selectedTask) { task in
            if let index = store.tasks.firstIndex(where: { $0.id == task.id }) {
                EditTaskView(task: $store.tasks[index]) { updated in
                    store.tasks[index] = updated
                    NotificationService.shared.reschedule(for: updated)
                    NotificationService.shared.scheduleLazyNudge(for: updated)
                }
            } else {
                VStack(spacing: 12) {
                    Text("Task not found")
                        .font(.headline)
                    Button("Close") { selectedTask = nil }
                }
                .padding()
            }
        }
    }

    // MARK: - Reusable task row

    @ViewBuilder
    private func taskRow(_ task: HabitTask) -> some View {
        HStack(alignment: .top) {
            // Completion toggle
            Button(action: {
                store.toggleCompletion(for: task)
                if task.isCompleted {
                    NotificationService.shared.cancelReminder(for: task.id)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }

            // Task details
            VStack(alignment: .leading, spacing: 6) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .black)

                HStack(spacing: 12) {
                    Label(task.startTime.formatted(date: .omitted, time: .shortened),
                          systemImage: "play.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(Color.indigo.opacity(0.15)))

                    Label(task.deadline.formatted(date: .omitted, time: .shortened),
                          systemImage: "flag.checkered")
                        .font(.subheadline.weight(.medium))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(Color.purple.opacity(0.15)))
                }
                .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Options menu (Edit / Delete)
            Menu {
                Button("Edit", systemImage: "pencil") {
                    selectedTask = task
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    deleteByID(task)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.leading, 6)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Deletion helpers

    private func deleteByID(_ task: HabitTask) {
        NotificationService.shared.cancelReminder(for: task.id)
        if let idx = store.tasks.firstIndex(where: { $0.id == task.id }) {
            store.deleteTask(at: IndexSet(integer: idx))
        }
    }

    // MARK: - Validation & reset

    private func validateTask() -> Bool {
        let task = HabitTask(name: newTask, startTime: startTime, deadline: deadline)
        let result = TaskValidator.validate(task)
        if !result.isValid {
            alertMessage = result.message ?? "Invalid task."
            showAlert = true
            return false
        }
        return true
    }

    private func resetInputs() {
        newTask = ""
        startTime = Date()
        deadline = Date().addingTimeInterval(3600)
    }
}

#Preview {
    ContentView()
}
