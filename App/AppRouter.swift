import SwiftUI
import Combine

/// Gestisce la navigazione globale dell'app.
/// Tutti i ViewModel possono injectarlo per navigare programmaticamente.
@MainActor
final class AppRouter: ObservableObject {

    enum Tab: Int, CaseIterable {
        case home, logbook, profile, medical, members

        var icon: String {
            switch self {
            case .home:    return "house.fill"
            case .logbook: return "book.closed.fill"
            case .profile: return "person.fill"
            case .medical: return "cross.case.fill"
            case .members: return "person.3.fill"
            }
        }

        var title: LocalizedStringKey {
            switch self {
            case .home:    return "nav.home"
            case .logbook: return "nav.logbook"
            case .profile: return "nav.profile"
            case .medical: return "nav.medical"
            case .members: return "nav.members"
            }
        }
    }

    @Published var selectedTab: Tab = .home
    @Published var showLogin         = false
    @Published var showOnboarding    = false

    // Sheet / alert presentati globalmente
    @Published var activeAlert: AppAlert?

    struct AppAlert: Identifiable {
        let id   = UUID()
        let title: String
        let message: String
        var primaryButton: Alert.Button = .default(Text("OK"))
    }

    func showError(_ message: String, title: String = String(localized: "error.generic_title")) {
        activeAlert = AppAlert(title: title, message: message)
    }

    func navigate(to tab: Tab) {
        selectedTab = tab
    }
}
