import SwiftUI
import Combine

class TaskStore: ObservableObject {
    @Published var tasks: [HabitTask] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadTasks()

        // Listen for "Mark as Begun" notifications
        NotificationCenter.default.addObserver(
            forName: NotificationService.Names.markBegun,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self = self,
                  let id = note.userInfo?["taskID"] as? UUID,
                  let idx = self.tasks.firstIndex(where: { $0.id == id }) else { return }
            self.tasks[idx].isBegun = true
            self.saveTasks()
        }

        // Automatically save only when tasks array changes meaningfully (debounced)
        $tasks
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.saveTasks() }
            .store(in: &cancellables)
    }

    // MARK: - CRUD

    func addTask(_ task: HabitTask) {
        tasks.append(task)
        saveTasks()
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    func markBegun(id: UUID) {
        if let idx = tasks.firstIndex(where: { $0.id == id }) {
            tasks[idx].isBegun = true
            saveTasks()
        }
    }

    func toggleCompletion(for task: HabitTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }

    // MARK: - Persistence

    private func saveTasks() {
        do {
            let encoded = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(encoded, forKey: "tasks")
        } catch {
            print("⚠️ Failed to save tasks:", error)
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([HabitTask].self, from: data) {
            tasks = decoded
        }
    }
}
