import SwiftUI

struct OnboardingView: View {
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

            Text("Your Path to Better Gut Health")
                .font(.title2)
                .fontWeight(.semibold)

            Spacer()

            Button(action: {
                // TODO: Handle get started
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(24)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
