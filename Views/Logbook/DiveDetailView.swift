import SwiftUI

struct DiveDetailView: View {
    let diveID: Int
    @StateObject private var vm = DiveDetailViewModel()
    @StateObject private var profileVM = ProfileViewModel()  // 🆕 Per recuperare preferenze
    @State private var showEditDiabetes = false

    var body: some View {
        Group {
            if vm.isLoading {
                LoadingView()
            } else if let dive = vm.dive {
                ScrollView {
                    VStack(spacing: 16) {
                        // ── Header ───────────────────────────────────────
                        diveHeader(dive)
                        // ── Dettagli immersione ──────────────────────────
                        diveDetailsCard(dive)
                        // ── Dati glicemici ───────────────────────────────
                        if let dd = vm.diabetesData {
                            diabetesCard(dd)
                        } else {
                            addDiabetesButton
                        }
                        // ── Note ─────────────────────────────────────────
                        if let notes = dive.notes, !notes.isEmpty {
                            notesCard(notes)
                        }
                    }
                    .padding(16)
                }
            } else if let err = vm.errorMessage {
                ErrorView(message: err) { Task { await vm.load(diveID: diveID) } }
            } else {
                LoadingView()  // fallback: non dovrebbe mai restare qui
            }
        }
        .navigationTitle("dive.detail.title")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            #if DEBUG
            print("📍 DiveDetailView loading diveID=\(diveID)")
            #endif
            await vm.load(diveID: diveID)
            await profileVM.load()  // 🆕 Carica profilo per preferenze
            #if DEBUG
            print("📍 DiveDetailView loaded: dive=\(vm.dive?.id ?? -1) error=\(vm.errorMessage ?? "none")")
            #endif
        }
        .sheet(isPresented: $showEditDiabetes) {
            if let dive = vm.dive {
                // 🆕 Passa unità glicemia dal profilo
                let glucoseUnit = profileVM.profile?.health?.glucoseUnit.flatMap { GlucoseUnit(rawValue: $0) } ?? .mgDl
                
                DiabetesFormView(
                    diveID: dive.id, 
                    existing: vm.diabetesData,
                    glucoseUnit: glucoseUnit
                ) { saved in
                    vm.diabetesData = saved
                }
            }
        }
    }

    // ── Header ────────────────────────────────────────────────────────────

    private func diveHeader(_ dive: Dive) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dive.site)
                    .font(.title2.bold())
                Text(formattedDate(dive.diveDate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("#\(dive.diveNumber)")
                .font(.title.bold().monospacedDigit())
                .foregroundStyle(Color("AccentColor"))
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }

    // ── Dettagli ──────────────────────────────────────────────────────────

    private func diveDetailsCard(_ dive: Dive) -> some View {
        SDCard {
            VStack(spacing: 0) {
                Label("dive.section.details", systemImage: "cylinder.fill")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    if let tin = dive.timeIn, let tout = dive.timeOut {
                        DetailCell(icon: "clock", label: "dive.time_in",  value: String(tin.prefix(5)))
                        DetailCell(icon: "clock.fill", label: "dive.time_out", value: String(tout.prefix(5)))
                    }
                    if let dur = dive.diveDuration {
                        DetailCell(icon: "timer",        label: "dive.duration",  value: dur)
                    }
                    if let d = dive.maxDepth {
                        DetailCell(icon: "arrow.down",   label: "dive.max_depth", value: "\(Int(d)) m")
                    }
                    if let p = dive.tankCapacity {
                        DetailCell(icon: "cylinder",     label: "dive.tank",      value: "\(p) L")
                    }
                    if let g = dive.gasMix {
                        DetailCell(icon: "wind",         label: "dive.gas_mix",   value: g)
                    }
                    if let w = dive.tempWater {
                        DetailCell(icon: "thermometer",  label: "dive.water_temp",value: "\(Int(w))°C")
                    }
                    if let v = dive.visibility, !v.isEmpty {
                        DetailCell(icon: "eye",          label: "dive.visibility", value: v)
                    }
                    if let b = dive.buddyName, !b.isEmpty {
                        DetailCell(icon: "person.2",     label: "dive.buddy",      value: b)
                    }
                    if let s = dive.suitType, !s.isEmpty {
                        DetailCell(icon: "tshirt",       label: "dive.suit",       value: s)
                    }
                }
            }
        }
    }

    // ── Dati glicemici ────────────────────────────────────────────────────

    private func diabetesCard(_ dd: DiabetesData) -> some View {
        SDCard {
            VStack(spacing: 12) {
                HStack {
                    Label("dive.section.diabetes", systemImage: "drop.fill")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Spacer()
                    Button { showEditDiabetes = true } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(Color("AccentColor"))
                    }
                }

                // Decision badge
                if let dec = dd.diveDecision {
                    HStack {
                        Text("dive.diabetes.decision")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        DecisionBadge(decision: dec)
                    }
                }

                // Decision reason banner
                if let reason = dd.diveDecisionReason, !reason.isEmpty {
                    DecisionReasonBanner(reason: reason, decision: dd.diveDecision)
                }

                Divider()

                // Tabella checkpoint
                VStack(spacing: 6) {
                    CheckpointRow(label: "-60 min", glic: dd.glicPre60, trend: dd.trendPre60, cho: dd.choRapitiPre60)
                    CheckpointRow(label: "-30 min", glic: dd.glicPre30, trend: dd.trendPre30, cho: dd.choRapitiPre30)
                    CheckpointRow(label: "-10 min", glic: dd.glicPre10, trend: dd.trendPre10, cho: dd.choRapitiPre10)
                    CheckpointRow(label: "Post",    glic: dd.glicPost,  trend: dd.trendPost,  cho: nil)
                }

                if dd.hypoDuringDive == true {
                    Label("dive.diabetes.hypo_during", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var addDiabetesButton: some View {
        Button { showEditDiabetes = true } label: {
            HStack {
                Image(systemName: "drop.fill").foregroundStyle(.red)
                Text("dive.diabetes.add").foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private func notesCard(_ notes: String) -> some View {
        SDCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("dive.section.notes_dive", systemImage: "note.text")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func formattedDate(_ s: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        guard let d = df.date(from: s) else { return s }
        df.dateStyle = .full; df.dateFormat = nil
        return df.string(from: d)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sub-components
// ─────────────────────────────────────────────────────────────────────────────

struct DetailCell: View {
    let icon:  String
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 18)
                .foregroundStyle(Color("AccentColor"))
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline.weight(.medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CheckpointRow: View {
    let label: String
    let glic:  Double?
    let trend: String?
    let cho:   Double?

    var body: some View {
        HStack {
            Text(label)
                .font(.caption.weight(.medium))
                .frame(width: 60, alignment: .leading)

            if let g = glic {
                Text("\(Int(g)) mg/dL")
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(glycColor(g))
            } else {
                Text("—").foregroundStyle(.secondary)
            }

            if let t = trend {
                Text(trendEmoji(t))
                    .font(.body)
            }
            Spacer()
            if let c = cho {
                Text("CHO: \(Int(c))g").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func trendEmoji(_ s: String) -> String {
        switch s {
        case "salita_rapida": return "↑↑"
        case "salita":        return "↑"
        case "stabile":       return "→"
        case "discesa":       return "↓"
        case "discesa_rapida":return "↓↓"
        default:              return s  // già emoji o stringa custom
        }
    }

    private func glycColor(_ v: Double) -> Color {
        switch v {
        case ..<70:    return .red
        case 70...100: return .orange
        case 101...140:return .green
        case 141...180:return .orange
        default:       return .red
        }
    }
}

struct DecisionBadge: View {
    let decision: String

    var body: some View {
        Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        switch decision {
        case "autorizzata": return "Autorizzata"
        case "posticipata": return "Posticipata"
        case "annullata":   return "Annullata"
        default:          return decision
        }
    }

    private var color: Color {
        switch decision {
        case "autorizzata": return .green
        case "posticipata": return .orange
        case "annullata":   return .red
        default:          return .gray
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DecisionReasonBanner
// Banner colorato per il motivo della decisione glicemica
// ─────────────────────────────────────────────────────────────────────────────

struct DecisionReasonBanner: View {
    let reason:   String
    let decision: String?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(reason)
                .font(.caption)
                .foregroundStyle(color)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var icon: String {
        switch decision {
        case "autorizzata": return "checkmark.circle.fill"
        case "posticipata": return "exclamationmark.triangle.fill"
        case "annullata":   return "xmark.circle.fill"
        default:            return "info.circle.fill"
        }
    }

    private var color: Color {
        switch decision {
        case "autorizzata": return .green
        case "posticipata": return .orange
        case "annullata":   return .red
        default:            return .orange  // default: attenzione arancione
        }
    }
}
