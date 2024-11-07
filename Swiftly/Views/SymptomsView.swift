import SwiftUI

struct SymptomsView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var currentDate = Date()
    @State private var noteText: String = ""

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
                // Handle done action
            }) {
                Text("Done")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.primary)
                    .foregroundStyle(.background)
                    .cornerRadius(64)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
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
