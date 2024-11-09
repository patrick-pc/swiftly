import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var isActive = false
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.75

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            HStack(spacing: 8) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.orange)

                Text("Biome")
                    .foregroundColor(foregroundColor)
            }
            .font(.title3)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
                scale = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
