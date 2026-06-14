import Foundation

@MainActor
final class StatisticsViewModel: ObservableObject {
    struct DayCount: Identifiable, Hashable {
        let date: Date
        let count: Int
        var id: Date { date }
    }

    @Published private(set) var sessions: [BreathingSession] = []
    @Published private(set) var moodEntries: [MoodEntry] = []

    private let persistence = PersistenceService.shared

    init() {
        refresh()
    }

    func refresh() {
        sessions = persistence.loadSessions()
        moodEntries = persistence.loadMoodEntries()
    }

    var totalSessions: Int { sessions.count }

    var totalMinutes: Int {
        Int((sessions.reduce(0) { $0 + $1.durationSeconds } / 60).rounded())
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let activeDays = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        guard !activeDays.isEmpty else { return 0 }

        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while activeDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    var averageMood: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let sum = moodEntries.reduce(0) { $0 + $1.mood.rawValue }
        return Double(sum) / Double(moodEntries.count)
    }

    var sessionsLast7Days: [DayCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let count = sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: day) }.count
            return DayCount(date: day, count: count)
        }
    }
}
