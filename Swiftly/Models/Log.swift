import FirebaseFirestore
import Foundation

struct Log: Identifiable, Codable {
    var id: String
    var userId: String
    var type: String
    var createdAt: Timestamp
    var note: String
    var data: LogData
}

struct LogData: Codable {
    // Mood
    var mood: String?
    
    // Meal
    var gutScore: Int?
    var mealType: String?
    var mealDescription: String?
    var mealTips: [MealTipData]?
    var mealSymptoms: [MealSymptomData]?
    
    // Symptoms (user input)
    var symptoms: [UserSymptomData]?
    
    // Stress levels
    var stressLevel: Int?
    var anxietyLevel: Int?
    
    // Stool
    var stoolType: Int?
    var stoolColor: String?
}

struct MealSymptomData: Codable, Identifiable {
    var id: String { symptom }
    var symptom: String
    var explanation: String
}

struct MealTipData: Codable, Identifiable {
    var id: String { tip }
    var tip: String
    var explanation: String
}

struct UserSymptomData: Codable {
    var name: String
    var severity: Int
}
