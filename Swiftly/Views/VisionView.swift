import Foundation
import SwiftUI

struct VisionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mainVM = MainViewModel()
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var currentDate = Date()
    @State private var mealDescription: String = ""
    @State private var selectedMealType: String?
    
    @State private var showGutScore = false
    @State private var gutHealthScore: Int?
    @State private var tips: [Tip] = []
    @State private var symptoms: [Symptom] = []
    @State private var isProcessing = true
    
    // Add a timer to keep the time updated
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Replace the mealTypes array
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
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

            // Meal Type Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Meal Type")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(mealTypes, id: \.self) { mealType in
                            MealTypeToggleButton(
                                title: mealType,
                                isSelected: selectedMealType == mealType,
                                action: { selectedMealType = mealType }
                            )
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .frame(height: 44, alignment: .top)
            }
            .padding(.horizontal)

            if gutHealthScore == nil {
                // Camera and Photos buttons
                VStack(spacing: 12) {
                    // Camera Button
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.headline)
                                Text("Camera")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundStyle(.primary.opacity(0.5))
                        }
                        .padding()
                        .foregroundStyle(.primary)
                        .background(.primary.opacity(0.1))
                        .cornerRadius(64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Photos Button
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.fill")
                                    .font(.headline)
                                Text("Photos")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundStyle(.primary.opacity(0.5))
                        }
                        .padding()
                        .foregroundStyle(.primary)
                        .background(.primary.opacity(0.1))
                        .cornerRadius(64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Meal Description section
            VStack(alignment: .leading, spacing: 8) {
                Text("What did you eat? (Optional)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Describe your meal", text: $mealDescription, axis: .vertical)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary.opacity(0.3))
                    .lineLimit(mealDescription.isEmpty ? 1...1 : 1...3)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal)
            
            if let score = gutHealthScore {
                // Gut Health Score section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gut Health Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(score)/100")
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer()
                
                // Done button
                Button(action: {
                    saveMealLog()
                }) {
                    Text("Done")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(selectedMealType != nil ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(selectedMealType == nil)
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                Spacer()
                
                Button(action: {
                    isProcessing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showGutScore = true
                        analyzeSelectedImage()
                    }
                }) {
                    Text("Analyze")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(!mealDescription.isEmpty ? Color.primary : Color.primary.opacity(0.3))
                        .foregroundStyle(.background)
                        .cornerRadius(64)
                }
                .disabled(mealDescription.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showGutScore) {
            GutScoreView(
                isProcessing: isProcessing,
                gutHealthScore: gutHealthScore,
                tips: tips,
                symptoms: symptoms
            )
        }
        .onChange(of: inputImage) { _ in
            if let _ = inputImage {
                isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showGutScore = true
                    analyzeSelectedImage()
                }
            }
        }
    }
    
    private func saveMealLog() {
        let symptomDataArray = symptoms.map { symptom in
            MealSymptomData(
                symptom: symptom.symptom,
                explanation: symptom.explanation
            )
        }
        
        let tipDataArray = tips.map { tip in
            MealTipData(
                tip: tip.tip,
                explanation: tip.explanation
            )
        }
        
        let logData = LogData(
            gutScore: gutHealthScore,
            mealType: selectedMealType,
            mealDescription: mealDescription,
            mealTips: tipDataArray,
            mealSymptoms: symptomDataArray
        )
        
        mainVM.addLog(
            type: "Meal",
            note: "", // Empty string for now
            data: logData
        )
        
        dismiss()
    }
    
    private func analyzeSelectedImage() {
        guard let image = inputImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let base64Image = imageData.base64EncodedString()
        
        Task {
            do {
                let analysis = try await OpenAIService().analyzeImage(base64Image: base64Image)
                DispatchQueue.main.async {
                    self.gutHealthScore = analysis["gutHealthScore"] as? Int
                    self.tips = parseTips(analysis["tips"] as? [[String: Any]] ?? [])
                    self.symptoms = parseSymptoms(analysis["symptoms"] as? [[String: Any]] ?? [])
                    if let description = analysis["mealDescription"] as? String {
                        self.mealDescription = description
                    }
                    self.isProcessing = false
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func parseTips(_ tipsData: [[String: Any]]) -> [Tip] {
        tipsData.compactMap { dict in
            if let tip = dict["tip"] as? String,
               let explanation = dict["explanation"] as? String,
               let emoji = dict["emoji"] as? String
            {
                return Tip(tip: tip, explanation: explanation, emoji: emoji)
            }
            return nil
        }
    }
    
    private func parseSymptoms(_ symptomsData: [[String: Any]]) -> [Symptom] {
        symptomsData.compactMap { dict in
            if let symptom = dict["symptom"] as? String,
               let explanation = dict["explanation"] as? String,
               let emoji = dict["emoji"] as? String
            {
                return Symptom(symptom: symptom, explanation: explanation, emoji: emoji)
            }
            return nil
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) {}
}

// Animatable modifier for the score number
struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double

    var animatableData: Double {
        get { number }
        set { number = newValue }
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                Text("\(Int(number))")
                    .font(.system(size: 54, weight: .bold))
            )
    }
}

// Convenience extension for the animatable number
extension View {
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}

struct GutHealthGauge: View {
    let score: Double
    let maxScore: Double = 100

    // Animation states
    @State private var animatedProgress: Double = 0
    @State private var showLabel: Bool = false
    @State private var animatedScore: Double = 0

    // Calculate the progress percentage
    private var progress: Double {
        score / maxScore
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .trim(from: 0.0, to: 0.8)
                .rotation(Angle(degrees: 126))
                .stroke(
                    Color.gray.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 16,
                        lineCap: .round
                    )
                )
                .frame(width: 250, height: 250)

            // Progress indicator with gradient
            Circle()
                .trim(from: 0.0, to: animatedProgress * 0.8)
                .rotation(Angle(degrees: 126))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#FF4B4B"), location: 0.0),
                            .init(color: Color(hex: "#FF9049"), location: 0.3),
                            .init(color: Color(hex: "#FFD749"), location: 0.6),
                            .init(color: Color(hex: "#4BFF4B"), location: 1.0),
                        ]),
                        center: .center,
                        startAngle: .degrees(126),
                        endAngle: .degrees(360 + 54)
                    ),
                    style: StrokeStyle(
                        lineWidth: 16,
                        lineCap: .round
                    )
                )
                .frame(width: 250, height: 250)
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedProgress)

            // Score display with animations
            VStack {
                // Animated number
                Color.clear
                    .frame(height: 60)
                    .animatingOverlay(for: animatedScore)

                // Label with fade animation
                Text(scoreLabel(score))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
                    .opacity(showLabel ? 1 : 0)
                    .animation(.easeIn.delay(1.2), value: showLabel)
            }
        }
        // .padding()
        .onAppear {
            startAnimationSequence()
        }
        .onChange(of: score) { _ in
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // Reset states
        animatedProgress = 0
        animatedScore = 0
        showLabel = false

        // Animate progress and score
        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
            animatedProgress = progress
            animatedScore = score
        }

        // Show label after progress animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLabel = true
        }
    }

    private func scoreLabel(_ score: Double) -> String {
        switch score {
            case 0 ..< 30:
                return "Harmful"
            case 30 ..< 60:
                return "Poor"
            case 60 ..< 80:
                return "Good"
            default:
                return "Excellent"
        }
    }
}

// Update MealTypeToggleButton struct
struct MealTypeToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 16)
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
