//
//  UpcomingView.swift
//  WizuHabits
//
//  Created by MAC on 26/09/2025.
//


import SwiftUI

struct UpcomingView: View {
    @StateObject private var store = TaskStore()
    
    private var upcomingTasks: [HabitTask] {
        let calendar = Calendar.current
        return store.tasks.filter { task in
            task.startTime > Date() && !calendar.isDate(task.startTime, inSameDayAs: Date())
        }
        .sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        VStack (spacing:0)
        {
            AppHeaderView(title: "What's coming up?")
                List {
                    if upcomingTasks.isEmpty {
                        Text("No upcoming tasks ")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(groupedTasks.keys.sorted(), id: \.self) { date in
                            Section(header: Text(sectionTitle(for: date))) {
                                ForEach(groupedTasks[date] ?? []) { task in
                                    VStack(alignment: .leading) {
                                        Text(task.name)
                                            .font(.headline)
                                        
                                        Text("Start: \(task.startTime.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
        }
        .ignoresSafeArea(edges: .top)
        
        }
    
    // Group tasks by calendar day
    private var groupedTasks: [Date: [HabitTask]] {
        Dictionary(grouping: upcomingTasks) { task in
            Calendar.current.startOfDay(for: task.startTime)
        }
    }
    
    // Convert date into readable section title
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if let days = calendar.dateComponents([.day], from: Date(), to: date).day {
            return "In \(days) days"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}

#Preview {
    UpcomingView()
}
