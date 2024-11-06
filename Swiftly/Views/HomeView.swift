import RevenueCat
import StoreKit
import SuperwallKit
import SwiftUI

struct HomeView: View {
    let items = [
        LogItem(id: 1, title: "Food and Drink", description: "What have you eaten today?"),
        LogItem(id: 2, title: "Mood", description: "How do you feel?"),
        LogItem(id: 3, title: "Symptoms", description: "What's bothering you?"),
        LogItem(id: 4, title: "Stress Levels", description: "How are your stress levels?"),
        LogItem(id: 5, title: "Stool", description: "Any bowel movements?"),
    ]
    @State private var currentIndex: Int = 0
    @State private var showFoodView = false
    @State private var showMoodView = false
    @State private var showSymptomsView = false
    @State private var showStressLevelsView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .padding(.vertical, 24)

                Text("Today")
                    .font(.headline)
                    .fontWeight(.medium)

                Carousel(spacing: 16, trailingSpace: 64, index: $currentIndex, items: items) { item in
                    SharedComponents.card {
                        VStack(alignment: .center, spacing: 16) {
                            Spacer()

                            Text(item.title)
                                .font(.headline)
                                .multilineTextAlignment(.center)

                            Text(item.description)
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.5))
                                .multilineTextAlignment(.center)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .onTapGesture {
                        if item.id == 1 {
                            showFoodView.toggle()
                        } else if item.id == 2 {
                            showMoodView.toggle()
                        } else if item.id == 3 {
                            showSymptomsView.toggle()
                        } else if item.id == 4 {
                            showStressLevelsView.toggle()
                        }
                    }
                }
                .frame(height: 180)

                Spacer()

                // NavigationLink(destination: ChatView()) {
                //     SharedComponents.card {
                //         VStack(alignment: .leading, spacing: 8) {
                //             Text("Chat")
                //                 .font(.headline)
                //         }
                //     }
                // }
                // .padding(.horizontal)

                // NavigationLink(destination: VisionView()) {
                //     SharedComponents.card {
                //         VStack(alignment: .leading, spacing: 8) {
                //             Text("Vision")
                //                 .font(.headline)
                //         }
                //     }
                // }
                // .padding(.horizontal)

                // NavigationLink(destination: CalendarView()) {
                //     SharedComponents.card {
                //         VStack(alignment: .leading, spacing: 8) {
                //             Text("Calendar")
                //                 .font(.headline)
                //         }
                //     }
                // }

                // NavigationLink(destination: ArticleView()) {
                //     SharedComponents.card {
                //         VStack(alignment: .leading, spacing: 8) {
                //             Text("Articles")
                //                 .font(.headline)
                //         }
                //     }
                // }
                // .padding(.horizontal)
            }
            .sheet(isPresented: $showFoodView) {
                NavigationStack {
                    VisionView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Meal Log")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                        }
                }
            }
            .sheet(isPresented: $showMoodView) {
                NavigationStack {
                    MoodView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Mood Log")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                        }
                }
            }
            .sheet(isPresented: $showSymptomsView) {
                NavigationStack {
                    SymptomsView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Symptoms Log")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                        }
                }
            }
            .sheet(isPresented: $showStressLevelsView) {
                NavigationStack {
                    StressLevelsView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Stress & Anxiety Log")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                            }
                        }
                }
            }
        }
        // .padding()
    }
}

struct Carousel<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int

    init(
        spacing: CGFloat = 16,
        trailingSpace: CGFloat = 100,
        index: Binding<Int>,
        items: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        _index = index
        self.content = content
    }

    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0

    var body: some View {
        GeometryReader { proxy in
            let width = abs(proxy.size.width - (trailingSpace - spacing))
            let adjustmentWidth = (trailingSpace / 2) - spacing

            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: abs(proxy.size.width - trailingSpace))
                }
            }
            .padding(.horizontal, 16)
            .offset(x: (CGFloat(currentIndex) * -width) + adjustmentWidth + offset) // Always apply adjustmentWidth
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    }
                    .onChanged { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    }
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
}

struct LogItem: Identifiable {
    let id: Int
    let title: String
    let description: String
}

#Preview {
    HomeView()
}
