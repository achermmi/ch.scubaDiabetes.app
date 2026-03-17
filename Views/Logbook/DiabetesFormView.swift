import SwiftUI
import Combine

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Costanti di mappatura DB ↔ UI
// ─────────────────────────────────────────────────────────────────────────────

// Il DB usa stringhe italiane; il picker usa emoji/frecce
private let trendDBtoUI: [String: String] = [
    "salita_rapida": "↑↑",
    "salita":        "↑",
    "stabile":       "→",
    "discesa":       "↓",
    "discesa_rapida":"↓↓"
]
private let trendUItoDisplay: [String: String] = [
    "↑↑": "↑↑", "↑": "↑", "→": "→", "↓": "↓", "↓↓": "↓↓"
]
private func trendFromDB(_ s: String?) -> String {
    guard let s else { return "→" }
    return trendDBtoUI[s] ?? "→"
}
private func trendToDB(_ ui: String) -> String {
    let map = trendDBtoUI.first { $0.value == ui }
    return map?.key ?? "stabile"
}

// Il DB usa italiano; il Picker usa tag inglesi per semplicità interna
private func decisionFromDB(_ s: String?) -> String {
    switch s {
    case "autorizzata":  return "autorizzata"
    case "posticipata":  return "posticipata"
    case "annullata":    return "annullata"
    default:             return "autorizzata"
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiabetesFormView
// ─────────────────────────────────────────────────────────────────────────────

struct DiabetesFormView: View {
    let diveID:   Int
    let existing: DiabetesData?
    let glucoseUnit: GlucoseUnit  // 🆕 Unità preferita dall'utente
    let onSaved:  (DiabetesData) -> Void

    @StateObject private var vm: DiabetesFormViewModel
    @Environment(\.dismiss) var dismiss

    init(diveID: Int, existing: DiabetesData?, glucoseUnit: GlucoseUnit = .mgDl, onSaved: @escaping (DiabetesData) -> Void) {
        self.diveID   = diveID
        self.existing = existing
        self.glucoseUnit = glucoseUnit
        self.onSaved  = onSaved
        _vm = StateObject(wrappedValue: DiabetesFormViewModel(diveID: diveID, existing: existing, glucoseUnit: glucoseUnit))
    }

    var body: some View {
        NavigationStack {
            Form {
                // ── Checkpoint -60 ─────────────────────────────────────────
                Section(header: Text("Checkpoint -60 min")) {
                    checkpointHeader
                    CheckpointFormSection(
                        label:   "-60 min",
                        glic:    $vm.glicPre60,
                        trend:   $vm.trendPre60,
                        choR:    $vm.choRapitiPre60,
                        choL:    $vm.choLentiPre60,
                        insulin: $vm.insulinPre60,
                        unit:    glucoseUnit  // 🆕
                    )
                }

                // ── Checkpoint -30 ─────────────────────────────────────────
                Section(header: Text("Checkpoint -30 min")) {
                    CheckpointFormSection(
                        label:   "-30 min",
                        glic:    $vm.glicPre30,
                        trend:   $vm.trendPre30,
                        choR:    $vm.choRapitiPre30,
                        choL:    $vm.choLentiPre30,
                        insulin: $vm.insulinPre30,
                        unit:    glucoseUnit  // 🆕
                    )
                }

                // ── Checkpoint -10 ─────────────────────────────────────────
                Section(header: Text("Checkpoint -10 min")) {
                    CheckpointFormSection(
                        label:   "-10 min",
                        glic:    $vm.glicPre10,
                        trend:   $vm.trendPre10,
                        choR:    $vm.choRapitiPre10,
                        choL:    $vm.choLentiPre10,
                        insulin: $vm.insulinPre10,
                        unit:    glucoseUnit  // 🆕
                    )
                }

                // ── Post immersione ────────────────────────────────────────
                Section(header: Text("Post immersione")) {
                    HStack {
                        Text("Glicemia").frame(width: 80, alignment: .leading)
                        TextField("—", text: $vm.glicPost)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text(glucoseUnit.displaySymbol).font(.caption).foregroundStyle(.secondary)  // 🆕
                    }
                    HStack {
                        Text("Trend").frame(width: 80, alignment: .leading)
                        Spacer()
                        trendPicker($vm.trendPost)
                    }
                }

                // ── Decisione ─────────────────────────────────────────────
                Section(header: Text("Decisione")) {
                    Picker("Decisione", selection: $vm.diveDecision) {
                        Label("Autorizzata",  systemImage: "checkmark.circle.fill").tag("autorizzata")
                        Label("Posticipata",  systemImage: "clock.badge.exclamationmark").tag("posticipata")
                        Label("Annullata",    systemImage: "xmark.circle.fill").tag("annullata")
                    }
                    .pickerStyle(.inline)

                    if !vm.diveDecisionReason.isEmpty {
                        Text(vm.diveDecisionReason)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // ── Flags ─────────────────────────────────────────────────
                Section(header: Text("Segnalazioni")) {
                    Toggle("Ipoglicemia durante immersione", isOn: $vm.hypoDuringDive)
                    if vm.hypoDuringDive {
                        HStack {
                            Text("Trattamento")
                            Spacer()
                            TextField("—", text: $vm.hypoTreatment)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    Toggle("Pompa disconnessa", isOn: $vm.pumpDisconnected)
                }

                // ── Note glicemia ─────────────────────────────────────────
                Section(header: Text("Note glicemia")) {
                    TextEditor(text: $vm.notes)
                        .frame(minHeight: 60)
                }

                if let err = vm.errorMessage {
                    Section { Text(err).foregroundStyle(.red).font(.caption) }
                }
            }
            .navigationTitle(existing == nil ? "Aggiungi dati glicemici" : "Modifica dati glicemici")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        Task {
                            if let saved = await vm.save() {
                                onSaved(saved)
                                dismiss()
                            }
                        }
                    }
                    .disabled(vm.isLoading)
                    .overlay { if vm.isLoading { ProgressView().scaleEffect(0.8) } }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fine") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }

    private var checkpointHeader: some View {
        HStack {
            Text("Glicemia").font(.caption).foregroundStyle(.secondary).frame(width: 80, alignment: .leading)
            Text(glucoseUnit.displaySymbol).font(.caption).foregroundStyle(.secondary).frame(width: 50)  // 🆕
            Spacer()
            Text("Trend").font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text("CHO r/l g").font(.caption).foregroundStyle(.secondary)
        }
    }

    private func trendPicker(_ binding: Binding<String>) -> some View {
        Picker("", selection: binding) {
            ForEach(["↑↑","↑","→","↓","↓↓"], id: \.self) { t in Text(t).tag(t) }
        }
        .pickerStyle(.segmented)
        .frame(width: 200)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - CheckpointFormSection
// ─────────────────────────────────────────────────────────────────────────────

struct CheckpointFormSection: View {
    let label:     String
    @Binding var glic:    String
    @Binding var trend:   String
    @Binding var choR:    String
    @Binding var choL:    String
    @Binding var insulin: String
    let unit: GlucoseUnit  // 🆕

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Glicemia").frame(width: 80, alignment: .leading)
                TextField("—", text: $glic)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text(unit.displaySymbol).font(.caption).foregroundStyle(.secondary)  // 🆕
            }
            HStack {
                Text("Trend").frame(width: 80, alignment: .leading)
                Spacer()
                Picker("", selection: $trend) {
                    ForEach(["↑↑","↑","→","↓","↓↓"], id: \.self) { t in Text(t).tag(t) }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            HStack {
                Text("CHO r").frame(width: 80, alignment: .leading)
                TextField("—", text: $choR)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("g").font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text("CHO l").frame(width: 80, alignment: .leading)
                TextField("—", text: $choL)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("g").font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Text("Insulina").frame(width: 80, alignment: .leading)
                TextField("—", text: $insulin)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                Text("U").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DiabetesFormViewModel
// ─────────────────────────────────────────────────────────────────────────────

@MainActor
final class DiabetesFormViewModel: ObservableObject {
    let diveID: Int
    let glucoseUnit: GlucoseUnit  // 🆕

    // Checkpoint stringhe per TextField + Picker
    @Published var glicPre60      = ""
    @Published var trendPre60     = "→"
    @Published var choRapitiPre60 = ""
    @Published var choLentiPre60  = ""
    @Published var insulinPre60   = ""

    @Published var glicPre30      = ""
    @Published var trendPre30     = "→"
    @Published var choRapitiPre30 = ""
    @Published var choLentiPre30  = ""
    @Published var insulinPre30   = ""

    @Published var glicPre10      = ""
    @Published var trendPre10     = "→"
    @Published var choRapitiPre10 = ""
    @Published var choLentiPre10  = ""
    @Published var insulinPre10   = ""

    @Published var glicPost       = ""
    @Published var trendPost      = "→"

    // Decisione — usa valori italiani come nel DB
    @Published var diveDecision       = "autorizzata"
    @Published var diveDecisionReason = ""

    // Flags
    @Published var hypoDuringDive    = false
    @Published var hypoTreatment     = ""
    @Published var pumpDisconnected  = false

    @Published var notes             = ""
    @Published var isLoading         = false
    @Published var errorMessage: String?

    private let service = DiabetesService()

    init(diveID: Int, existing: DiabetesData?, glucoseUnit: GlucoseUnit = .mgDl) {
        self.diveID = diveID
        self.glucoseUnit = glucoseUnit
        if let d = existing { populate(from: d) }
    }

    // Popola i campi dal modello scaricato dall'API
    // 🆕 I valori dal DB sono sempre in mg/dL, quindi convertiamo se l'utente usa mmol/L
    private func populate(from d: DiabetesData) {
        // Glicemie: Double? → String (con conversione se necessario)
        glicPre60 = d.glicPre60.map { formatGlucoseForDisplay($0) } ?? ""
        glicPre30 = d.glicPre30.map { formatGlucoseForDisplay($0) } ?? ""
        glicPre10 = d.glicPre10.map { formatGlucoseForDisplay($0) } ?? ""
        glicPost  = d.glicPost.map  { formatGlucoseForDisplay($0) } ?? ""

        // Trend: DB "discesa" → UI "↓"
        trendPre60 = trendFromDB(d.trendPre60)
        trendPre30 = trendFromDB(d.trendPre30)
        trendPre10 = trendFromDB(d.trendPre10)
        trendPost  = trendFromDB(d.trendPost)

        // CHO / Insulina
        choRapitiPre60 = d.choRapitiPre60.map { "\($0)" } ?? ""
        choLentiPre60  = d.choLentiPre60.map  { "\($0)" } ?? ""
        insulinPre60   = d.insulinPre60.map   { "\($0)" } ?? ""
        choRapitiPre30 = d.choRapitiPre30.map { "\($0)" } ?? ""
        choLentiPre30  = d.choLentiPre30.map  { "\($0)" } ?? ""
        insulinPre30   = d.insulinPre30.map   { "\($0)" } ?? ""
        choRapitiPre10 = d.choRapitiPre10.map { "\($0)" } ?? ""
        choLentiPre10  = d.choLentiPre10.map  { "\($0)" } ?? ""
        insulinPre10   = d.insulinPre10.map   { "\($0)" } ?? ""

        // Decisione
        diveDecision       = decisionFromDB(d.diveDecision)
        diveDecisionReason = d.diveDecisionReason ?? ""

        // Flags
        hypoDuringDive   = d.hypoDuringDive   ?? false
        hypoTreatment    = d.hypoTreatment    ?? ""
        pumpDisconnected = d.pumpDisconnected ?? false

        notes = d.diabetesNotes ?? ""
    }
    
    // 🆕 Formatta glicemia dal DB (mg/dL) all'unità preferita
    private func formatGlucoseForDisplay(_ mgDl: Double) -> String {
        switch glucoseUnit {
        case .mgDl:
            return "\(Int(mgDl))"
        case .mmolL:
            let mmol = mgDl.mgDlToMmolL
            return String(format: "%.1f", mmol)
        }
    }
    
    // 🆕 Converte glicemia dall'unità dell'utente a mg/dL per il salvataggio
    private func convertToMgDl(_ value: Double) -> Double {
        switch glucoseUnit {
        case .mgDl:
            return value
        case .mmolL:
            return value.mmolLToMgDl
        }
    }

    func save() async -> DiabetesData? {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }

        func dbl(_ s: String) -> Double? { Double(s) }

        // Chiavi API: corrispondono alle colonne MySQL del plugin
        var body: [String: Any] = [
            "dive_decision": diveDecision
        ]

        // 🆕 Converti i valori in mg/dL prima di salvare
        // -60
        if let v = dbl(glicPre60)      { body["glic_60_value"]      = convertToMgDl(v) }
        body["glic_60_trend"]           = trendToDB(trendPre60)
        if let v = dbl(choRapitiPre60) { body["glic_60_cho_rapidi"] = v }
        if let v = dbl(choLentiPre60)  { body["glic_60_cho_lenti"]  = v }
        if let v = dbl(insulinPre60)   { body["glic_60_insulin"]    = v }

        // -30
        if let v = dbl(glicPre30)      { body["glic_30_value"]      = convertToMgDl(v) }
        body["glic_30_trend"]           = trendToDB(trendPre30)
        if let v = dbl(choRapitiPre30) { body["glic_30_cho_rapidi"] = v }
        if let v = dbl(choLentiPre30)  { body["glic_30_cho_lenti"]  = v }
        if let v = dbl(insulinPre30)   { body["glic_30_insulin"]    = v }

        // -10
        if let v = dbl(glicPre10)      { body["glic_10_value"]      = convertToMgDl(v) }
        body["glic_10_trend"]           = trendToDB(trendPre10)
        if let v = dbl(choRapitiPre10) { body["glic_10_cho_rapidi"] = v }
        if let v = dbl(choLentiPre10)  { body["glic_10_cho_lenti"]  = v }
        if let v = dbl(insulinPre10)   { body["glic_10_insulin"]    = v }

        // Post
        if let v = dbl(glicPost)       { body["glic_post_value"]    = convertToMgDl(v) }
        body["glic_post_trend"]         = trendToDB(trendPost)

        // Flags
        body["hypo_during_dive"]   = hypoDuringDive ? 1 : 0
        if !hypoTreatment.isEmpty  { body["hypo_treatment"]   = hypoTreatment }
        body["pump_disconnected"]  = pumpDisconnected ? 1 : 0
        if !notes.isEmpty          { body["diabetes_notes"] = notes }

        do {
            return try await service.upsert(diveID: diveID, body: body)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
