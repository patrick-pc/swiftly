import SwiftUI

struct BottomNavigationView: View {
    @State private var selectedTab = 2

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HistoryView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Logs")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                        }
                    }
            }
            .tabItem {
                // Label("Logs", systemImage: "calendar")
                Image(systemName: "calendar")
            }
            .tag(0)

            NavigationStack {
                ArticleView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("For Your Gut")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                        }
                    }
            }
            .tabItem {
                // Label("Learn", systemImage: "book.pages.fill")
                Image(systemName: "book.pages.fill")
            }
            .tag(1)

            NavigationStack {
                HomeView()
            }
            .tabItem {
                // Label("Insights", systemImage: "square.grid.2x2.fill")
                Image(systemName: "plus.circle.fill")
            }
            .tag(2)

            NavigationStack {
                InsightsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Insights")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                        }
                    }
            }
            .tabItem {
                // Label("Insights", systemImage: "square.grid.2x2.fill")
                Image(systemName: "square.grid.2x2.fill")
            }
            .tag(3)

            NavigationStack {
                SettingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Settings")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                        }
                    }
            }
            .tabItem {
                // Label("Settings", systemImage: "gearshape.fill")
                Image(systemName: "gearshape.fill")
            }
            .tag(4)
        }
        // .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Enable swipe gestures
        // .safeAreaInset(edge: .bottom) {
        //     HStack(spacing: 24) {
        //         Spacer()

        //         Button(action: {
        //             selectedTab = 0
        //         }) {
        //             Image(systemName: "flame.fill")
        //                 .padding(12)
        //                 .foregroundStyle(.primary)
        //                 .background(.primary.opacity(0.1))
        //         }
        //         .clipShape(Circle())

        //         Button(action: {
        //             selectedTab = 1
        //         }) {
        //             Image(systemName: "swift")
        //                 .font(.title2)
        //                 .padding(18)
        //                 .foregroundStyle(.background)
        //                 .background(.primary)
        //         }
        //         .clipShape(Circle())

        //         Button(action: {
        //             selectedTab = 2
        //         }) {
        //             Image(systemName: "person.fill")
        //                 .padding(12)
        //                 .foregroundStyle(.primary)
        //                 .background(.primary.opacity(0.1))
        //         }
        //         .clipShape(Circle())

        //         Spacer()
        //     }
        //     .padding(.top, 6)
        //     .padding(.bottom, 12)
        //     .background(Color(.systemBackground))
        // }
        .tint(.primary)
    }
}

#Preview {
    BottomNavigationView()
}
