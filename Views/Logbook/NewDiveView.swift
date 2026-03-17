import SwiftUI

struct NewDiveView: View {
    let isDiabetic: Bool
    let userGlucoseUnit: GlucoseUnit  // 🆕 Unità preferita dall'utente
    let defaultShareForResearch: Bool // 🆕 Default dal profilo
    let onSaved: () -> Void

    @StateObject private var vm = NewDiveViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case site, maxDepth, tank, gas, ballast, airTemp, waterTemp, vis, suit, buddy, notes
    }

    var body: some View {
        NavigationStack {
            Form {
                // ── Data e sito ───────────────────────────────────────────
                Section("dive.form.section.basic") {
                    DatePicker("dive.form.date", selection: $vm.diveDate, displayedComponents: .date)

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color("AccentColor"))
                            .frame(width: 24)
                        TextField("dive.form.site", text: $vm.site)
                            .focused($focusedField, equals: .site)
                    }
                }

                // ── Orari ─────────────────────────────────────────────────
                Section("dive.form.section.times") {
                    DatePicker("dive.form.time_in",  selection: $vm.timeIn,  displayedComponents: .hourAndMinute)
                    DatePicker("dive.form.time_out", selection: $vm.timeOut, displayedComponents: .hourAndMinute)
                }

                // ── Parametri ─────────────────────────────────────────────
                Section("dive.form.section.params") {
                    FormRow(icon: "arrow.down", label: "dive.form.max_depth", unit: "m") {
                        TextField("0", text: $vm.maxDepth)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .maxDepth)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "cylinder", label: "dive.form.tank", unit: "L") {
                        TextField("12", text: $vm.tankVolume)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .tank)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "wind", label: "dive.form.gas_mix", unit: nil) {
                        TextField("Aria", text: $vm.gasMix)
                            .focused($focusedField, equals: .gas)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "scalemass", label: "dive.form.ballast", unit: "kg") {
                        TextField("0", text: $vm.ballast)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .ballast)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("dive.form.entry_type", selection: $vm.entryType) {
                        Text("dive.entry.shore").tag("Riva")
                        Text("dive.entry.boat").tag("Barca")
                        Text("dive.entry.platform").tag("Piattaforma")
                        Text("dive.entry.other").tag("Altro")
                    }
                }

                // ── Condizioni ────────────────────────────────────────────
                Section("dive.form.section.conditions") {
                    FormRow(icon: "thermometer", label: "dive.form.air_temp", unit: "°C") {
                        TextField("20", text: $vm.airTemp)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .airTemp)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "thermometer.medium.slash", label: "dive.form.water_temp", unit: "°C") {
                        TextField("18", text: $vm.waterTemp)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .waterTemp)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "eye", label: "dive.form.visibility", unit: "m") {
                        TextField("10", text: $vm.visibility)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .vis)
                            .multilineTextAlignment(.trailing)
                    }
                    FormRow(icon: "cloud.sun", label: "dive.form.weather", unit: nil) {
                        Picker("", selection: $vm.weather) {
                            Text("").tag("")
                            Text("☀️ Sole").tag("Sole")
                            Text("⛅ Nuvoloso").tag("Nuvoloso")
                            Text("🌧 Pioggia").tag("Pioggia")
                            Text("💨 Vento").tag("Vento")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }

                // ── Equipaggiamento ───────────────────────────────────────
                Section("dive.form.section.equipment") {
                    FormRow(icon: "tshirt", label: "dive.form.suit", unit: nil) {
                        TextField("dive.form.suit_placeholder", text: $vm.suit)
                            .focused($focusedField, equals: .suit)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // ── Buddy ─────────────────────────────────────────────────
                Section("dive.form.section.buddy") {
                    FormRow(icon: "person.2", label: "dive.form.buddy", unit: nil) {
                        TextField("dive.form.buddy_placeholder", text: $vm.buddyName)
                            .focused($focusedField, equals: .buddy)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // ── Dati glicemici (solo diabetici) ───────────────────────
                if isDiabetic {
                    Section {
                        Toggle(isOn: $vm.showDiabetesSection.animation()) {
                            Label("dive.form.add_diabetes_data", systemImage: "drop.fill")
                                .foregroundStyle(.red)
                        }
                    }

                    if vm.showDiabetesSection {
                        diabetesSection
                    }
                }

                // ── Note ─────────────────────────────────────────────────
                Section("dive.form.section.notes") {
                    TextEditor(text: $vm.notes)
                        .focused($focusedField, equals: .notes)
                        .frame(minHeight: 80)
                }
                
                // 🆕 Privacy
                Section {
                    Toggle(isOn: $vm.shareForResearch) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("dive.form.share_for_research")
                                .font(.body)
                            Text("dive.form.share_for_research_desc")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("dive.form.privacy", systemImage: "lock.shield")
                }

                // ── Errore ────────────────────────────────────────────────
                if let err = vm.errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("dive.form.title_new")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        focusedField = nil
                        Task {
                            await vm.save(isDiabetic: isDiabetic, glucoseUnit: userGlucoseUnit)
                            if vm.savedDive != nil {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!vm.isValid || vm.isLoading)
                    .overlay {
                        if vm.isLoading { ProgressView().scaleEffect(0.8) }
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done") { focusedField = nil }
                }
            }
            .onAppear {
                // 🆕 Imposta il default dal profilo
                vm.shareForResearch = defaultShareForResearch
            }
        }
    }

    // ── Sezione diabetes inline ───────────────────────────────────────────

    private var diabetesSection: some View {
        Group {
            Section("dive.diabetes.checkpoints") {
                CheckpointInputRow(label: "-60 min", glic: $vm.glicPre60, unit: userGlucoseUnit)
                CheckpointInputRow(label: "-30 min", glic: $vm.glicPre30, unit: userGlucoseUnit)
                CheckpointInputRow(label: "-10 min", glic: $vm.glicPre10, unit: userGlucoseUnit)
                CheckpointInputRow(label: "Post",    glic: $vm.glicPost, unit: userGlucoseUnit)

                HStack {
                    Text("dive.diabetes.trend")
                    Spacer()
                    Picker("", selection: $vm.trendPre10) {
                        Text("↑↑").tag("↑↑")
                        Text("↑").tag("↑")
                        Text("→").tag("→")
                        Text("↓").tag("↓")
                        Text("↓↓").tag("↓↓")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }

            Section("dive.diabetes.decision") {
                Picker("dive.diabetes.decision", selection: $vm.diveDecision) {
                    Label("dive.decision.allowed",   systemImage: "checkmark.circle.fill").tag("allowed")
                    Label("dive.decision.postponed", systemImage: "clock.badge.exclamationmark").tag("postponed")
                    Label("dive.decision.cancelled", systemImage: "xmark.circle.fill").tag("cancelled")
                }
                .pickerStyle(.inline)

                Toggle("dive.diabetes.hypo_during",    isOn: $vm.hypoDuringDive)
                Toggle("dive.diabetes.pump_disconnect", isOn: $vm.pumpDisconnected)
                Toggle("dive.diabetes.cgm_used",        isOn: $vm.cgmUsed)
            }

            Section("dive.diabetes.cho") {
                FormRow(icon: "fork.knife", label: "dive.diabetes.cho_rapidi", unit: "g") {
                    TextField("0", text: $vm.choRapidi)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                FormRow(icon: "fork.knife.circle", label: "dive.diabetes.cho_lenti", unit: "g") {
                    TextField("0", text: $vm.choLenti)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Form helpers
// ─────────────────────────────────────────────────────────────────────────────

struct FormRow<Content: View>: View {
    let icon:    String
    let label:   LocalizedStringKey
    let unit:    String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color("AccentColor"))
                .frame(width: 22)
            Text(label)
            Spacer()
            content()
            if let u = unit {
                Text(u).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct CheckpointInputRow: View {
    let label: String
    @Binding var glic: String
    let unit: GlucoseUnit  // 🆕

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.medium))
                .frame(width: 60, alignment: .leading)
            Spacer()
            TextField("—", text: $glic)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit.displaySymbol).font(.caption).foregroundStyle(.secondary)
        }
    }
}
