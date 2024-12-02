import SwiftUI

struct MoodView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mainVM = MainViewModel()
    @State private var selectedMood: String?
    @State private var currentDate = Date()
    @State private var noteText: String = ""

    var editingLog: Log?

    init(editingLog: Log? = nil) {
        self.editingLog = editingLog
        if let log = editingLog,
           let mood = log.data.mood {
            // Extract mood text without emoji
            let components = mood.components(separatedBy: " ")
            if components.count > 1 {
                _selectedMood = State(initialValue: components[1])
            }
            _noteText = State(initialValue: log.note)
        }
    }

    // Add a timer to keep the time updated
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    // Add this property to your MoodView struct
    let moods: [(String, String)] = [
        ("Joyful", "😊"),
        ("Happy", "🙂"),
        ("Satisfied", "😀"),
        ("Calm", "😌"),
        ("Meh", "😐"),
        ("Overwhelmed", "😩"),
        ("Stressed", "😰"),
        ("Drained", "😮‍💨"),
        ("Anxious", "😟"),
        ("Sad", "😢"),
        ("Angry", "😠"),
        ("Frustrated", "😤"),
        ("Irritated", "😒"),
        ("Worried", "🫨"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Top buttons
                HStack(spacing: 16) {
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.5))

                            Text(dateFormatter.string(from: currentDate))
                                .font(.headline)
                        }
                    }

                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.5))

                            Text(timeFormatter.string(from: currentDate))
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                // Add the timer to update currentDate
                .onReceive(timer) { _ in
                    currentDate = Date()
                }

                // Mood section
                VStack(alignment: .leading, spacing: 8) {
                    Text("How are you feeling?")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(moods, id: \.0) { mood in
                                MoodToggleButton(
                                    title: mood.0,
                                    emoji: mood.1,
                                    isSelected: selectedMood == mood.0,
                                    action: { selectedMood = mood.0 }
                                )
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                    .frame(height: 44, alignment: .top)
                }
                .padding(.horizontal)

                // Notes section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Attach a note")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    TextField("Tap here to write", text: $noteText, axis: .vertical)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary.opacity(0.3))
                        .lineLimit(4 ... 6)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal)

                Spacer()

                // Done button
                Button(action: {
                    saveMoodLog()
                }) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(selectedMood != nil ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(selectedMood == nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editingLog != nil ? "Edit Mood" : "Mood Log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
        }
    }

    private func saveMoodLog() {
        guard let selectedMood = selectedMood,
              let moodData = moods.first(where: { $0.0 == selectedMood }) else { return }
              
        let logData = LogData(
            mood: "\(moodData.1) \(moodData.0)"
        )
        
        if let editingLog = editingLog {
            // Update existing log
            mainVM.updateLog(
                id: editingLog.id,
                type: "Mood",
                note: noteText,
                data: logData
            )
        } else {
            // Create new log
            mainVM.addLog(
                type: "Mood",
                note: noteText,
                data: logData
            )
        }
        
        dismiss()
    }
}

struct MoodToggleButton: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                Text(title)
            }
            .font(.headline)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primary.opacity(0.1) : Color.clear)
            .foregroundColor(.primary)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    MoodView()
}
