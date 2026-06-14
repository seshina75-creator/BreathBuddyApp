import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let defaults = UserDefaults.standard

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private enum Keys {
        static let moodEntries = "breathbuddy.moodEntries"
        static let sessions = "breathbuddy.sessions"
        static let reminderEnabled = "breathbuddy.reminderEnabled"
        static let reminderHour = "breathbuddy.reminderHour"
        static let reminderMinute = "breathbuddy.reminderMinute"
        static let reminderConfigured = "breathbuddy.reminderConfigured"
    }

    // MARK: - Mood entries

    func loadMoodEntries() -> [MoodEntry] {
        guard let data = defaults.data(forKey: Keys.moodEntries),
              let entries = try? decoder.decode([MoodEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func saveMoodEntries(_ entries: [MoodEntry]) {
        guard let data = try? encoder.encode(entries) else { return }
        defaults.set(data, forKey: Keys.moodEntries)
    }

    // MARK: - Breathing sessions

    func loadSessions() -> [BreathingSession] {
        guard let data = defaults.data(forKey: Keys.sessions),
              let sessions = try? decoder.decode([BreathingSession].self, from: data) else {
            return []
        }
        return sessions
    }

    func saveSessions(_ sessions: [BreathingSession]) {
        guard let data = try? encoder.encode(sessions) else { return }
        defaults.set(data, forKey: Keys.sessions)
    }

    func appendSession(_ session: BreathingSession) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
    }

    // MARK: - Reminder

    var reminderEnabled: Bool {
        get { defaults.bool(forKey: Keys.reminderEnabled) }
        set { defaults.set(newValue, forKey: Keys.reminderEnabled) }
    }

    var reminderHour: Int {
        get {
            if defaults.bool(forKey: Keys.reminderConfigured) {
                return defaults.integer(forKey: Keys.reminderHour)
            }
            return 9
        }
        set {
            defaults.set(newValue, forKey: Keys.reminderHour)
            defaults.set(true, forKey: Keys.reminderConfigured)
        }
    }

    var reminderMinute: Int {
        get {
            if defaults.bool(forKey: Keys.reminderConfigured) {
                return defaults.integer(forKey: Keys.reminderMinute)
            }
            return 0
        }
        set {
            defaults.set(newValue, forKey: Keys.reminderMinute)
            defaults.set(true, forKey: Keys.reminderConfigured)
        }
    }
}
