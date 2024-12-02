import SwiftUI

struct SymptomsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mainVM = MainViewModel()
    @State private var selectedSymptoms: Set<String> = []
    @State private var symptomSeverities: [String: Double] = [:]
    @State private var currentDate = Date()
    @State private var noteText: String = ""
    
    var editingLog: Log?
    
    init(editingLog: Log? = nil) {
        self.editingLog = editingLog
        if let log = editingLog {
            _noteText = State(initialValue: log.note)
            if let symptoms = log.data.symptoms {
                _selectedSymptoms = State(initialValue: Set(symptoms.map { $0.name }))
                _symptomSeverities = State(initialValue: Dictionary(
                    uniqueKeysWithValues: symptoms.map { ($0.name, Double($0.severity)) }
                ))
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

    // Replace the moods property with symptoms
    let symptoms = [
        "Nausea",
        "Bloating",
        "Sweats",
        "Sore throat",
        "Vomiting",
        "Indigestion",
        "Upset stomach",
        "Heartburn",
        "Dry cough",
        "Loss of appetite",
        "Globus sensation",
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
                .onReceive(timer) { _ in
                    currentDate = Date()
                }

                // Symptoms section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's bothering you?")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(symptoms, id: \.self) { symptom in
                                SymptomToggleButton(
                                    title: symptom,
                                    isSelected: selectedSymptoms.contains(symptom),
                                    action: {
                                        if selectedSymptoms.contains(symptom) {
                                            selectedSymptoms.remove(symptom)
                                        } else {
                                            selectedSymptoms.insert(symptom)
                                        }
                                    }
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
                    saveSymptomLog()
                }) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(!selectedSymptoms.isEmpty ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(selectedSymptoms.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editingLog != nil ? "Edit Symptoms" : "Symptoms Log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
        }
    }

    private func saveSymptomLog() {
        let symptomDataArray = selectedSymptoms.map { symptom in
            UserSymptomData(
                name: symptom,
                severity: Int(symptomSeverities[symptom] ?? 5)
            )
        }
        
        let logData = LogData(
            symptoms: symptomDataArray
        )
        
        if let editingLog = editingLog {
            mainVM.updateLog(
                id: editingLog.id,
                type: "Symptoms",
                note: noteText,
                data: logData
            )
        } else {
            mainVM.addLog(
                type: "Symptoms",
                note: noteText,
                data: logData
            )
        }
        
        dismiss()
    }
}

// Replace MoodToggleButton with SymptomToggleButton
struct SymptomToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 12)
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
    SymptomsView()
}
