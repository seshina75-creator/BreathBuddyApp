import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BreathingView()
                .tabItem { Label("Breathing", systemImage: "wind") }

            MoodDiaryView()
                .tabItem { Label("Diary", systemImage: "book.closed") }

            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.bar.xaxis") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(Color.appAccent)
    }
}

#Preview {
    ContentView()
}
