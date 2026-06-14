import Foundation

enum Mood: Int, CaseIterable, Codable, Identifiable, Hashable {
    case awful = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .awful:   return "😣"
        case .bad:     return "😕"
        case .neutral: return "😐"
        case .good:    return "🙂"
        case .great:   return "😄"
        }
    }

    var title: String {
        switch self {
        case .awful:   return "Awful"
        case .bad:     return "Bad"
        case .neutral: return "Neutral"
        case .good:    return "Good"
        case .great:   return "Great"
        }
    }
}

struct MoodEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var mood: Mood
    var note: String

    init(id: UUID = UUID(), date: Date = Date(), mood: Mood, note: String = "") {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
    }
}
