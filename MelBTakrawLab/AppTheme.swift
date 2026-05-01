import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.06, green: 0.06, blue: 0.07)
    static let surface = Color.white.opacity(0.08)
    static let surfaceStrong = Color.white.opacity(0.13)
    static let brandYellow = Color(red: 0.97, green: 0.75, blue: 0.09)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)

    static let heroGradient = LinearGradient(
        colors: [Color.white.opacity(0.09), brandYellow.opacity(0.18)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.04, green: 0.04, blue: 0.05),
            Color(red: 0.09, green: 0.09, blue: 0.11),
            Color(red: 0.04, green: 0.04, blue: 0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipped()
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardModifier())
    }
}
