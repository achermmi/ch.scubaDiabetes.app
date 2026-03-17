import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    // ── Stato ─────────────────────────────────────────────────────────────
    @Published var profile:    DiverProfile?
    @Published var isLoading   = false
    @Published var errorMessage: String?
    @Published var expandedSection: ProfileSection? = nil  // 🆕 Tutte le sezioni contratte all'inizio

    enum ProfileSection: Hashable {
        case health, certifications, clearances, emergency
    }

    private let profileService = ProfileService()

    // ── Caricamento ───────────────────────────────────────────────────────

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            profile = try await profileService.fullProfile()
            
            #if DEBUG
            print("✅ [PROFILE] Caricato con successo")
            if let health = profile?.health {
                print("  📊 Health:")
                print("    - isDiabetic: \(health.isDiabetic ?? false)")
                print("    - diabetesType: \(health.diabetesType ?? "nil")")
                print("    - therapyType: \(health.therapyType ?? "nil")")
                print("    - bloodType: \(health.bloodType ?? "nil")")
                print("    - hba1c: \(health.hba1c?.description ?? "nil")")
            } else {
                print("  ⚠️ Health profile is nil")
            }
            
            print("  🏆 Certifications: \(profile?.certifications.count ?? 0)")
            profile?.certifications.forEach { cert in
                print("    - \(cert.agency) | \(cert.level) | \(cert.date)")
            }
            
            print("  🩺 Clearances: \(profile?.clearances.count ?? 0)")
            print("  📞 Emergency Contacts: \(profile?.emergencyContacts.count ?? 0)")
            profile?.emergencyContacts.forEach { contact in
                print("    - \(contact.name) | \(contact.phone)")
                print("      relationship: \(contact.relationship ?? "nil")")
                print("      email: \(contact.email ?? "nil")")
            }
            #endif
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("❌ [PROFILE] Errore caricamento: \(error)")
            #endif
        }
    }

    // ── Salva salute ──────────────────────────────────────────────────────

    func saveHealth(_ body: [String: Any]) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            let updatedHealth = try await profileService.updateHealth(body)
            // Aggiorna solo la sezione health nel profilo esistente
            if let p = profile {
                profile = DiverProfile(
                    user: p.user,
                    health: updatedHealth,
                    certifications: p.certifications,
                    clearances: p.clearances,
                    emergencyContacts: p.emergencyContacts
                )
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // ── Certificazioni ────────────────────────────────────────────────────

    func addCertification(_ body: [String: Any]) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            // Se body contiene "id" → update, altrimenti → add
            let cert: Certification
            if let id = body["id"] as? Int {
                cert = try await profileService.updateCertification(id: id, body: body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications.map { $0.id == id ? cert : $0 },
                                 clearances: $0.clearances,
                                 emergencyContacts: $0.emergencyContacts)
                }
            } else {
                cert = try await profileService.addCertification(body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications + [cert],
                                 clearances: $0.clearances,
                                 emergencyContacts: $0.emergencyContacts)
                }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteCertification(id: Int) async {
        do {
            try await profileService.deleteCertification(id: id)
            profile = profile.map {
                DiverProfile(user: $0.user, health: $0.health,
                             certifications: $0.certifications.filter { $0.id != id },
                             clearances: $0.clearances,
                             emergencyContacts: $0.emergencyContacts)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ── Clearance mediche ─────────────────────────────────────────────────

    func addClearance(_ body: [String: Any]) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            let cl: MedicalClearance
            if let id = body["id"] as? Int {
                cl = try await profileService.updateClearance(id: id, body: body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications,
                                 clearances: $0.clearances.map { $0.id == id ? cl : $0 },
                                 emergencyContacts: $0.emergencyContacts)
                }
            } else {
                cl = try await profileService.addClearance(body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications,
                                 clearances: $0.clearances + [cl],
                                 emergencyContacts: $0.emergencyContacts)
                }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteClearance(id: Int) async {
        do {
            try await profileService.deleteClearance(id: id)
            profile = profile.map {
                DiverProfile(user: $0.user, health: $0.health,
                             certifications: $0.certifications,
                             clearances: $0.clearances.filter { $0.id != id },
                             emergencyContacts: $0.emergencyContacts)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ── Contatti emergenza ────────────────────────────────────────────────

    func addEmergencyContact(_ body: [String: Any]) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            let ec: EmergencyContact
            if let id = body["id"] as? Int {
                ec = try await profileService.updateEmergencyContact(id: id, body: body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications,
                                 clearances: $0.clearances,
                                 emergencyContacts: $0.emergencyContacts.map { $0.id == id ? ec : $0 })
                }
            } else {
                ec = try await profileService.addEmergencyContact(body)
                profile = profile.map {
                    DiverProfile(user: $0.user, health: $0.health,
                                 certifications: $0.certifications,
                                 clearances: $0.clearances,
                                 emergencyContacts: $0.emergencyContacts + [ec])
                }
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteEmergencyContact(id: Int) async {
        do {
            try await profileService.deleteEmergencyContact(id: id)
            profile = profile.map {
                DiverProfile(user: $0.user, health: $0.health,
                             certifications: $0.certifications,
                             clearances: $0.clearances,
                             emergencyContacts: $0.emergencyContacts.filter { $0.id != id })
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
