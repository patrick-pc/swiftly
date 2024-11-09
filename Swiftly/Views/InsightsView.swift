//
//  InsightsView.swift
//  Swiftly
//
//  Created by Patrick on 11/9/24.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @StateObject private var mainVM = MainViewModel()
    
    // Sample data structure for gut scores
    struct DailyScore: Identifiable {
        let id = UUID()
        let day: String
        let score: Int
    }
    
    // Calculate streak from logs
    private var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var currentDate = Date()
        
        while true {
            let logsForDay = mainVM.logs.filter { log in
                calendar.isDate(log.createdAt.dateValue(), inSameDayAs: currentDate)
            }
            
            if logsForDay.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
        }
        
        return streak
    }
    
    // Calculate average gut score
    private var averageGutScore: Int {
        let scores = mainVM.logs.compactMap { $0.data.gutScore }
        return scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
    }

    // Calculate today's gut score
    private var todayGutScore: Int {
        let calendar = Calendar.current
        let today = Date()
        let todayLogs = mainVM.logs.filter { log in
            calendar.isDate(log.createdAt.dateValue(), inSameDayAs: today)
        }
        
        let scores = todayLogs.compactMap { $0.data.gutScore }
        return scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
    }
    
    // Calculate weekly gut scores
    private var weeklyGutScores: [DailyScore] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).map { day -> DailyScore in
            let date = calendar.date(byAdding: .day, value: -day, to: today) ?? today
            let dayLogs = mainVM.logs.filter { log in
                calendar.isDate(log.createdAt.dateValue(), inSameDayAs: date)
            }
            
            let scores = dayLogs.compactMap { $0.data.gutScore }
            let averageScore = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let dayString = formatter.string(from: date)
            
            return DailyScore(day: dayString, score: averageScore)
        }.reversed()
        
        return Array(weekDays)
    }
    
    // Add this function after other private properties
    private func getTopMoods() -> [(mood: String, count: Int)] {
        // Create dictionary to count occurrences of each mood
        var moodCounts: [String: Int] = [:]
        
        // Count moods from logs
        for log in mainVM.logs {
            if let mood = log.data.mood {
                moodCounts[mood, default: 0] += 1
            }
        }
        
        // Sort by count and get top 5
        let sortedMoods = moodCounts.sorted { $0.value > $1.value }
        return Array(sortedMoods.prefix(5))
            .map { (mood: $0.key, count: $0.value) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Streak Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stats")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 16) {
                        // Current Streak
                        SharedComponents.card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current streak")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.5))
                                
                                Text("\(currentStreak) days")
                                    .font(.headline)
                            }
                        }
                        
                        // Average Gut Score
                        SharedComponents.card {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Average gut score")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.5))
                                
                                Text("\(averageGutScore)")
                                    .font(.headline)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Daily Progress Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gut Score")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today's gut score")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.5))
                                
                                Text(todayGutScore == 0 ? "0" : "\(todayGutScore)/100")
                                    .font(.headline)
                            }
                            
                            // Chart with empty day indicators
                            Chart {
                                ForEach(weeklyGutScores) { score in
                                    if score.score > 0 {
                                        BarMark(
                                            x: .value("Day", score.day),
                                            y: .value("Score", score.score)
                                        )
                                        .cornerRadius(4)
                                        .foregroundStyle(isCurrentDay(score.day) ? Color.primary : Color.primary.opacity(0.5))
                                    } else {
                                        // Add line for empty days
                                        RectangleMark(
                                            x: .value("Day", score.day),
                                            yStart: .value("Start", 0),
                                            yEnd: .value("End", 2),
                                            width: .fixed(30)
                                        )
                                        .foregroundStyle(
                                            isCurrentDay(score.day) ? Color.primary : Color.primary.opacity(0.5)
                                        )
                                    }
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .foregroundStyle(isCurrentDay(value.as(String.self) ?? "") ? Color.primary : Color.primary.opacity(0.5))
                                }
                            }
                            .chartYAxis(.hidden)
                            .frame(height: 100)
                            
                            Text("You don't have enough tracking data from the last week to give any insights. Track at least 4 days in a week to give you a better idea of your gut health.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Button(action: {
                                // TODO: Implement unlock insights
                            }) {
                                Text("Unlock insights")
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundStyle(.background)
                                    .background(.primary)
                                    .cornerRadius(32)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Mood Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Mood")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top 5 moods")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.5))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(getTopMoods(), id: \.mood) { mood in
                                    Text("\(mood.mood) (\(mood.count))")
                                        .font(.headline)
                                }
                            }
                            
                            if getTopMoods().isEmpty {
                                Text("Nothing here yet")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Add helper function to check if it's the current day
    private func isCurrentDay(_ day: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let currentDay = formatter.string(from: Date())
        return day == currentDay
    }
}

#Preview {
    NavigationStack {
        InsightsView()
    }
}
