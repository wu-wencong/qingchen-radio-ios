import SwiftUI

@main
struct QingchenRadioApp: App {
    @StateObject private var radio = RadioPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(radio)
        }
    }
}
