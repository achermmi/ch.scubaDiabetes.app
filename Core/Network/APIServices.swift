import Foundation
#if canImport(UIKit)
import UIKit
#endif

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - AuthService
// ─────────────────────────────────────────────────────────────────────────────

final class AuthService {
    private let net = NetworkManager.shared

    func login(email: String, password: String, deviceName: String, deviceType: String) async throws -> LoginResponse {
        try await net.request("/auth/login", method: .post, body: [
            "email": email,
            "password": password,
            "device_name": deviceName,
            "device_type": deviceType,
            "device_id": Self.deviceUUID(),
        ], requiresAuth: false)
    }

    private static func deviceUUID() -> String {
        #if canImport(UIKit)
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #else
        return UserDefaults.standard.string(forKey: "device_uuid") ?? UUID().uuidString
        #endif
    }

    func refresh(refreshToken: String) async throws -> TokenPair {
        try await net.request("/auth/refresh", method: .post, body: [
            "refresh_token": refreshToken,
        ], requiresAuth: false)
    }

    func logout() async throws {
        let _: EmptyResponse = try await net.request("/auth/logout", method: .post)
    }

    func logoutAll() async throws {
        let _: EmptyResponse = try await net.request("/auth/logout-all", method: .post)
    }

    func send2FA(email: String) async throws {
        let _: MessageResponse = try await net.request("/auth/2fa/send", method: .post, body: ["email": email], requiresAuth: false)
    }

    func verify2FA(userID: Int, code: String, deviceName: String) async throws -> LoginResponse {
        try await net.request("/auth/2fa/verify", method: .post, body: [
            "user_id": userID,
            "code": code,
            "device_name": deviceName,
            "device_type": "iOS",
        ], requiresAuth: false)
    }

    func me() async throws -> SDUser {
        try await net.request("/auth/me")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiveService
// ─────────────────────────────────────────────────────────────────────────────

final class DiveService {
    private let net = NetworkManager.shared

    func list(page: Int = 1, perPage: Int = 20, filters: DiveFilters? = nil) async throws -> [Dive] {
        var qi: [URLQueryItem] = [
            URLQueryItem(name: "page",     value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        if let f = filters {
            if let from = f.dateFrom { qi.append(URLQueryItem(name: "date_from", value: from)) }
            if let to   = f.dateTo   { qi.append(URLQueryItem(name: "date_to",   value: to)) }
            if let site = f.site     { qi.append(URLQueryItem(name: "site",       value: site)) }
        }
        return try await net.request("/dives", queryItems: qi)
    }

    func stats() async throws -> DiveStats {
        try await net.request("/dives/stats")
    }

    func detail(id: Int) async throws -> DiveDetail {
        try await net.request("/dives/\(id)")
    }

    func create(_ body: [String: Any]) async throws -> Dive {
        try await net.request("/dives", method: .post, body: body)
    }

    func update(id: Int, body: [String: Any]) async throws -> Dive {
        try await net.request("/dives/\(id)", method: .put, body: body)
    }

    func delete(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/dives/\(id)", method: .delete)
    }

    func exportCSV() async throws -> Data {
        try await net.download("/dives/export/csv")
    }

    // Sessioni
    func sessions(page: Int = 1) async throws -> [DiveSession] {
        try await net.request("/dives/sessions", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
        ])
    }

    func createSession(date: String, notes: String? = nil) async throws -> DiveSession {
        var body: [String: Any] = ["session_date": date]
        if let n = notes { body["notes"] = n }
        return try await net.request("/dives/sessions", method: .post, body: body)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiabetesService
// ─────────────────────────────────────────────────────────────────────────────

final class DiabetesService {
    private let net = NetworkManager.shared

    func get(diveID: Int) async throws -> DiabetesData? {
        try await net.request("/dives/\(diveID)/diabetes")
    }

    func upsert(diveID: Int, body: [String: Any]) async throws -> DiabetesData {
        try await net.request("/dives/\(diveID)/diabetes", method: .post, body: body)
    }

    func nutritionList(diveID: Int) async throws -> [NutritionEntry] {
        try await net.request("/dives/\(diveID)/nutrition")
    }

    func addNutrition(diveID: Int, body: [String: Any]) async throws -> NutritionEntry {
        try await net.request("/dives/\(diveID)/nutrition", method: .post, body: body)
    }

    func deleteNutrition(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/nutrition/\(id)", method: .delete)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - ProfileService
// ─────────────────────────────────────────────────────────────────────────────

final class ProfileService {
    private let net = NetworkManager.shared

    func fullProfile() async throws -> DiverProfile {
        try await net.request("/profile")
    }

    func updateHealth(_ body: [String: Any]) async throws -> HealthProfile {
        try await net.request("/profile", method: .put, body: body)
    }

    // Certificazioni
    func certifications() async throws -> [Certification] {
        try await net.request("/profile/certifications")
    }
    func addCertification(_ body: [String: Any]) async throws -> Certification {
        try await net.request("/profile/certifications", method: .post, body: body)
    }
    func updateCertification(id: Int, body: [String: Any]) async throws -> Certification {
        try await net.request("/profile/certifications/\(id)", method: .put, body: body)
    }
    func deleteCertification(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/profile/certifications/\(id)", method: .delete)
    }

    // Clearance
    func clearances() async throws -> [MedicalClearance] {
        try await net.request("/profile/clearances")
    }
    func addClearance(_ body: [String: Any]) async throws -> MedicalClearance {
        try await net.request("/profile/clearances", method: .post, body: body)
    }
    func updateClearance(id: Int, body: [String: Any]) async throws -> MedicalClearance {
        try await net.request("/profile/clearances/\(id)", method: .put, body: body)
    }
    func deleteClearance(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/profile/clearances/\(id)", method: .delete)
    }
    func uploadClearanceDoc(id: Int, fileData: Data, fileName: String, mimeType: String) async throws -> UploadResult {
        try await net.upload("/profile/clearances/\(id)/upload", fileData: fileData, fileName: fileName, mimeType: mimeType)
    }

    // Contatti emergenza
    func emergencyContacts() async throws -> [EmergencyContact] {
        try await net.request("/profile/emergency-contacts")
    }
    func addEmergencyContact(_ body: [String: Any]) async throws -> EmergencyContact {
        try await net.request("/profile/emergency-contacts", method: .post, body: body)
    }
    func updateEmergencyContact(id: Int, body: [String: Any]) async throws -> EmergencyContact {
        try await net.request("/profile/emergency-contacts/\(id)", method: .put, body: body)
    }
    func deleteEmergencyContact(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/profile/emergency-contacts/\(id)", method: .delete)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - MedicalService
// ─────────────────────────────────────────────────────────────────────────────

final class MedicalService {
    private let net = NetworkManager.shared

    func divers(search: String? = nil) async throws -> [DiverSummary] {
        var qi: [URLQueryItem] = []
        if let s = search { qi.append(URLQueryItem(name: "search", value: s)) }
        return try await net.request("/medical/divers", queryItems: qi.isEmpty ? nil : qi)
    }

    func diverDetail(userID: Int) async throws -> MedicalDiverDetail {
        try await net.request("/medical/divers/\(userID)")
    }

    func diverDives(userID: Int, page: Int = 1) async throws -> [DiveWithGlycemia] {
        try await net.request("/medical/divers/\(userID)/dives", queryItems: [
            URLQueryItem(name: "page", value: "\(page)"),
        ])
    }

    func addSupervision(_ body: [String: Any]) async throws -> Supervision {
        try await net.request("/medical/supervision", method: .post, body: body)
    }

    func updateSupervision(id: Int, body: [String: Any]) async throws -> Supervision {
        try await net.request("/medical/supervision/\(id)", method: .put, body: body)
    }

    func supervisions(forDive diveID: Int) async throws -> [Supervision] {
        try await net.request("/medical/supervision/dive/\(diveID)")
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - MembersService
// ─────────────────────────────────────────────────────────────────────────────

final class MembersService {
    private let net = NetworkManager.shared

    func myMembership() async throws -> Membership? {
        try await net.request("/members/me")
    }

    func myPayments() async throws -> [Payment] {
        try await net.request("/members/me/payments")
    }

    func myFamily() async throws -> [FamilyMember] {
        try await net.request("/members/me/family")
    }

    func addFamilyMember(_ body: [String: Any]) async throws -> FamilyMember {
        try await net.request("/members/me/family", method: .post, body: body)
    }

    func removeFamilyMember(id: Int) async throws {
        let _: EmptyResponse = try await net.request("/members/me/family/\(id)", method: .delete)
    }

    // Admin
    func allMembers(page: Int = 1, status: String? = nil, type: String? = nil) async throws -> [MemberRow] {
        var qi = [URLQueryItem(name: "page", value: "\(page)")]
        if let s = status { qi.append(URLQueryItem(name: "status", value: s)) }
        if let t = type   { qi.append(URLQueryItem(name: "type",   value: t)) }
        return try await net.request("/members", queryItems: qi)
    }

    func memberDetail(id: Int) async throws -> MemberDetail {
        try await net.request("/members/\(id)")
    }

    func updateMember(id: Int, body: [String: Any]) async throws -> Membership {
        try await net.request("/members/\(id)", method: .put, body: body)
    }

    func recordPayment(memberID: Int, body: [String: Any]) async throws -> Payment {
        try await net.request("/members/\(memberID)/payments", method: .post, body: body)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - ResearchService
// ─────────────────────────────────────────────────────────────────────────────

final class ResearchService {
    private let net = NetworkManager.shared

    func overview(filters: ResearchFilters) async throws -> ResearchOverview {
        try await net.request("/research/overview", queryItems: filters.toQueryItems())
    }

    func glycemicDistribution(filters: ResearchFilters) async throws -> GlycemicDistribution {
        try await net.request("/research/glycemic", queryItems: filters.toQueryItems())
    }

    func checkpointAverages(filters: ResearchFilters) async throws -> CheckpointAverages {
        try await net.request("/research/checkpoints", queryItems: filters.toQueryItems())
    }

    func decisionDistribution(filters: ResearchFilters) async throws -> [DecisionCount] {
        try await net.request("/research/decisions", queryItems: filters.toQueryItems())
    }

    func timeline(filters: ResearchFilters, groupBy: String = "month") async throws -> [TimelinePoint] {
        var qi = filters.toQueryItems()
        qi.append(URLQueryItem(name: "group_by", value: groupBy))
        return try await net.request("/research/timeline", queryItems: qi)
    }

    func exportCSV(filters: ResearchFilters) async throws -> Data {
        try await net.download("/research/export/csv", queryItems: filters.toQueryItems())
    }
}

struct ResearchFilters {
    var years: [Int] = []
    var dateFrom: String?
    var dateTo: String?
    var diabetesType: String?
    var therapyType: String?

    func toQueryItems() -> [URLQueryItem] {
        var qi: [URLQueryItem] = []
        years.forEach    { qi.append(URLQueryItem(name: "year[]", value: "\($0)")) }
        if let v = dateFrom    { qi.append(URLQueryItem(name: "date_from",     value: v)) }
        if let v = dateTo      { qi.append(URLQueryItem(name: "date_to",       value: v)) }
        if let v = diabetesType{ qi.append(URLQueryItem(name: "diabetes_type", value: v)) }
        if let v = therapyType { qi.append(URLQueryItem(name: "therapy_type",  value: v)) }
        return qi
    }
}
