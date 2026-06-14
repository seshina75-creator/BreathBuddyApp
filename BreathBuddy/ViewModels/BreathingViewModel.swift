import Foundation
import SwiftUI

@MainActor
final class BreathingViewModel: ObservableObject {
    enum Phase: String {
        case idle, inhale, hold, exhale, rest, finished

        var instruction: String {
            switch self {
            case .idle:     return "Ready to begin?"
            case .inhale:   return "Inhale"
            case .hold:     return "Hold"
            case .exhale:   return "Exhale"
            case .rest:     return "Rest"
            case .finished: return "Great job!"
            }
        }
    }

    @Published var selectedTechnique: BreathingTechnique
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var phaseProgress: Double = 0
    @Published private(set) var currentCycle: Int = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var elapsedSeconds: Double = 0

    private var timer: Timer?
    private var phaseStartedAt: Date = Date()
    private var phaseDuration: Double = 0
    private var sessionStartedAt: Date = Date()

    private let persistence = PersistenceService.shared

    init(technique: BreathingTechnique = BreathingTechnique.presets[0]) {
        self.selectedTechnique = technique
    }

    deinit {
        timer?.invalidate()
    }

    var scale: CGFloat {
        switch phase {
        case .idle, .finished, .rest:
            return 0.55
        case .inhale:
            return 0.55 + 0.45 * CGFloat(phaseProgress)
        case .hold:
            return 1.0
        case .exhale:
            return 1.0 - 0.45 * CGFloat(phaseProgress)
        }
    }

    var displayCycle: Int {
        max(1, min(currentCycle + (isRunning ? 1 : 0), selectedTechnique.cycles))
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        currentCycle = 0
        elapsedSeconds = 0
        sessionStartedAt = Date()
        beginPhase(.inhale)

        let t = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
    }

    func stop() {
        let wasRunning = isRunning
        let cyclesAtStop = currentCycle
        let elapsed = elapsedSeconds

        timer?.invalidate()
        timer = nil
        isRunning = false

        if wasRunning && elapsed > 1 {
            persistSession(durationSeconds: elapsed, completedCycles: cyclesAtStop)
        }

        phase = .idle
        phaseProgress = 0
    }

    private func tick() {
        let now = Date()
        elapsedSeconds = now.timeIntervalSince(sessionStartedAt)
        let elapsedInPhase = now.timeIntervalSince(phaseStartedAt)
        phaseProgress = min(1, elapsedInPhase / max(phaseDuration, 0.0001))

        if elapsedInPhase >= phaseDuration {
            advancePhase()
        }
    }

    private func advancePhase() {
        switch phase {
        case .inhale:
            if selectedTechnique.holdSeconds > 0 {
                beginPhase(.hold)
            } else {
                beginPhase(.exhale)
            }
        case .hold:
            beginPhase(.exhale)
        case .exhale:
            if selectedTechnique.restSeconds > 0 {
                beginPhase(.rest)
            } else {
                finishCycle()
            }
        case .rest:
            finishCycle()
        case .idle, .finished:
            break
        }
    }

    private func finishCycle() {
        currentCycle += 1
        if currentCycle >= selectedTechnique.cycles {
            complete()
        } else {
            beginPhase(.inhale)
        }
    }

    private func complete() {
        let elapsed = elapsedSeconds
        let cycles = currentCycle

        timer?.invalidate()
        timer = nil
        isRunning = false
        phase = .finished
        phaseProgress = 1

        persistSession(durationSeconds: elapsed, completedCycles: cycles)
    }

    private func beginPhase(_ newPhase: Phase) {
        phase = newPhase
        phaseStartedAt = Date()
        phaseProgress = 0
        switch newPhase {
        case .inhale: phaseDuration = selectedTechnique.inhaleSeconds
        case .hold:   phaseDuration = selectedTechnique.holdSeconds
        case .exhale: phaseDuration = selectedTechnique.exhaleSeconds
        case .rest:   phaseDuration = selectedTechnique.restSeconds
        case .idle, .finished: phaseDuration = 0
        }
    }

    private func persistSession(durationSeconds: Double, completedCycles: Int) {
        let session = BreathingSession(
            techniqueId: selectedTechnique.id,
            techniqueName: selectedTechnique.name,
            startedAt: sessionStartedAt,
            durationSeconds: durationSeconds,
            completedCycles: completedCycles
        )
        persistence.appendSession(session)
    }
}
