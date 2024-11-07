//
//  GutScoreView.swift
//  Swiftly
//
//  Created by Patrick on 11/6/24.
//

import SwiftUI

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

struct GutScoreView: View {
    @Environment(\.dismiss) var dismiss
    let isProcessing: Bool
    let gutHealthScore: Int?
    let tips: [Tip]
    let symptoms: [Symptom]
    
    var body: some View {
        NavigationView {
            Group {
                if isProcessing {
                    VStack {
                        Spacer()
                        ProgressView("Analyzing...")
                        Spacer()
                    }
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
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Gut Score")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
            }
        }
    }
}
