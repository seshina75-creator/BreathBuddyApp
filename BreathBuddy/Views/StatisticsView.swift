import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryGrid
                    sessionsChartCard
                    moodSummaryCard
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Statistics")
            .onAppear { viewModel.refresh() }
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Sessions",
                value: "\(viewModel.totalSessions)",
                systemImage: "wind"
            )
            StatCard(
                title: "Minutes",
                value: "\(viewModel.totalMinutes)",
                systemImage: "clock"
            )
            StatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak) days",
                systemImage: "flame"
            )
            StatCard(
                title: "Mood",
                value: viewModel.averageMood == 0 ? "—" : String(format: "%.1f / 5", viewModel.averageMood),
                systemImage: "heart"
            )
        }
    }

    private var sessionsChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sessions in the last 7 days")
                .font(.headline)

            Chart(viewModel.sessionsLast7Days) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Sessions", item.count)
                )
                .foregroundStyle(Color.appAccent)
                .cornerRadius(6)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                    AxisTick()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appCard))
    }

    private var moodSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood entries")
                .font(.headline)
            Text("\(viewModel.moodEntries.count)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            if !viewModel.moodEntries.isEmpty {
                Text("Average rating: \(String(format: "%.2f", viewModel.averageMood)) out of 5")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("No entries yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appCard))
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(Color.appAccent)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appCard))
    }
}

#Preview {
    StatisticsView()
}
