import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Profile Medical Clearances Section
// Sezione Idoneità Medica completa per il Profilo Subacqueo
// Mostra tutte le funzionalità allineate con il sito web
// ─────────────────────────────────────────────────────────────────────────────

struct ProfileMedicalClearancesSection: View {
    @State private var clearances: [MedicalClearance] = []
    @State private var showAddForm = false
    @State private var editingClearance: MedicalClearance?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Section {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if clearances.isEmpty {
                emptyStateView
            } else {
                ForEach(clearances.sorted(by: { $0.year > $1.year })) { clearance in
                    MedicalClearanceCardView(clearance: clearance) {
                        deleteClearance(clearance)
                    }
                    .onTapGesture {
                        editingClearance = clearance
                    }
                }
            }
            
            // Pulsante aggiungi
            Button(action: { showAddForm = true }) {
                Label("Aggiungi idoneità", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
        } header: {
            Label("Idoneità Medica", systemImage: "heart.text.square.fill")
        } footer: {
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
        }
        .sheet(isPresented: $showAddForm) {
            MedicalClearanceFormView(existing: nil) { body, documentData in
                saveClearance(body: body, documentData: documentData)
            }
        }
        .sheet(item: $editingClearance) { clearance in
            MedicalClearanceFormView(existing: clearance) { body, documentData in
                updateClearance(id: clearance.id, body: body, documentData: documentData)
            }
        }
        .task {
            await loadClearances()
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Empty State
    // ═══════════════════════════════════════════════════════════════════
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Nessuna idoneità medica")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("Aggiungi la tua certificazione medica per le immersioni")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - API Calls
    // ═══════════════════════════════════════════════════════════════════
    
    private func loadClearances() async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implementare chiamata API reale
        // Esempio:
        // let result = await APIService.shared.getMedicalClearances()
        // switch result {
        // case .success(let data):
        //     clearances = data
        // case .failure(let error):
        //     errorMessage = error.localizedDescription
        // }
        
        // Mock data per preview
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        clearances = [
            MedicalClearance(
                id: 1,
                year: 2026,
                date: "2026-03-12",
                validUntil: "2027-03-12",
                type: "iperbarica",
                doctor: "Dr. Pippo Baudo",
                outcome: "fit",
                notes: "Test note",
                documentUrl: "https://example.com/doc.pdf",
                documentName: "Spirometria.pdf",
                approvedBy: nil,
                approvedAt: nil,
                approvedNotes: nil
            ),
            MedicalClearance(
                id: 2,
                year: 2025,
                date: "2025-03-03",
                validUntil: "2026-03-03",
                type: "sportiva",
                doctor: "Dr. Pinco Palla",
                outcome: "fit",
                notes: nil,
                documentUrl: "https://example.com/doc2.pdf",
                documentName: "Certificato.pdf",
                approvedBy: nil,
                approvedAt: nil,
                approvedNotes: nil
            )
        ]
        
        isLoading = false
    }
    
    private func saveClearance(body: [String: Any], documentData: Data?) {
        Task {
            // TODO: Implementare upload multipart/form-data
            // Se c'è documentData, inviare come multipart
            // Altrimenti, inviare solo JSON
            
            print("📝 Salvataggio idoneità:", body)
            if let data = documentData {
                print("📎 Con documento di \(data.count) bytes")
            }
            
            // Ricarica lista
            await loadClearances()
        }
    }
    
    private func updateClearance(id: Int, body: [String: Any], documentData: Data?) {
        Task {
            print("📝 Aggiornamento idoneità #\(id):", body)
            if let data = documentData {
                print("📎 Nuovo documento di \(data.count) bytes")
            }
            
            await loadClearances()
        }
    }
    
    private func deleteClearance(_ clearance: MedicalClearance) {
        Task {
            // TODO: Implementare DELETE API
            print("🗑️ Eliminazione idoneità #\(clearance.id)")
            
            // Rimuovi localmente
            clearances.removeAll { $0.id == clearance.id }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════

#Preview {
    NavigationStack {
        Form {
            ProfileMedicalClearancesSection()
        }
        .navigationTitle("Profilo Subacqueo")
    }
}
