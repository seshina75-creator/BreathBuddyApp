import Foundation

@MainActor
final class MoodDiaryViewModel: ObservableObject {
    @Published private(set) var entries: [MoodEntry] = []

    private let persistence = PersistenceService.shared

    init() {
        load()
    }

    func load() {
        entries = persistence.loadMoodEntries().sorted { $0.date > $1.date }
    }

    func add(_ entry: MoodEntry) {
        entries.append(entry)
        entries.sort { $0.date > $1.date }
        persistence.saveMoodEntries(entries)
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        persistence.saveMoodEntries(entries)
    }
}
