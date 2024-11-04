import RevenueCat
import StoreKit
import SuperwallKit
import SwiftUI

struct HomeView: View {
    let items = [CardItem(id: 1, title: "Card 1"), CardItem(id: 2, title: "Card 2"), CardItem(id: 3, title: "Card 3")]
    @State private var currentIndex: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Carousel(spacing: 16, trailingSpace: 64, index: $currentIndex, items: items) { item in
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(item.title)
                                .font(.title2)
                                .fontWeight(.semibold)

                            Rectangle()
                                .fill(Color.primary.opacity(0.1))
                                .frame(height: 120)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 400)

                NavigationLink(destination: ChatView()) {
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Chat")
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)

                NavigationLink(destination: VisionView()) {
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vision")
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)

                // NavigationLink(destination: CalendarView()) {
                //     SharedComponents.card {
                //         VStack(alignment: .leading, spacing: 8) {
                //             Text("Calendar")
                //                 .font(.headline)
                //         }
                //     }
                // }

                NavigationLink(destination: ArticleView()) {
                    SharedComponents.card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Articles")
                                .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)
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
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustmentWidth = (trailingSpace / 2) - spacing

            HStack(spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
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

struct CardItem: Identifiable {
    let id: Int
    let title: String
}

#Preview {
    HomeView()
}
