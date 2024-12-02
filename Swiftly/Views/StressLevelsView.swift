import SwiftUI

struct StressLevelsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mainVM = MainViewModel()
    @State private var currentDate = Date()
    @State private var noteText: String = ""
    @State private var stressLevel: Double = 0
    @State private var anxietyLevel: Double = 0

    var editingLog: Log?
    
    init(editingLog: Log? = nil) {
        self.editingLog = editingLog
        if let log = editingLog {
            _noteText = State(initialValue: log.note)
            if let stress = log.data.stressLevel {
                print("Setting stress level: \(stress)")
                _stressLevel = State(initialValue: Double(stress))
            }
            if let anxiety = log.data.anxietyLevel {
                print("Setting anxiety level: \(anxiety)")
                _anxietyLevel = State(initialValue: Double(anxiety))
            }
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

    private func getLevelText(for level: Int, type: String) -> String {
        switch level {
            case 0: return "No \(type)"
            case 1: return "Very low \(type)"
            case 2: return "Low \(type)"
            case 3: return "Average \(type)"
            case 4: return "High \(type)"
            case 5: return "Very high \(type)"
            default: return ""
        }
    }

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
                .onReceive(timer) { _ in
                    currentDate = Date()
                }

                // Stress section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("How stressed are you?")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()
                        Text(getLevelText(for: Int(stressLevel), type: "stress"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $stressLevel, in: 0 ... 5, step: 1)
                        .tint(.primary)
                }
                .padding(.horizontal)

                // Anxiety section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("How anxious are you?")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(getLevelText(for: Int(anxietyLevel), type: "anxiety"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Slider(value: $anxietyLevel, in: 0 ... 5, step: 1)
                        .tint(.primary)
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
                    saveStressLog()
                }) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(stressLevel > 0 || anxietyLevel > 0 ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(stressLevel == 0 && anxietyLevel == 0)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editingLog != nil ? "Edit Stress & Anxiety" : "Stress & Anxiety Log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
        }
    }

    private func saveStressLog() {
        let logData = LogData(
            stressLevel: Int(stressLevel),
            anxietyLevel: Int(anxietyLevel)
        )
        
        if let editingLog = editingLog {
            mainVM.updateLog(
                id: editingLog.id,
                type: "StressLevels",
                note: noteText,
                data: logData
            )
        } else {
            mainVM.addLog(
                type: "StressLevels",
                note: noteText,
                data: logData
            )
        }
        
        dismiss()
    }
}

#Preview {
    StressLevelsView()
}
