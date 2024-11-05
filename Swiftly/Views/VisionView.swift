import Foundation
import SwiftUI

struct VisionView: View {
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?

    @State private var gutHealthScore: Int?
    @State private var tips: [Tip] = []
    @State private var symptoms: [Symptom] = []
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if isProcessing {
                    ProgressView("Analyzing...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let score = gutHealthScore {
                    ScrollView {
                        VStack(spacing: 24) {
                            GutHealthGauge(score: Double(score))

                            if !tips.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    SharedComponents.titleWithDivider("Tips", color: .primary.opacity(0.5))

                                    VStack(spacing: 24) {
                                        ForEach(tips) { tip in
                                            HStack(alignment: .top, spacing: 16) {
                                                Text(tip.emoji)
                                                    .font(.headline)

                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text(tip.tip)
                                                        .font(.headline)
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

                            if !symptoms.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    SharedComponents.titleWithDivider("Symptoms", color: .primary.opacity(0.5))

                                    VStack(spacing: 24) {
                                        ForEach(symptoms) { symptom in
                                            HStack(alignment: .top, spacing: 16) {
                                                Text(symptom.emoji)
                                                    .font(.headline)

                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text(symptom.symptom)
                                                        .font(.headline)
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
                        }
                        .padding()
                    }
                } else {
                    VStack {
                        Spacer()
                        SharedComponents.roundButton(title: "Upload Food/Drink") {
                            showImagePicker.toggle()
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Gut Score")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $inputImage, sourceType: .photoLibrary)
            }
            .onChange(of: inputImage) { _ in
                analyzeSelectedImage()
            }
        }
    }

    private func analyzeSelectedImage() {
        guard let image = inputImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let base64Image = imageData.base64EncodedString()

        isProcessing = true // Start processing

        Task {
            do {
                let analysis = try await OpenAIService().analyzeImage(base64Image: base64Image)
                DispatchQueue.main.async {
                    self.gutHealthScore = analysis["gutHealthScore"] as? Int
                    self.tips = parseTips(analysis["tips"] as? [[String: Any]] ?? [])
                    self.symptoms = parseSymptoms(analysis["symptoms"] as? [[String: Any]] ?? [])
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

    struct Tip: Identifiable {
        let id = UUID()
        let tip: String
        let explanation: String
        let emoji: String
    }

    struct Symptom: Identifiable {
        let id = UUID()
        let symptom: String
        let explanation: String
        let emoji: String
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
