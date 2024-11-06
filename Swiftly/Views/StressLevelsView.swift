import SwiftUI

struct StressLevelsView: View {
    @State private var selectedMood: String?
    @State private var currentDate = Date()
    @State private var noteText: String = ""
    @State private var stressLevel: Double = 0
    @State private var anxietyLevel: Double = 0

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
        VStack(spacing: 24) {
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

#Preview {
    StressLevelsView()
}
