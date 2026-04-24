import SwiftUI
import UIKit

/// Dark, high-contrast “AI studio” chrome (original styling — not affiliated with any third-party product).
enum WCSStudioTheme {
    static let void = Color(red: 0.03, green: 0.03, blue: 0.06)
    static let onyx = Color(red: 0.05, green: 0.05, blue: 0.09)
    static let panel = Color(red: 0.09, green: 0.09, blue: 0.14)
    static let panelElevated = Color(red: 0.12, green: 0.11, blue: 0.18)
    static let stroke = Color.white.opacity(0.08)
    static let textPrimary = Color(red: 0.97, green: 0.96, blue: 0.99)
    static let textMuted = Color(red: 0.58, green: 0.58, blue: 0.68)
    static let accent = Color(red: 0.62, green: 0.48, blue: 1.0)
    static let accentSecondary = Color(red: 0.35, green: 0.85, blue: 0.95)
    /// Warm metallic highlight for borders and typographic accents.
    static let champagne = Color(red: 0.93, green: 0.82, blue: 0.62)
    static let pearl = Color(red: 0.88, green: 0.9, blue: 0.96)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.45, green: 0.35, blue: 0.95),
                Color(red: 0.25, green: 0.75, blue: 0.92),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var screenWash: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.05, blue: 0.12),
                void,
                Color(red: 0.07, green: 0.05, blue: 0.1),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var frameGradient: LinearGradient {
        LinearGradient(
            colors: [
                champagne.opacity(0.55),
                accent.opacity(0.35),
                accentSecondary.opacity(0.3),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum WCSStudioAppearance {
    static func configure() {
        let void = UIColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1)
        let panel = UIColor(red: 0.09, green: 0.09, blue: 0.14, alpha: 1)
        let accent = UIColor(red: 0.62, green: 0.48, blue: 1.0, alpha: 1)

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = void
        tab.shadowImage = UIImage()
        tab.shadowColor = .clear
        tab.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.38)
        tab.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.42),
        ]
        tab.stackedLayoutAppearance.selected.iconColor = accent
        tab.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: accent,
        ]
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = accent
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.38)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = panel
        nav.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1),
        ]
        nav.largeTitleTextAttributes = nav.titleTextAttributes
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = accent

        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }
}

struct WCSScreenBackground: View {
    var body: some View {
        ZStack {
            WCSStudioTheme.screenWash.ignoresSafeArea()
            RadialGradient(
                colors: [
                    WCSStudioTheme.accent.opacity(0.14),
                    Color.clear,
                ],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [
                    WCSStudioTheme.champagne.opacity(0.08),
                    Color.clear,
                ],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }
}

struct WCSGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(WCSStudioTheme.panelElevated.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        WCSStudioTheme.accent.opacity(0.35),
                                        WCSStudioTheme.stroke,
                                        WCSStudioTheme.accentSecondary.opacity(0.25),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1,
                            ),
                    ),
            )
            .shadow(color: WCSStudioTheme.accent.opacity(0.12), radius: 18, y: 10)
            .shadow(color: WCSStudioTheme.champagne.opacity(0.06), radius: 28, y: 14)
    }
}

extension View {
    func wcsGlassCard() -> some View {
        modifier(WCSGlassCard())
    }

    /// Narrow inner frame for hero imagery and premium tiles.
    func wcsLuxeFrame(cornerRadius: CGFloat = 20) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(WCSStudioTheme.frameGradient, lineWidth: 1.15),
        )
        .shadow(color: WCSStudioTheme.champagne.opacity(0.12), radius: 22, y: 12)
    }
}
