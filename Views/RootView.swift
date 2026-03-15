import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        ZStack {
            if authVM.isAuthenticated, let user = authVM.currentUser {
                MainTabView(user: user)
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: AppConstants.Design.animationDuration),
                   value: authVM.isAuthenticated)
        .alert(
            appRouter.activeAlert?.title ?? "",
            isPresented: Binding(
                get: { appRouter.activeAlert != nil },
                set: { if !$0 { appRouter.activeAlert = nil } }
            )
        ) {
            Button("ok") { appRouter.activeAlert = nil }
        } message: {
            Text(appRouter.activeAlert?.message ?? "")
        }
    }
}
