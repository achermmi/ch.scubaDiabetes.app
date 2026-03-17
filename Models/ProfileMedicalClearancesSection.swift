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
            MedicalClearanceFormView(existing: nil) { body, documentData, fileName in
                saveClearance(body: body, documentData: documentData, fileName: fileName)
            }
        }
        .sheet(item: $editingClearance) { clearance in
            MedicalClearanceFormView(existing: clearance) { body, documentData, fileName in
                updateClearance(id: clearance.id, body: body, documentData: documentData, fileName: fileName)
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
        
        do {
            clearances = try await APIService.shared.getMedicalClearances()
        } catch {
            errorMessage = "Errore caricamento: \(error.localizedDescription)"
            #if DEBUG
            print("❌ Errore caricamento idoneità:", error)
            #endif
        }
        
        isLoading = false
    }
    
    private func saveClearance(body: [String: Any], documentData: Data?, fileName: String?) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let newClearance = try await APIService.shared.saveMedicalClearance(
                    body: body,
                    documentData: documentData,
                    documentName: fileName
                )
                
                #if DEBUG
                print("✅ Idoneità salvata:", newClearance.id)
                #endif
                
                // Ricarica lista
                await loadClearances()
            } catch {
                errorMessage = "Errore salvataggio: \(error.localizedDescription)"
                #if DEBUG
                print("❌ Errore salvataggio idoneità:", error)
                #endif
            }
            
            isLoading = false
        }
    }
    
    private func updateClearance(id: Int, body: [String: Any], documentData: Data?, fileName: String?) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let updatedClearance = try await APIService.shared.updateMedicalClearance(
                    id: id,
                    body: body,
                    documentData: documentData,
                    documentName: fileName
                )
                
                #if DEBUG
                print("✅ Idoneità aggiornata:", updatedClearance.id)
                #endif
                
                // Ricarica lista
                await loadClearances()
            } catch {
                errorMessage = "Errore aggiornamento: \(error.localizedDescription)"
                #if DEBUG
                print("❌ Errore aggiornamento idoneità:", error)
                #endif
            }
            
            isLoading = false
        }
    }
    
    private func deleteClearance(_ clearance: MedicalClearance) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                try await APIService.shared.deleteMedicalClearance(id: clearance.id)
                
                #if DEBUG
                print("✅ Idoneità eliminata:", clearance.id)
                #endif
                
                // Rimuovi localmente
                clearances.removeAll { $0.id == clearance.id }
            } catch {
                errorMessage = "Errore eliminazione: \(error.localizedDescription)"
                #if DEBUG
                print("❌ Errore eliminazione idoneità:", error)
                #endif
            }
            
            isLoading = false
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
