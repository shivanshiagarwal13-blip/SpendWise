import SwiftUI

struct ContentView: View {

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 1)
                : UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
        }
        UITabBar.appearance().standardAppearance    = appearance
        UITabBar.appearance().scrollEdgeAppearance  = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.label.withAlphaComponent(0.35)
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home",     systemImage: "house.fill")        }
            DayLogView()
                .tabItem { Label("Day Log",  systemImage: "square.and.pencil") }
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar")          }
        }
        .tint(.accentTerracotta)
    }
}
