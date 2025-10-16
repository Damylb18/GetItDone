import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private override init() {}
    
    struct Names {
        static let markBegun = Notification.Name("Task.MarkBegun")
    }

    func configure() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        registerCategories()
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification auth error:", error)
            } else {
                print("Notifications granted:", granted)
            }
        }
    }

    private func registerCategories() {
        let begin = UNNotificationAction(identifier: "MARK_BEGUN", title: "Mark as Begun", options: [])
        let category = UNNotificationCategory(identifier: "TASK_START", actions: [begin], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Scheduling

    func scheduleStartReminder(for task: HabitTask) {
        guard task.startTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to start: \(task.name)"
        content.body = "Due \(task.deadline.formatted(date: .omitted, time: .shortened))"
        content.sound = .default
        content.categoryIdentifier = "TASK_START"
        content.userInfo = ["taskID": task.id.uuidString]

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleLazyNudge(for task: HabitTask) {
        guard task.startTime > Date() else { return }

        Task {
            // 🔹 Fetch AI-generated cheeky message
            let message = await generateCheekyNudge(for: task.name)

            let content = UNMutableNotificationContent()
            content.title = "Still not started? 😏"
            content.body = message
            content.sound = .default
            content.categoryIdentifier = "TASK_START"
            content.userInfo = ["taskID": task.id.uuidString, "type": "lazyNudge"]

            // Trigger 5 minutes after start time
            let triggerDate = task.startTime.addingTimeInterval(5 * 60)
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(task.id.uuidString)-lazyNudge",
                content: content,
                trigger: trigger
            )

            // ✅ Handle the throwable call
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("⚠️ Failed to schedule lazy nudge:", error)
            }
        }
    }

    func cancelReminder(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [
                taskID.uuidString,
                "\(taskID.uuidString)-lazyNudge"
            ]
        )
    }

    func reschedule(for task: HabitTask) {
        cancelReminder(for: task.id)
        scheduleStartReminder(for: task)
        scheduleLazyNudge(for: task)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }

        let userInfo = response.notification.request.content.userInfo
        if let idString = userInfo["taskID"] as? String,
           let id = UUID(uuidString: idString) {
            if response.actionIdentifier == "MARK_BEGUN" {
                NotificationCenter.default.post(name: Names.markBegun, object: nil, userInfo: ["taskID": id])
                cancelReminder(for: id) // Cancel nudge too
            }
        }
    }

    // MARK: - AI Message Generator

    private func generateCheekyNudge(for taskName: String) async -> String {
        // ✅ Fallback in case API fails
        let fallback = [
            "Come on, \(taskName) won’t do itself!",
            "If procrastination burned calories, you’d be shredded.",
            "Don’t make future you angry — start now!",
            "Five minutes in, and you’re already behind 😎",
            "Less scrolling, more doing! Get to \(taskName)."
        ]

        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return fallback.randomElement()!
        }

        let prompt = "Write a short cheeky motivational nudge for someone who hasn’t started their task named '\(taskName)' yet. Be playful but encouraging."

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 30,
            "temperature": 0.9
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = data

            // Proper async/await + try usage
            let (responseData, _) = try await URLSession.shared.data(for: request)

            if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = (choices.first?["message"] as? [String: Any])?["content"] as? String {
                return message.trimmingCharacters(in: .whitespacesAndNewlines)
            }

        } catch {
            print(" AI nudge fetch failed:", error)
        }

        return fallback.randomElement()!
    }
}
