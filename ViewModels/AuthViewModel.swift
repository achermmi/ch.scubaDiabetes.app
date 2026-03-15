import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class AuthViewModel: ObservableObject {

    // ── Stato pubblico ────────────────────────────────────────────────────
    @Published var currentUser: SDUser?
    @Published var isAuthenticated = false
    @Published var isLoading       = false
    @Published var errorMessage:   String?
    @Published var needs2FA        = false
    @Published var pendingUserID:  Int?

    private let service  = AuthService()
    private let keychain = KeychainManager.shared

    // Collegato al NetworkManager per gestire token scaduti
    init() {
        NetworkManager.shared.onUnauthorized = { [weak self] in
            Task { await self?.handleUnauthorized() }
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await service.login(
                email: email,
                password: password,
                deviceName: deviceName(),
                deviceType: "iOS"
            )
            saveSession(response)
        } catch APIError.serverError(let code, let message, _) {
            if code == "invalid_credentials" {
                errorMessage = String(localized: "auth.error.invalid_credentials")
            } else {
                errorMessage = message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ── 2FA ───────────────────────────────────────────────────────────────
    func send2FA(email: String) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            try await service.send2FA(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verify2FA(code: String) async {
        guard let uid = pendingUserID else { return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await service.verify2FA(userID: uid, code: code, deviceName: deviceName())
            needs2FA = false
            pendingUserID = nil
            saveSession(response)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ── Ripristina sessione all'avvio ─────────────────────────────────────
    func restoreSession() {
        guard keychain.accessToken != nil else { return }
        Task {
            await refreshUserIfNeeded()
        }
    }

    // ── Refresh token ─────────────────────────────────────────────────────
    func refreshToken() async -> Bool {
        guard let rt = keychain.refreshToken else { logout(); return false }
        do {
            let pair = try await service.refresh(refreshToken: rt)
            keychain.accessToken  = pair.accessToken
            keychain.refreshToken = pair.refreshToken
            return true
        } catch {
            logout()
            return false
        }
    }

    // ── Logout ────────────────────────────────────────────────────────────
    func logout() {
        Task {
            try? await service.logout()
        }
        clearSession()
    }

    func logoutAll() async {
        isLoading = true
        defer { isLoading = false }
        try? await service.logoutAll()
        clearSession()
    }

    // ── Privato ───────────────────────────────────────────────────────────

    private func saveSession(_ response: LoginResponse) {
        keychain.accessToken  = response.accessToken
        keychain.refreshToken = response.refreshToken
        keychain.save("\(response.user.id)", key: AppConstants.Keychain.userID)
        keychain.save(response.user.role ?? "",  key: AppConstants.Keychain.userRole)
        currentUser     = response.user
        isAuthenticated = true
    }

    private func clearSession() {
        keychain.clearAll()
        currentUser     = nil
        isAuthenticated = false
    }

    private func refreshUserIfNeeded() async {
        do {
            let user = try await service.me()
            currentUser     = user
            isAuthenticated = true
        } catch APIError.unauthorized {
            let refreshed = await refreshToken()
            if refreshed {
                if let user = try? await service.me() {
                    currentUser     = user
                    isAuthenticated = true
                }
            }
        } catch {
            // Token non valido – nessun crash, l'utente vedrà login
            isAuthenticated = false
        }
    }

    private func handleUnauthorized() async {
        let refreshed = await refreshToken()
        if !refreshed {
            clearSession()
        }
    }

    private func deviceName() -> String {
        #if os(iOS)
        return UIDevice.current.name
        #else
        return Host.current().localizedName ?? "Mac"
        #endif
    }
}
