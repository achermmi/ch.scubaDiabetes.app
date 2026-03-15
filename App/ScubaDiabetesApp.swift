import SwiftUI

@main
struct ScubaDiabetesApp: App {

    @StateObject private var authVM    = AuthViewModel()
    @StateObject private var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(appRouter)
                .onAppear {
                    authVM.restoreSession()
                }
        }
    }
}
