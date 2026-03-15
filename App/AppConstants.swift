import Foundation

enum AppConstants {

    // ── API ──────────────────────────────────────────────────────────────
    enum API {
#if DEBUG
        static let baseURL = "https://scubadiabetes.m-achermann.com/wp-json/sd/v2"
#else
        static let baseURL = "https://scubadiabetes.ch/wp-json/sd/v2"
#endif
        static let timeoutInterval: TimeInterval = 30
        static let uploadTimeoutInterval: TimeInterval = 120
    }

    // ── Keychain ─────────────────────────────────────────────────────────
    enum Keychain {
        static let accessToken  = "ch.scubadiabetes.access_token"
        static let refreshToken = "ch.scubadiabetes.refresh_token"
        static let userID       = "ch.scubadiabetes.user_id"
        static let userRole     = "ch.scubadiabetes.user_role"
    }

    // ── UserDefaults ─────────────────────────────────────────────────────
    enum Defaults {
        static let preferredLanguage  = "preferred_language"
        static let hasSeenOnboarding  = "has_seen_onboarding"
        static let lastSyncDate       = "last_sync_date"
        static let use2FA             = "use_2fa"
    }

    // ── Ruoli ─────────────────────────────────────────────────────────────
    enum Role: String, CaseIterable {
        case diabeticDiver  = "sd_diver_diabetic"
        case diver          = "sd_diver"
        case medical        = "sd_medical"
        case staff          = "sd_staff"
        case administrator  = "administrator"
        case subscriber     = "subscriber"

        var isMedicalStaff: Bool { self == .medical || self == .staff || self == .administrator }
        var isDiver: Bool        { self == .diabeticDiver || self == .diver }
        var isDiabetic: Bool     { self == .diabeticDiver }
        var canViewAll: Bool     { isMedicalStaff }

        var displayName: String {
            switch self {
            case .diabeticDiver: return String(localized: "role.diabetic_diver")
            case .diver:         return String(localized: "role.diver")
            case .medical:       return String(localized: "role.medical")
            case .staff:         return String(localized: "role.staff")
            case .administrator: return String(localized: "role.administrator")
            case .subscriber:    return String(localized: "role.subscriber")
            }
        }
    }

    // ── Design ────────────────────────────────────────────────────────────
    enum Design {
        static let cornerRadius: CGFloat   = 12
        static let cardPadding: CGFloat    = 16
        static let sectionSpacing: CGFloat = 24
        static let animationDuration       = 0.3
    }

    // ── Pagamenti ─────────────────────────────────────────────────────────
    enum Payment {
        static let currency = "CHF"
        static let membershipFeeIndividual: Double = 50
        static let membershipFeeFamily: Double     = 80
        static let membershipFeeSupporter: Double  = 100
    }

    // ── File upload ───────────────────────────────────────────────────────
    enum Upload {
        static let maxFileSizeMB: Int = 5
        static let allowedTypes = ["pdf", "jpg", "jpeg", "png", "zip"]
    }

    // ── Lingue supportate ─────────────────────────────────────────────────
    static let supportedLanguages: [(code: String, name: String)] = [
        ("it", "Italiano"),
        ("de", "Deutsch"),
        ("fr", "Français"),
        ("en", "English"),
    ]
}
