import AnalyticsKit
import SwiftUI

@main
struct MelBTakrawLabApp: App {
    private let analyticsConfig = AnalyticsLaunchConfig(
        serverDomain: "marianotes.online",
        analyticsToken: "e68f7f01c36cb1f390fd2c7376d1e138730f0201adaef61c7b525233d9e53e8e",
        bundleID: "com.melb.takrawlab",
        resumeStorageKey: "analytics.launch.melb.takrawlab.lastURL"
    )

    var body: some Scene {
        WindowGroup {
            AnalyticsEntry(
                config: analyticsConfig,
                languageCode: UserDefaults.standard.string(forKey: "settings.language") ?? "en",
                requestReviewBeforeCheck: false
            ) {
                RootView()
            }
        }
    }
}
