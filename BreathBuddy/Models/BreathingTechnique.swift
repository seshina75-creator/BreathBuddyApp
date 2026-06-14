import Foundation

struct BreathingTechnique: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let subtitle: String
    let inhaleSeconds: Double
    let holdSeconds: Double
    let exhaleSeconds: Double
    let restSeconds: Double
    let cycles: Int

    var totalCycleSeconds: Double {
        inhaleSeconds + holdSeconds + exhaleSeconds + restSeconds
    }

    var totalDurationSeconds: Double {
        totalCycleSeconds * Double(cycles)
    }

    static let presets: [BreathingTechnique] = [
        BreathingTechnique(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Box",
            subtitle: "Box breathing 4·4·4·4",
            inhaleSeconds: 4, holdSeconds: 4, exhaleSeconds: 4, restSeconds: 4,
            cycles: 6
        ),
        BreathingTechnique(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "4-7-8",
            subtitle: "For relaxing before bed",
            inhaleSeconds: 4, holdSeconds: 7, exhaleSeconds: 8, restSeconds: 0,
            cycles: 4
        ),
        BreathingTechnique(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Coherent",
            subtitle: "Even 5·5 breathing for calm",
            inhaleSeconds: 5, holdSeconds: 0, exhaleSeconds: 5, restSeconds: 0,
            cycles: 8
        )
    ]
}
