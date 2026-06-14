import Foundation

struct BreathingSession: Identifiable, Codable, Hashable {
    let id: UUID
    let techniqueId: UUID
    let techniqueName: String
    let startedAt: Date
    let durationSeconds: Double
    let completedCycles: Int

    init(
        id: UUID = UUID(),
        techniqueId: UUID,
        techniqueName: String,
        startedAt: Date = Date(),
        durationSeconds: Double,
        completedCycles: Int
    ) {
        self.id = id
        self.techniqueId = techniqueId
        self.techniqueName = techniqueName
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.completedCycles = completedCycles
    }
}
