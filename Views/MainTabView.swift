import SwiftUI

struct MainTabView: View {
    let user: SDUser

    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authVM:    AuthViewModel

    var body: some View {
        TabView(selection: $appRouter.selectedTab) {

            // ── Home / Pubblica ──────────────────────────────────────────
            HomeView()
                .tabItem { Label("nav.home", systemImage: "house.fill") }
                .tag(AppRouter.Tab.home)

            // ── Logbook (solo soci subacquei) ────────────────────────────
            if user.sdRole.isDiver {
                LogbookListView()
                    .tabItem { Label("nav.logbook", systemImage: "book.closed.fill") }
                    .tag(AppRouter.Tab.logbook)
            }

            // ── Profilo personale ────────────────────────────────────────
            ProfileView()
                .tabItem { Label("nav.profile", systemImage: "person.fill") }
                .tag(AppRouter.Tab.profile)

            // ── Pannello medico (solo staff medico) ──────────────────────
            if user.sdRole.canViewAll {
                MedicalPanelView()
                    .tabItem { Label("nav.medical", systemImage: "cross.case.fill") }
                    .tag(AppRouter.Tab.medical)
            }

            // ── Gestione soci (solo staff/admin) ─────────────────────────
            if user.sdRole == .staff || user.sdRole == .administrator {
                MembersListView()
                    .tabItem { Label("nav.members", systemImage: "person.3.fill") }
                    .tag(AppRouter.Tab.members)
            }
        }
        .accentColor(Color("AccentColor"))
        .onAppear { setupInitialTab() }
    }

    private func setupInitialTab() {
        // I subacquei partono dal logbook, gli altri dall'home
        if user.sdRole.isDiver {
            appRouter.selectedTab = .logbook
        } else if user.sdRole.canViewAll {
            appRouter.selectedTab = .medical
        }
    }
}
