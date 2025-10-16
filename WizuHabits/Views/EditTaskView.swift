import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var task: HabitTask
    var onSave: (HabitTask) -> Void
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Task Info") {
                    TextField("Task Name", text: $task.name)
                    
                    DatePicker("Start Time", selection: $task.startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Deadline", selection: $task.deadline, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let result = TaskValidator.validate(task)
                        if result.isValid {
                            onSave(task)
                            dismiss()
                        } else {
                            alertMessage = result.message ?? "Invalid task."
                            showAlert = true
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Task"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
