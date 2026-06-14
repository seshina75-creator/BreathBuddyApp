import SwiftUI

struct SettingsView: View {
    @State private var reminderEnabled: Bool = PersistenceService.shared.reminderEnabled
    @State private var reminderTime: Date = SettingsView.initialReminderTime()
    @State private var permissionDenied = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily reminder") {
                    Toggle("Enable", isOn: $reminderEnabled)
                        .tint(Color.appAccent)
                        .onChange(of: reminderEnabled) { _, newValue in
                            Task { await handleReminderToggle(newValue) }
                        }

                    if reminderEnabled {
                        DatePicker("Time",
                                   selection: $reminderTime,
                                   displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { _, newValue in
                                Task { await rescheduleReminder(at: newValue) }
                            }
                    }

                    if permissionDenied {
                        Text("Allow notifications in iOS Settings to receive reminders.")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }

                Section("About") {
                    LabeledContent("Name", value: "BreathBuddy")
                    LabeledContent("Version", value: appVersion)
                    Text("Breathing exercises, mood diary, and simple progress statistics.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private static func initialReminderTime() -> Date {
        var components = DateComponents()
        components.hour = PersistenceService.shared.reminderHour
        components.minute = PersistenceService.shared.reminderMinute
        return Calendar.current.date(from: components) ?? Date()
    }

    @MainActor
    private func handleReminderToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await NotificationService.shared.requestAuthorization()
            if !granted {
                reminderEnabled = false
                permissionDenied = true
                PersistenceService.shared.reminderEnabled = false
                return
            }
            permissionDenied = false
            PersistenceService.shared.reminderEnabled = true
            await rescheduleReminder(at: reminderTime)
        } else {
            PersistenceService.shared.reminderEnabled = false
            NotificationService.shared.cancelDailyReminder()
        }
    }

    @MainActor
    private func rescheduleReminder(at date: Date) async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0
        PersistenceService.shared.reminderHour = hour
        PersistenceService.shared.reminderMinute = minute
        guard reminderEnabled else { return }
        await NotificationService.shared.scheduleDailyReminder(hour: hour, minute: minute)
    }
}

#Preview {
    SettingsView()
}
