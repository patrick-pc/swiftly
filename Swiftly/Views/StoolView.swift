import SwiftUI

// Add this struct at the top of the file, outside of StoolView
struct StoolType: Identifiable {
    let id: Int
    let title: String
    let condition: String
    let description: String
    let shape: String
    let image: String
}

// Add this struct near StoolType
struct StoolColor: Identifiable {
    let id: String
    let name: String
    let color: Color
}

struct StoolView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mainVM = MainViewModel()
    @State private var selectedStoolType: Int?
    @State private var selectedColor: String?
    @State private var currentDate = Date()
    @State private var noteText: String = ""
    
    var editingLog: Log?
    
    init(editingLog: Log? = nil) {
        self.editingLog = editingLog
        if let log = editingLog {
            _noteText = State(initialValue: log.note)
            if let stoolType = log.data.stoolType {
                _selectedStoolType = State(initialValue: stoolType)
            }
            if let color = log.data.stoolColor {
                _selectedColor = State(initialValue: color)
            }
        }
    }
    
    // Add stool types data
    let stoolTypes: [StoolType] = [
        StoolType(id: 1, title: "Type 1", condition: "Severe Constipation", description: "Separate small and hard lumps", shape: "Pebble", image: "🫘"),
        StoolType(id: 2, title: "Type 2", condition: "Mild Constipation", description: "Lumpy, hard, sausage-shaped", shape: "Log", image: "🪵"),
        StoolType(id: 3, title: "Type 3", condition: "Normal", description: "Sausage-shaped with small cracks", shape: "Sausage", image: "🌭"),
        StoolType(id: 4, title: "Type 4", condition: "Normal", description: "A smooth and soft snake or sausage", shape: "Snake", image: "🐍"),
        StoolType(id: 5, title: "Type 5", condition: "Lacking Fiber", description: "Soft blobs with clear-cut edges", shape: "Blobs", image: "🧆"),
        StoolType(id: 6, title: "Type 6", condition: "Mild Diarrhea", description: "Mushy, fluffy with ragged edges", shape: "Mushy", image: "🍄"),
        StoolType(id: 7, title: "Type 7", condition: "Diarrhea", description: "Completely liquid with no solid pieces", shape: "Watery", image: "🫠")
    ]

    // Add stool colors data
    let stoolColors: [StoolColor] = [
        StoolColor(id: "green", name: "Green", color: .green),
        StoolColor(id: "brown", name: "Brown", color: .brown),
        StoolColor(id: "yellow", name: "Yellow", color: .yellow),
        StoolColor(id: "light", name: "Light", color: .white.opacity(0.8)),
        StoolColor(id: "gray", name: "Gray", color: .gray),
        StoolColor(id: "bloody", name: "Bloody", color: .red),
        StoolColor(id: "black", name: "Black", color: .black)
    ]

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

                // Add Stool section
                VStack(alignment: .leading, spacing: 8) {
                    Text("How was your poop?")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEach(stoolTypes) { stoolType in
                                StoolToggleButton(
                                    image: stoolType.image,
                                    shape: stoolType.shape,
                                    condition: stoolType.condition,
                                    isSelected: selectedStoolType == stoolType.id,
                                    action: { selectedStoolType = stoolType.id }
                                )
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                    .frame(height: 44, alignment: .top)
                }
                .padding(.horizontal)

                // Color section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()

                        if let selectedColor = selectedColor,
                           let color = stoolColors.first(where: { $0.id == selectedColor }) {
                            Text(color.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        ForEach(stoolColors) { stoolColor in
                            Button(action: {
                                selectedColor = stoolColor.id
                            }) {
                                Circle()
                                    .fill(stoolColor.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(
                                                selectedColor == stoolColor.id ? 
                                                    Color.primary : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(
                                        color: Color.black.opacity(0.1),
                                        radius: 2,
                                        x: 0,
                                        y: 1
                                    )
                            }
                            
                            if stoolColor.id != stoolColors.last?.id {
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 44)
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
                    saveStoolLog()
                }) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(selectedStoolType != nil && selectedColor != nil ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(selectedStoolType == nil || selectedColor == nil)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editingLog != nil ? "Edit Stool" : "Stool Log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
        }
    }

    private func saveStoolLog() {
        let logData = LogData(
            stoolType: selectedStoolType,
            stoolColor: selectedColor
        )
        
        if let editingLog = editingLog {
            mainVM.updateLog(
                id: editingLog.id,
                type: "Stool",
                note: noteText,
                data: logData
            )
        } else {
            mainVM.addLog(
                type: "Stool",
                note: noteText,
                data: logData
            )
        }
        
        dismiss()
    }
}

// Add this new view for the toggle buttons
struct StoolToggleButton: View {
    let image: String
    let shape: String
    let condition: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(image)
                Text(shape)
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
    StoolView()
}
