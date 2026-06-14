import SwiftUI

struct BreathingView: View {
    @StateObject private var viewModel = BreathingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    techniquePicker
                    BreathingCircleView(viewModel: viewModel)
                        .frame(height: 320)
                    instructionPanel
                    controls
                }
                .padding()
            }
            .navigationTitle("Breathing")
            .background(Color.appBackground.ignoresSafeArea())
        }
    }

    private var techniquePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BreathingTechnique.presets) { technique in
                    techniqueCard(technique)
                }
            }
        }
    }

    private func techniqueCard(_ technique: BreathingTechnique) -> some View {
        let isSelected = viewModel.selectedTechnique.id == technique.id
        return Button {
            if !viewModel.isRunning {
                viewModel.selectedTechnique = technique
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(technique.name)
                    .font(.headline)
                Text(technique.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer(minLength: 4)
                Text("\(technique.cycles) cycles · \(Int(technique.totalDurationSeconds)) sec")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .frame(width: 180, height: 110, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.appAccent.opacity(0.18) : Color.appCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.appAccent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isRunning)
    }

    private var instructionPanel: some View {
        VStack(spacing: 6) {
            Text(viewModel.phase.instruction)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: viewModel.phase)
            Text("Cycle \(viewModel.displayCycle) of \(viewModel.selectedTechnique.cycles)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack(spacing: 16) {
            if viewModel.isRunning {
                Button(role: .destructive) {
                    viewModel.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button {
                    viewModel.start()
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.appAccent)
            }
        }
        .controlSize(.large)
    }
}

#Preview {
    BreathingView()
}
