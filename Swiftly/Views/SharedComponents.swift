import Foundation
import SwiftUI

enum SharedComponents {
    static func roundButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
                .foregroundStyle(.primary)
        }
    }

    static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.primary.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
            )
            .foregroundStyle(.primary)
    }

    static func titleWithDivider(_ text: String, color: Color = .primary) -> some View {
        HStack(alignment: .center, spacing: 20) {
            Text(text)
                .font(.headline)
                .foregroundColor(color)

            Rectangle()
                .fill(color.opacity(0.1))
                .frame(height: 1)
        }
    }
}
