import Foundation
import Security

/// Wrapper type-safe per Keychain.
/// Usato esclusivamente per access token, refresh token e dati sensibili.
final class KeychainManager {

    static let shared = KeychainManager()
    private init() {}

    // ── Salva ─────────────────────────────────────────────────────────────
    @discardableResult
    func save(_ value: String, key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // ── Leggi ─────────────────────────────────────────────────────────────
    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:            kSecClassGenericPassword,
            kSecAttrAccount as String:      key,
            kSecReturnData as String:       true,
            kSecMatchLimit as String:       kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // ── Elimina ───────────────────────────────────────────────────────────
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    // ── Elimina tutto (logout) ────────────────────────────────────────────
    func clearAll() {
        let keys = [
            AppConstants.Keychain.accessToken,
            AppConstants.Keychain.refreshToken,
            AppConstants.Keychain.userID,
            AppConstants.Keychain.userRole,
        ]
        keys.forEach { delete(key: $0) }
    }

    // ── Shortcut token ────────────────────────────────────────────────────
    var accessToken: String?  {
        get { read(key: AppConstants.Keychain.accessToken) }
        set { if let v = newValue { save(v, key: AppConstants.Keychain.accessToken) } else { delete(key: AppConstants.Keychain.accessToken) } }
    }

    var refreshToken: String? {
        get { read(key: AppConstants.Keychain.refreshToken) }
        set { if let v = newValue { save(v, key: AppConstants.Keychain.refreshToken) } else { delete(key: AppConstants.Keychain.refreshToken) } }
    }
}
