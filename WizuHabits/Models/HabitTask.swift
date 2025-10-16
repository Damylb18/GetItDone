//
//  HabitTask.swift
//  WizuHabits
//
//  Created by MAC on 26/09/2025.
//

import Foundation

struct HabitTask: Identifiable, Codable {
    let id = UUID()
    var name: String
    var startTime: Date
    var deadline: Date
    var isBegun: Bool = false
    var isCompleted: Bool = false
}
