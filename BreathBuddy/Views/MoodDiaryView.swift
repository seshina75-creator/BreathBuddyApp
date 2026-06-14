import SwiftUI

struct MoodDiaryView: View {
    @StateObject private var viewModel = MoodDiaryViewModel()
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            MoodEntryRow(entry: entry)
                                .listRowBackground(Color.appCard)
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Diary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddMoodEntryView { entry in
                    viewModel.add(entry)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("Your diary is empty")
                .font(.title2.bold())
            Text("Add your first mood entry")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showingAddSheet = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appAccent)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MoodEntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(entry.mood.emoji)
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.mood.title)
                        .font(.headline)
                    Spacer()
                    Text(entry.date, format: .dateTime.day().month().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    MoodDiaryView()
}
