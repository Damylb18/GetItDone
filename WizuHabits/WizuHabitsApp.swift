//
//  WizuHabitsApp.swift
//  WizuHabits
//
//  Created by MAC on 19/09/2025.
//

import SwiftUI

@main
struct WizuHabitsApp: App {
    init() {
        NotificationService.shared.requestAuthorization()
        NotificationService.shared.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
