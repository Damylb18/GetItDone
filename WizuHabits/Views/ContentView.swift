import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(0)
                    .tabItem {
                        Label("Today", systemImage: "calendar")
                    }

                UpcomingView()
                    .tag(1)
                    .tabItem {
                        Label("Upcoming", systemImage: "clock")
                    }

                StatsView()
                    .tag(2)
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }

                ProfileView()
                    .tag(3)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.purple)
        }
    }

    // Computed title based on the selected tab
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Today"
        case 1: return "Upcoming"
        case 2: return "Stats"
        case 3: return "Profile"
        default: return "Get it Done"
        }
    }
}

#Preview {
    ContentView()
}
