import SwiftUI

struct AddMoodEntryView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMood: Mood = .neutral
    @State private var note: String = ""

    let onSave: (MoodEntry) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("How are you feeling?") {
                    HStack(spacing: 6) {
                        ForEach(Mood.allCases) { mood in
                            moodButton(mood)
                        }
                    }
                    .padding(.vertical, 4)

                    Text(selectedMood.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Section("Note") {
                    TextField("What happened?", text: $note, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        let entry = MoodEntry(mood: selectedMood, note: trimmed)
                        onSave(entry)
                        dismiss()
                    }
                }
            }
        }
    }

    private func moodButton(_ mood: Mood) -> some View {
        let isSelected = selectedMood == mood
        return Button {
            selectedMood = mood
        } label: {
            Text(mood.emoji)
                .font(.system(size: 34))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.appAccent.opacity(0.25) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.appAccent : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddMoodEntryView { _ in }
}
