import SwiftUI
import PhotosUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Medical Clearance Form View
// Form per aggiungere/modificare Idoneità Medica con tutti i campi del web
// ─────────────────────────────────────────────────────────────────────────────

struct MedicalClearanceFormView: View {
    let existing: MedicalClearance?
    let onSave: ([String: Any], Data?, String?) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    // State per i campi del form
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var date = Date()
    @State private var validUntil = Date().addingTimeInterval(365 * 24 * 3600) // +1 anno
    @State private var type = "iperbarica"
    @State private var doctor = ""
    @State private var outcome = "fit"
    @State private var notes = ""
    
    // Upload documento
    @State private var selectedDocument: PhotosPickerItem?
    @State private var documentData: Data?
    @State private var documentName: String?
    @State private var existingDocumentUrl: String?
    @State private var showDocumentPicker = false
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                // ═══════════════════════════════════════════════════════════
                // SEZIONE: INFORMAZIONI
                // ═══════════════════════════════════════════════════════════
                Section("Informazioni") {
                    // Anno (Stepper per compatibilità con web)
                    Stepper("Anno: \(year)", value: $year, in: 2000...2030)
                    
                    // Data rilascio
                    DatePicker("Data rilascio", 
                              selection: $date,
                              displayedComponents: .date)
                    
                    // Data scadenza
                    DatePicker("Valida fino al",
                              selection: $validUntil,
                              displayedComponents: .date)
                    
                    // Tipo visita
                    Picker("Tipo visita", selection: $type) {
                        Text("Iperbarica").tag("iperbarica")
                        Text("Sportiva agonistica").tag("sportiva")
                        Text("Sportiva non agonistica").tag("non_agonistica")
                        Text("Altro").tag("altro")
                    }
                    
                    // Medico
                    HStack {
                        Text("Medico")
                        Spacer()
                        TextField("Nome medico", text: $doctor)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // ═══════════════════════════════════════════════════════════
                // SEZIONE: ESITO
                // ═══════════════════════════════════════════════════════════
                Section("Esito") {
                    Picker("Risultato", selection: $outcome) {
                        Label("Idoneo", systemImage: "checkmark.circle.fill")
                            .tag("fit")
                        Label("Idoneo con limitazioni", systemImage: "exclamationmark.circle.fill")
                            .tag("fit_limited")
                        Label("Non idoneo", systemImage: "xmark.circle.fill")
                            .tag("unfit")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                // ═══════════════════════════════════════════════════════════
                // SEZIONE: DOCUMENTO
                // ═══════════════════════════════════════════════════════════
                Section {
                    if existingDocumentUrl != nil, documentData == nil {
                        // Documento esistente
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                            Text(documentName ?? "Documento")
                                .font(.subheadline)
                            Spacer()
                            Button("Cambia") {
                                showDocumentPicker = true
                            }
                            .font(.subheadline)
                        }
                    } else if let newDocName = documentName, documentData != nil {
                        // Nuovo documento selezionato
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.green)
                            Text(newDocName)
                                .font(.subheadline)
                            Spacer()
                            Button("Rimuovi") {
                                documentData = nil
                                documentName = nil
                            }
                            .foregroundColor(.red)
                            .font(.subheadline)
                        }
                    } else {
                        // Nessun documento
                        Button(action: { showDocumentPicker = true }) {
                            Label("Allega documento", systemImage: "paperclip")
                        }
                    }
                } header: {
                    Text("Documento")
                } footer: {
                    Text("PDF, JPG, PNG, ZIP — max 5 MB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // ═══════════════════════════════════════════════════════════
                // SEZIONE: NOTE
                // ═══════════════════════════════════════════════════════════
                Section("Note") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(existing == nil ? "Aggiungi Idoneità" : "Modifica Idoneità")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        saveAndDismiss()
                    }
                }
            }
            .onAppear {
                populateFields()
            }
            .fileImporter(
                isPresented: $showDocumentPicker,
                allowedContentTypes: [.pdf, .jpeg, .png, .zip],
                allowsMultipleSelection: false
            ) { result in
                handleDocumentSelection(result)
            }
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Populate da existing
    // ═══════════════════════════════════════════════════════════════════
    private func populateFields() {
        guard let existing = existing else { return }
        
        year = existing.year
        
        if let dateStr = dateFormatter.date(from: existing.date) {
            date = dateStr
        }
        
        if let validStr = dateFormatter.date(from: existing.validUntil) {
            validUntil = validStr
        }
        
        type = existing.type ?? "iperbarica"
        doctor = existing.doctor ?? ""
        outcome = existing.outcome ?? "fit"
        notes = existing.notes ?? ""
        
        existingDocumentUrl = existing.documentUrl
        documentName = existing.documentName
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Save
    // ═══════════════════════════════════════════════════════════════════
    private func saveAndDismiss() {
        var body: [String: Any] = [
            "year": year,
            "date": dateFormatter.string(from: date),
            "valid_until": dateFormatter.string(from: validUntil),
            "type": type,
            "outcome": outcome
        ]
        
        if !doctor.isEmpty {
            body["doctor"] = doctor
        }
        
        if !notes.isEmpty {
            body["notes"] = notes
        }
        
        if let id = existing?.id {
            body["id"] = id
        }
        
        // Chiama callback con body, documento e nome file
        onSave(body, documentData, documentName)
        dismiss()
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Document Handling
    // ═══════════════════════════════════════════════════════════════════
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Verifica dimensione (max 5 MB)
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
               let fileSize = attributes[.size] as? UInt64 {
                if fileSize > 5 * 1024 * 1024 {
                    // TODO: Mostra alert errore
                    print("⚠️ File troppo grande (max 5 MB)")
                    return
                }
            }
            
            // Carica i dati
            do {
                let data = try Data(contentsOf: url)
                documentData = data
                documentName = url.lastPathComponent
                
                // Pulisci URL esistente
                existingDocumentUrl = nil
            } catch {
                print("❌ Errore lettura file: \(error)")
            }
            
        case .failure(let error):
            print("❌ Errore selezione file: \(error)")
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════

#Preview("Nuovo") {
    MedicalClearanceFormView(existing: nil) { body, doc, fileName in
        print("📝 Salvataggio:", body)
        if let doc = doc, let name = fileName {
            print("📎 Documento:", name, "-", doc.count, "bytes")
        }
    }
}

#Preview("Modifica") {
    let sample = MedicalClearance(
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
    )
    
    MedicalClearanceFormView(existing: sample) { body, doc, fileName in
        print("📝 Aggiornamento:", body)
    }
}
