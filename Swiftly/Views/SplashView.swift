import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isActive = false

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            HStack(spacing: 8) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.orange)

                Text("biome")
                    .foregroundColor(foregroundColor)
            }
            .font(.title3)
            .fontWeight(.medium)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    SplashView()
}
