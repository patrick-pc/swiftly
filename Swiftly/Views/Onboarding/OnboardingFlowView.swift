import SwiftUI

enum OnboardingScreen: Hashable {
    case welcome
    case journey
    case foodLogging
    case insights
    case tracking
    case heightAndWeight
    case ageGroup
    case gender
    case experiences
    case lastFeltGreat
    case currentGutFeeling
    case commonSymptoms
    case dietaryPreferences
    case digestiveConditions
    case goals
    case summary
    case auth
}

extension OnboardingScreen {
    var progressValue: Double {
        let total = 17.0 // Total number of screens
        switch self {
        case .welcome: return 1 / total
        case .lastFeltGreat: return 2 / total
        case .journey: return 3 / total
        case .foodLogging: return 4 / total
        case .insights: return 5 / total
        case .tracking: return 6 / total
        case .heightAndWeight: return 7 / total
        case .ageGroup: return 8 / total
        case .gender: return 9 / total
        case .experiences: return 10 / total
        case .currentGutFeeling: return 11 / total
        case .commonSymptoms: return 12 / total
        case .dietaryPreferences: return 13 / total
        case .digestiveConditions: return 14 / total
        case .goals: return 15 / total
        // case .summary: return 16 / total
        case .summary: return 1.0
        case .auth: return 1
        }
    }
}

struct OnboardingSelections: Codable {
    var lastFeltGreat: String?
    var heightImperial: HeightImperial?
    var heightMetric: Int?
    var weightImperial: Int?
    var weightMetric: Int?
    var ageGroup: String?
    var gender: String?
    var relatedExperiences: [String]
    var currentGutFeeling: String?
    var commonSymptoms: [String]
    var dietaryPreferences: [String]
    var digestiveConditions: [String]
    var goals: [String]
    
    struct HeightImperial: Codable {
        var feet: Int
        var inches: Int
    }
}

struct OnboardingFlowView: View {
    @State private var currentScreen: OnboardingScreen = .welcome
    @State private var selections = OnboardingSelections(
        lastFeltGreat: nil,
        heightImperial: nil,
        heightMetric: nil,
        weightImperial: nil,
        weightMetric: nil,
        ageGroup: nil,
        gender: nil,
        relatedExperiences: [],
        currentGutFeeling: nil,
        commonSymptoms: [],
        dietaryPreferences: [],
        digestiveConditions: [],
        goals: []
    )
    @State private var isSummaryLoading = true
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentScreen) {
                WelcomeScreen(currentScreen: $currentScreen)
                    .tag(OnboardingScreen.welcome)

                LastFeltGreatScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.lastFeltGreat)
                
                JourneyScreen(currentScreen: $currentScreen)
                    .tag(OnboardingScreen.journey)
                
                FoodLoggingScreen(currentScreen: $currentScreen)
                    .tag(OnboardingScreen.foodLogging)
                
                InsightsScreen(currentScreen: $currentScreen)
                    .tag(OnboardingScreen.insights)
                
                TrackingScreen(currentScreen: $currentScreen)
                    .tag(OnboardingScreen.tracking)
                
                HeightAndWeightScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.heightAndWeight)
                
                AgeGroupScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.ageGroup)
                
                GenderScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.gender)
                
                ExperiencesScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.experiences)
                
                CurrentGutFeelingScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.currentGutFeeling)
                
                CommonSymptomsScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.commonSymptoms)
                
                DietaryPreferencesScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.dietaryPreferences)
                
                DigestiveConditionsScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.digestiveConditions)
                
                GoalsScreen(currentScreen: $currentScreen, selections: $selections)
                    .tag(OnboardingScreen.goals)
                
                SummaryScreen(
                    currentScreen: $currentScreen,
                    selections: $selections,
                    isLoading: $isSummaryLoading
                )
                    .tag(OnboardingScreen.summary)
                
                AuthView()
                    .tag(OnboardingScreen.auth)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .interactiveDismissDisabled()
            // .simultaneousGesture(DragGesture().onChanged { _ in })
            .toolbar {
                if currentScreen != .welcome && currentScreen != .auth && !(currentScreen == .summary && isSummaryLoading) {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withAnimation {
                                navigateToPreviousScreen()
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.gray.opacity(0.1)))
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        ProgressView(value: currentScreen.progressValue)
                            .tint(.primary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .toolbarBackground(.background, for: .navigationBar)
        }
    }
    
    private func navigateToPreviousScreen() {
        switch currentScreen {
        case .welcome: break
        case .lastFeltGreat: currentScreen = .welcome
        case .journey: currentScreen = .lastFeltGreat
        case .foodLogging: currentScreen = .journey
        case .insights: currentScreen = .foodLogging
        case .tracking: currentScreen = .insights
        case .heightAndWeight: currentScreen = .tracking
        case .ageGroup: currentScreen = .heightAndWeight
        case .gender: currentScreen = .ageGroup
        case .experiences: currentScreen = .gender
        case .currentGutFeeling: currentScreen = .experiences
        case .commonSymptoms: currentScreen = .currentGutFeeling
        case .dietaryPreferences: currentScreen = .commonSymptoms
        case .digestiveConditions: currentScreen = .dietaryPreferences
        case .goals: currentScreen = .digestiveConditions
        case .summary: currentScreen = .goals
        case .auth: currentScreen = .summary
        }
    }
    
    private func generateSelectionsJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(selections)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding selections: \(error)")
            return nil
        }
    }
}

struct WelcomeScreen: View {
    @Binding var currentScreen: OnboardingScreen
    
    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.orange)
                .frame(width: 60, height: 60)
                .padding(.top, 60)

            Text("Welcome to Biome")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.7))
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            Text("Your body is speaking. Are you listening?")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: 250)
                .multilineTextAlignment(.center)

            Spacer()

            SharedComponents.primaryButton(title: "Continue") {
                withAnimation {
                    currentScreen = .lastFeltGreat
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

struct LastFeltGreatScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedOption: String?
    
    let options = ["Today", "Last Week", "I Can't Remember"]
    
    var body: some View {
        OnboardingContainerView(
            title: "When was the last time you truly felt great?",
            buttonTitle: "Next",
            isButtonDisabled: selectedOption == nil
        ) {
            selections.lastFeltGreat = selectedOption
            withAnimation {
                currentScreen = .journey
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(options, id: \.self) { option in
                    OptionButton(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
        }
    }
}

struct JourneyScreen: View {
    @Binding var currentScreen: OnboardingScreen
    
    var body: some View {
        OnboardingContainerView(
            title: "Start your gut health journey",
            buttonTitle: "Start My Journey"
        ) {
            withAnimation {
                currentScreen = .foodLogging
            }
        } content: {
            VStack(spacing: 24) {
                Text("Track, analyze, and discover what affects your gut health")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // add an image placeholder here, use my sharedcomponent .card
                SharedComponents.card {
                    VStack(spacing: 12) {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(0..<7) { index in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.primary)
                                        .frame(height: CGFloat([140, 100, 160, 120, 180, 130, 150][index]))
                                    
                                    Text(["S", "M", "T", "W", "T", "F", "S"][index])
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(height: 200)
                        
                        HStack {
                            Text("Your Gut Score")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("Last 7 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                }

                // Text("Join 10,000+ people discovering their gut health patterns")
                //     .font(.headline)
                //     .foregroundStyle(.secondary)
                //     .multilineTextAlignment(.center)
            }
        }
    }
}

struct FoodLoggingScreen: View {
    @Binding var currentScreen: OnboardingScreen
    
    var body: some View {
        OnboardingContainerView(
            title: "Here's how Biome works",
            buttonTitle: "Next"
        ) {
            withAnimation {
                currentScreen = .insights
            }
        } content: {
            VStack(spacing: 24) {
                Text("Just snap a quick photo of your meal")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Image("food")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct InsightsScreen: View {
    @Binding var currentScreen: OnboardingScreen
    
    // Sample data
    private let tips = [
        Tip(tip: "Add fermented foods", 
            explanation: "Incorporating fermented foods like kimchi or sauerkraut can enhance the probiotic content, improving gut flora.", 
            emoji: "🥬"),
        Tip(tip: "Include more fiber-rich foods", 
            explanation: "Boost the meal with high-fiber foods such as chia seeds or flaxseed to promote digestive health.", 
            emoji: "🌾"),
        Tip(tip: "Limit added sugars", 
            explanation: "Avoid creamy dressings with added sugars which can disrupt gut balance; opt for olive oil and vinegar instead.", 
            emoji: "🥗")
    ]
    
    private let symptoms = [
        Symptom(symptom: "Bloating", 
                explanation: "High fiber from legumes and vegetables can cause bloating, especially if you're not used to it.", 
                emoji: "🤰"),
        Symptom(symptom: "Indigestion", 
                explanation: "The combination of high fiber and rich yogurt may lead to digestive discomfort in sensitive individuals.", 
                emoji: "🤢"),
        Symptom(symptom: "Gas", 
                explanation: "Legumes can produce gas during digestion, leading to discomfort for some people.", 
                emoji: "💨")
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "We give you insights on how the food impacts you",
            buttonTitle: "Next"
        ) {
            withAnimation {
                currentScreen = .tracking
            }
        } content: {
            VStack(spacing: 24) {
                GutHealthGauge(score: 85)
                
                if !symptoms.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SharedComponents.titleWithDivider("Symptoms", color: .primary.opacity(0.5))
                        
                        VStack(spacing: 24) {
                            ForEach(symptoms) { symptom in
                                HStack(alignment: .top, spacing: 16) {
                                    Text(symptom.emoji)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(symptom.symptom)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        SharedComponents.card {
                                            Text(symptom.explanation)
                                                .font(.subheadline)
                                                .foregroundColor(.primary.opacity(0.5))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !tips.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SharedComponents.titleWithDivider("Tips", color: .primary.opacity(0.5))
                        
                        VStack(spacing: 24) {
                            ForEach(tips) { tip in
                                HStack(alignment: .top, spacing: 16) {
                                    Text(tip.emoji)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(tip.tip)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        SharedComponents.card {
                                            Text(tip.explanation)
                                                .font(.subheadline)
                                                .foregroundColor(.primary.opacity(0.5))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 24)
        }
    }
}

struct TrackingScreen: View {
    @Binding var currentScreen: OnboardingScreen
    
    let trackingOptions = [
        (emoji: "😊", label: "Mood"),
        (emoji: "🤒", label: "Symptoms"),
        (emoji: "😰", label: "Stress Levels"),
        (emoji: "🫠", label: "Stool")
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "Biome can also track your",
            buttonTitle: "Next"
        ) {
            withAnimation {
                currentScreen = .heightAndWeight
            }
        } content: {
            VStack(spacing: 24) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(trackingOptions, id: \.label) { option in
                        SharedComponents.card {
                            VStack(spacing: 8) {
                                Text(option.emoji)
                                    .font(.system(size: 32))
                                Text(option.label)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Text("The more you log, the better we understand you")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct HeightAndWeightScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var isMetric = false
    @State private var feet: Int = 5
    @State private var inches: Int = 6
    @State private var centimeters: Int = 167
    @State private var pounds: Int = 120
    @State private var kilograms: Int = 54
    
    var body: some View {
        OnboardingContainerView(
            title: "What's your height & weight?",
            buttonTitle: "Next"
        ) {
            if isMetric {
                selections.heightMetric = centimeters
                selections.weightMetric = kilograms
            } else {
                selections.heightImperial = OnboardingSelections.HeightImperial(feet: feet, inches: inches)
                selections.weightImperial = pounds
            }
            currentScreen = .ageGroup
        } content: {
            VStack(spacing: 32) {
                // Metric Toggle
                HStack {
                    Text("Imperial")
                        .font(.headline)
                        .foregroundColor(isMetric ? .secondary : .primary)
                    Toggle("", isOn: $isMetric)
                        .labelsHidden()
                        .toggleStyle(CircleToggleStyle())
                    Text("Metric")
                        .font(.headline)
                        .foregroundColor(isMetric ? .primary : .secondary)
                }
                
                HStack(spacing: 24) {
                    if !isMetric {
                        // Imperial Height Section
                        VStack(spacing: 8) {
                            Text("Height")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 8) {
                                // Feet Picker
                                Picker("Feet", selection: $feet) {
                                    ForEach(2...7, id: \.self) { foot in
                                        Text("\(foot) ft")
                                            .font(.subheadline)
                                            .tag(foot)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .compositingGroup()
                                .clipped()
                                
                                // Inches Picker
                                Picker("Inches", selection: $inches) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch) in")
                                            .font(.subheadline)
                                            .tag(inch)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .compositingGroup()
                                .clipped()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Imperial Weight Section
                        VStack(spacing: 8) {
                            Text("Weight")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Pounds", selection: $pounds) {
                                ForEach(50...400, id: \.self) { pound in
                                    Text("\(pound) lbs")
                                        .font(.subheadline)
                                        .tag(pound)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .compositingGroup()
                            .clipped()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // Metric Height Section
                        VStack(spacing: 8) {
                            Text("Height")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Centimeters", selection: $centimeters) {
                                ForEach(100...250, id: \.self) { cm in
                                    Text("\(cm) cm")
                                        .font(.subheadline)
                                        .tag(cm)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .compositingGroup()
                            .clipped()
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Metric Weight Section
                        VStack(spacing: 8) {
                            Text("Weight")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("Kilograms", selection: $kilograms) {
                                ForEach(30...200, id: \.self) { kg in
                                    Text("\(kg) kg")
                                        .font(.subheadline)
                                        .tag(kg)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .compositingGroup()
                            .clipped()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
        }
    }
}

// Custom Circle Toggle Style
struct CircleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(.white)
                    .shadow(radius: 1)
                    .frame(width: 26, height: 26)
                    .offset(x: configuration.isOn ? 10 : -10)
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

struct AgeGroupScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedAgeGroup: String?
    
    let ageGroups = ["Under 18", "18-24", "25-34", "35-44", "45-54", "55+"]
    
    var body: some View {
        OnboardingContainerView(
            title: "What's your age?",
            buttonTitle: "Next",
            isButtonDisabled: selectedAgeGroup == nil
        ) {
            selections.ageGroup = selectedAgeGroup
            withAnimation {
                currentScreen = .gender
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(ageGroups, id: \.self) { group in
                    OptionButton(
                        option: group,
                        isSelected: selectedAgeGroup == group
                    ) {
                        selectedAgeGroup = group
                    }
                }
            }
        }
    }
}

struct GenderScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedGender: String?
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        OnboardingContainerView(
            title: "Choose your gender",
            buttonTitle: "Next",
            isButtonDisabled: selectedGender == nil
        ) {
            selections.gender = selectedGender
            withAnimation {
                currentScreen = .experiences
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(genders, id: \.self) { gender in
                    OptionButton(
                        option: gender,
                        isSelected: selectedGender == gender
                    ) {
                        selectedGender = gender
                    }
                }
            }
        }
    }
}

struct ExperiencesScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedGoals: Set<String> = []
    
    let goals = [
        "I often feel tired after eating",
        "My energy crashes in the afternoon",
        "I've tried diets that didn't work",
        "My mood and digestion seem connected",
        "I want to improve my gut health"
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "Which of these experiences\ndo you relate to?",
            buttonTitle: "Next",
            isButtonDisabled: selectedGoals.isEmpty
        ) {
            selections.relatedExperiences = Array(selectedGoals)
            withAnimation {
                currentScreen = .currentGutFeeling
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(goals, id: \.self) { goal in
                    OptionButton(
                        option: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
        }
    }
}

struct CurrentGutFeelingScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedFeeling: String?
    
    let feelings = [
        ("😊  Great", "Great"),
        ("😐  Okay", "Okay"),
        ("😟  Not so good", "Not so good"),
        ("😫  Terrible", "Terrible")
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "Right now, my gut feels...",
            buttonTitle: "Next",
            isButtonDisabled: selectedFeeling == nil
        ) {
            selections.currentGutFeeling = selectedFeeling
            withAnimation {
                currentScreen = .commonSymptoms
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(feelings, id: \.0) { feeling in
                    OptionButton(
                        option: feeling.0,
                        isSelected: selectedFeeling == feeling.1
                    ) {
                        selectedFeeling = feeling.1
                    }
                }
            }
        }
    }
}

struct CommonSymptomsScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedSymptoms: Set<String> = []
    
    let symptoms = [
        "Bloating", "Gas", "Abdominal pain",
        "Constipation", "Diarrhea", "Heartburn", "Nausea"
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "What symptoms do you commonly experience?",
            buttonTitle: "Next"
        ) {
            selections.commonSymptoms = Array(selectedSymptoms)
            withAnimation {
                currentScreen = .dietaryPreferences
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(symptoms, id: \.self) { symptom in
                    OptionButton(
                        option: symptom,
                        isSelected: selectedSymptoms.contains(symptom)
                    ) {
                        if selectedSymptoms.contains(symptom) {
                            selectedSymptoms.remove(symptom)
                        } else {
                            selectedSymptoms.insert(symptom)
                        }
                    }
                }
            }
        }
    }
}

struct DietaryPreferencesScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedDiets: Set<String> = []
    
    let diets = [
        "Classic", "Gluten-free", "Dairy-free",
        "Vegetarian/Vegan", "Keto", "Low FODMAP"
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "Are you following any specific diets?",
            buttonTitle: "Next"
        ) {
            selections.dietaryPreferences = Array(selectedDiets)
            withAnimation {
                currentScreen = .digestiveConditions
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(diets, id: \.self) { diet in
                    OptionButton(
                        option: diet,
                        isSelected: selectedDiets.contains(diet)
                    ) {
                        if selectedDiets.contains(diet) {
                            selectedDiets.remove(diet)
                        } else {
                            selectedDiets.insert(diet)
                        }
                    }
                }
            }
        }
    }
}

struct DigestiveConditionsScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedConditions: Set<String> = []
    
    let conditions = [
        "IBS", "Celiac Disease", "Crohn's Disease",
        "Ulcerative Colitis", "GERD", "Other", "None"
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "Do you have any diagnosed digestive conditions?",
            buttonTitle: "Next"
        ) {
            selections.digestiveConditions = Array(selectedConditions)
            withAnimation {
                currentScreen = .goals
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(conditions, id: \.self) { condition in
                    OptionButton(
                        option: condition,
                        isSelected: selectedConditions.contains(condition)
                    ) {
                        if selectedConditions.contains(condition) {
                            selectedConditions.remove(condition)
                        } else {
                            selectedConditions.insert(condition)
                        }
                    }
                }
            }
        }
    }
}

struct GoalsScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @State private var selectedGoals: Set<String> = []
    
    let goals = [
        "Identify food triggers",
        "Improve regular bowel movements",
        "Manage existing condition",
        "Improve overall gut health",
        "Track mood-gut connection",
        "Reduce bloating",
    ]
    
    var body: some View {
        OnboardingContainerView(
            title: "What's your main reason for using Biome?",
            buttonTitle: "Next",
            isButtonDisabled: selectedGoals.isEmpty
        ) {
            selections.goals = Array(selectedGoals)
            withAnimation {
                currentScreen = .summary
            }
        } content: {
            VStack(spacing: 16) {
                ForEach(goals, id: \.self) { goal in
                    OptionButton(
                        option: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
        }
    }
}

struct Risk: Identifiable {
    let id = UUID()
    let risk: String
    let explanation: String
    let emoji: String
}

struct Recommendation: Identifiable {
    let id = UUID()
    let recommendation: String
    let explanation: String
    let emoji: String
}

struct LineGauge: View {
    let score: Double
    let maxScore: Double = 100
    @State private var animatedProgress: Double = 0
    @State private var showLabel: Bool = false
    
    private var progress: Double {
        score / maxScore
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Text("Your gut health diagnosis")
            //     .font(.title2)
            //     .fontWeight(.semibold)
            //     .multilineTextAlignment(.center)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Full gradient background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "#FF4B4B"), location: 0.0),
                                    .init(color: Color(hex: "#FF9049"), location: 0.3),
                                    .init(color: Color(hex: "#FFD749"), location: 0.6),
                                    .init(color: Color(hex: "#4BFF4B"), location: 1.0),
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 16)
                    
                    let position = geometry.size.width * animatedProgress
                    
                    Group {
                        // White line indicator
                        Rectangle()
                            .fill(.background)
                            .frame(width: 3, height: 24)
                            .position(x: position, y: 8)

                        // Top triangle indicator
                        Triangle()
                            .rotation(.degrees(180))
                            .fill(.primary)
                            .frame(width: 12, height: 8)
                            .position(x: position, y: -8)
                        
                        // Bottom triangle indicator
                        Triangle()
                            .fill(.primary)
                            .frame(width: 12, height: 8)
                            .position(x: position, y: 24)
                    }
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12) // Add padding for the triangles
            
            Text(scoreLabel(score))
                .font(.headline)
                .foregroundColor(.secondary)
                .opacity(showLabel ? 1 : 0)
                .animation(.easeIn.delay(1.2), value: showLabel)
        }
        .onAppear {
            if score != 0 {
                startAnimationSequence()
            }
        }
        .onChange(of: score) { _ in
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        animatedProgress = 0
        showLabel = false
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedProgress = progress
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLabel = true
        }
    }
    
    private func scoreLabel(_ score: Double) -> String {
        switch score {
        case 0 ..< 30:
            return "Critical Attention Needed"
        case 30 ..< 60:
            return "Needs Improvement"
        case 60 ..< 80:
            return "Moderately Healthy"
        default:
            return "Optimal Health"
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SummaryScreen: View {
    @Binding var currentScreen: OnboardingScreen
    @Binding var selections: OnboardingSelections
    @Binding var isLoading: Bool
    @State private var gutHealthScore: Int?
    @State private var gutHealthDiagnosis: String?
    @State private var scoreExplanation: String?
    @State private var risks: [Risk] = []
    @State private var recommendations: [Recommendation] = []

    @State private var currentLoadingMessage = "Analyzing your data..."

    private func startLoadingSequence() {
        let messages = ["Analyzing your data...",
                    "Diagnosing your gut health...",
                    "Almost there..."]
        
        // Change message every 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentLoadingMessage = messages[1]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                currentLoadingMessage = messages[2]
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                // if isLoading {
                //    GeometryReader { geometry in
                //         VStack {
                //             Spacer()
                //             ProgressView("Analyzing...")
                //             Spacer()
                //         }
                //         .frame(width: geometry.size.width)
                //         .frame(minHeight: geometry.frame(in: .global).height)
                //     }
                // } else {
                LazyVStack(spacing: 24) {
                    if !isLoading {
                        Text("Your Gut Health Diagnosis")
                                .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        if let score = gutHealthScore {
                            LineGauge(score: Double(score))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 24)
                        }
                        
                        // if let explanation = scoreExplanation {
                        //     Text(explanation)
                        //         .font(.body)
                        //         .foregroundStyle(.secondary)
                        //         .multilineTextAlignment(.center)
                        //         .frame(maxWidth: .infinity, alignment: .center)
                        // }
                        
                        if !risks.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                SharedComponents.titleWithDivider("Risk Assessment", color: .primary.opacity(0.5))
                                
                                VStack(spacing: 24) {
                                    ForEach(risks) { risk in
                                        HStack(alignment: .top, spacing: 16) {
                                            Text(risk.emoji)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            
                                            VStack(alignment: .leading, spacing: 16) {
                                                Text(risk.risk)
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                SharedComponents.card {
                                                    Text(risk.explanation)
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary.opacity(0.5))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if !recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                SharedComponents.titleWithDivider("Recommendations", color: .primary.opacity(0.5))
                                
                                VStack(spacing: 24) {
                                    ForEach(recommendations) { recommendation in
                                        HStack(alignment: .top, spacing: 16) {
                                            Text(recommendation.emoji)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            
                                            VStack(alignment: .leading, spacing: 16) {
                                                Text(recommendation.recommendation)
                                                    .font(.title3)
                                                    .fontWeight(.semibold)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                SharedComponents.card {
                                                    Text(recommendation.explanation)
                                                        .font(.subheadline)
                                                        .foregroundColor(.primary.opacity(0.5))
                                                        .fixedSize(horizontal: false, vertical: true)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 24) // Add padding for button
                // }
            }
            .overlay {
                if isLoading {
                    VStack(alignment: .center, spacing: 24) {
                        // Use a @State variable to track the current message
                        let messages = ["Analyzing your data...",
                                    "Diagnosing your gut health...",
                                    "Almost there..."]
                        
                        Text("We're setting up everything for you")
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        Text(currentLoadingMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        ProgressView()
                    }
                    .onAppear {
                        // Start the sequence when the overlay appears
                        startLoadingSequence()
                    }
                }
            }

            if !isLoading {
                // Fixed button at bottom
                VStack {
                    SharedComponents.primaryButton(title: "Get Started") {
                        withAnimation {
                            currentScreen = .auth
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .background(.background)
            }
        }
        .onAppear {
            if gutHealthScore == nil {
                analyzeOnboardingData()
            }
        }
    }
    
    private func analyzeOnboardingData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let jsonData = try? encoder.encode(selections),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        Task {
            do {
                let analysis = try await OpenAIService().onboardingCompletion(onboardingData: jsonString)
                
                DispatchQueue.main.async {
                    self.gutHealthScore = analysis["gutHealthScore"] as? Int
                    self.gutHealthDiagnosis = analysis["gutHealthDiagnosis"] as? String
                    self.scoreExplanation = analysis["scoreExplanation"] as? String
                    
                    // Handle risks as either objects or strings
                    if let risks = analysis["riskAssessment"] as? [[String: Any]] {
                        self.risks = risks.compactMap { risk in
                            guard let riskTitle = risk["risk"] as? String,
                                  let explanation = risk["explanation"] as? String,
                                  let emoji = risk["emoji"] as? String else {
                                return nil
                            }
                            return Risk(risk: riskTitle, explanation: explanation, emoji: emoji)
                        }
                    } else if let risks = analysis["riskAssessment"] as? [String] {
                        // Convert simple strings to Risk objects
                        self.risks = risks.map { riskString in
                            Risk(
                                risk: riskString,
                                explanation: "This risk factor requires attention and monitoring.",
                                emoji: "⚠️"
                            )
                        }
                    }
                    
                    // Handle recommendations as either objects or strings
                    if let recommendations = analysis["recommendations"] as? [[String: Any]] {
                        self.recommendations = recommendations.compactMap { recommendation in
                            guard let rec = recommendation["recommendation"] as? String,
                                  let explanation = recommendation["explanation"] as? String,
                                  let emoji = recommendation["emoji"] as? String else {
                                return nil
                            }
                            return Recommendation(
                                recommendation: rec,
                                explanation: explanation,
                                emoji: emoji
                            )
                        }
                    } else if let recommendations = analysis["recommendations"] as? [String] {
                        // Convert simple strings to Recommendation objects
                        self.recommendations = recommendations.map { recString in
                            Recommendation(
                                recommendation: recString,
                                explanation: "Follow this recommendation to improve your gut health.",
                                emoji: "💡"
                            )
                        }
                    }
                    
                    self.isLoading = false
                }
            } catch {
                print("Error analyzing onboarding data:", error)
                print("Error details:", String(describing: error))
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

struct OptionButton: View {
    let option: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(option)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(isSelected ? Color.primary : Color.primary.opacity(0.1))
                .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : .primary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
struct OnboardingContainerView<Content: View>: View {
    let title: String
    let content: Content
    let buttonTitle: String
    let buttonAction: () -> Void
    let isButtonDisabled: Bool
    
    init(
        title: String,
        buttonTitle: String,
        isButtonDisabled: Bool = false,
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.isButtonDisabled = isButtonDisabled
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    content
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 24) // Add padding for button
            }
            
            // Fixed button at bottom
            VStack {
                SharedComponents.primaryButton(title: buttonTitle) {
                    buttonAction()
                }
                .opacity(isButtonDisabled ? 0.5 : 1)
                .disabled(isButtonDisabled)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(.background)
        }
    }
}
