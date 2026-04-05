import SwiftUI

struct MaxxPrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                isEnabled
                ? AnyShapeStyle(Color.maxxGradient)
                : AnyShapeStyle(Color.maxxSurfaceLight)
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct MaxxSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.maxxPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.maxxPrimary.opacity(0.1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.maxxPrimary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == MaxxPrimaryButtonStyle {
    static func maxxPrimary(isEnabled: Bool = true) -> MaxxPrimaryButtonStyle {
        MaxxPrimaryButtonStyle(isEnabled: isEnabled)
    }
}

extension ButtonStyle where Self == MaxxSecondaryButtonStyle {
    static var maxxSecondary: MaxxSecondaryButtonStyle {
        MaxxSecondaryButtonStyle()
    }
}
