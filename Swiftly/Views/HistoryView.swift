import SwiftUI

struct HistoryView: View {
    @StateObject private var mainVM = MainViewModel()

    @State private var selectedLog: Log?

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

    private func formatLogDisplay(_ log: Log) -> (title: String, description: String) {
        switch log.type {
        case "Mood":
            return ("Mood", (log.data.mood ?? "").replacingOccurrences(of: "^[\\p{Emoji}\\s]+", with: "", options: .regularExpression))
            
        case "Meal":
            return (log.data.mealType ?? "Meal", "Gut Score: \(log.data.gutScore ?? 0)/100")
            
        case "Symptoms":
            let symptomsText = (log.data.symptoms ?? [])
                .map { "\($0.name)" }
                .joined(separator: ", ")
            return ("Symptoms", symptomsText)
            
        case "StressLevels":
            var desc = ""
            if let stress = log.data.stressLevel {
                desc += getLevelText(for: stress, type: "stress")
            }
            if let anxiety = log.data.anxietyLevel {
                desc += anxiety > 0 ? ", \(getLevelText(for: anxiety, type: "anxiety"))" : ""
            }
            return ("Stress & Anxiety", desc)
            
        case "Stool":
            if let stoolType = log.data.stoolType,
               let stoolData = stoolTypes.first(where: { $0.id == stoolType }) {
                return ("Stool", "\(stoolData.condition)")
            }
            return ("Stool", "Unknown type")
            
        default:
            return ("Unknown", "")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar View
                CalendarView(
                    selectedDate: $mainVM.selectedDate,
                    logDates: Set(mainVM.logs.map { Calendar.current.startOfDay(for: $0.createdAt.dateValue()) })
                )
                .padding(.bottom)

                // Items List
                VStack {
                    if mainVM.filteredLogs.isEmpty {
                        Spacer()

                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .padding(10)
                                    .background(Circle().fill(.primary.opacity(0.1)))
                                
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .padding(10)
                                    .background(Circle().fill(.primary.opacity(0.1)))


                                Image(systemName: "figure.mind.and.body")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .padding(10)
                                    .background(Circle().fill(.primary.opacity(0.1)))
                            }

                            Text("It's a bit quiet in here...")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("You can see the daily history of all your logs here")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.5))
                                .frame(maxWidth: 220)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                ForEach(mainVM.filteredLogs) { log in
                                    let displayInfo = formatLogDisplay(log)
                                    SharedComponents.card {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formattedDate(log.createdAt.dateValue()))
                                                .font(.caption)
                                                .foregroundColor(.primary.opacity(0.8))
                                            Text(displayInfo.title)
                                                // .font(.title2)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            if !displayInfo.description.isEmpty {
                                                Text(displayInfo.description)
                                                    .font(.subheadline)
                                                    .padding(.top)
                                            }
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedLog = log
                                    }
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedLog) { log in
            switch log.type {
            case "Mood":
                MoodView(editingLog: log)
            case "Symptoms":
                SymptomsView(editingLog: log)
            case "StressLevels":
                StressLevelsView(editingLog: log)
            case "Stool":
                StoolView(editingLog: log)
            case "Meal":
                VisionView(editingLog: log)
            default:
                Text("Unsupported log type: \(log.type)")
            }
        }
    }

    // Delete Items
    private func deleteItems(at offsets: IndexSet) {
        offsets.map { mainVM.items[$0] }.forEach { item in
            mainVM.deleteItem(item)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
