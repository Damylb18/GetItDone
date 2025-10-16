//
//  TaskValidator.swift
//  WizuHabits
//
//  Created by DAMY on 14/10/2025.
//

import Foundation

struct TaskValidator {
    static func validate(_ task: HabitTask) -> (isValid: Bool, message: String?) {
        if task.name.trimmingCharacters(in: .whitespaces).isEmpty {
            return (false, "Task name cannot be empty.")
        }
        if task.startTime < Date() {
            return (false, "Start time cannot be in the past.")
        }
        if task.deadline <= task.startTime {
            return (false, "Deadline must be after the start time.")
        }
        return (true, nil)
    }
}
