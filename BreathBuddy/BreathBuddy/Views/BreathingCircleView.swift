import SwiftUI

struct BreathingCircleView: View {
    @ObservedObject var viewModel: BreathingViewModel

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                Circle()
                    .stroke(Color.appAccent.opacity(0.18), lineWidth: 2)
                    .frame(width: side, height: side)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appAccent.opacity(0.75),
                                Color.appAccent.opacity(0.15)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: side / 2
                        )
                    )
                    .frame(width: side, height: side)
                    .scaleEffect(viewModel.scale)
                    .animation(.linear(duration: 0.04), value: viewModel.scale)

                VStack(spacing: 4) {
                    Text(timeRemaining)
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                    Text(viewModel.selectedTechnique.name)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(radius: 2)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var timeRemaining: String {
        let total = viewModel.selectedTechnique.totalDurationSeconds
        let remaining = max(0, total - viewModel.elapsedSeconds)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
