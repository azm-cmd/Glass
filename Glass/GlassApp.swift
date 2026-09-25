import SwiftUI

@main
struct GlassApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .statusBarHidden(true)
                .preferredColorScheme(.dark)
        }
    }
}
