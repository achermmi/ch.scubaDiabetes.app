import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - HealthProfileFormView
// ─────────────────────────────────────────────────────────────────────────────

struct HealthProfileFormView: View {
    let existing: HealthProfile?
    let onSave:   ([String: Any]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var isDiabetic     = false
    @State private var diabetesType   = "T1"
    @State private var therapyType    = "MDI"
    @State private var hba1c          = ""
    @State private var cgmDevice      = ""
    @State private var insulinPump    = ""
    @State private var bloodType      = ""
    @State private var allergies      = ""
    @State private var medications    = ""
    @State private var notes          = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("profile.health.diabetes") {
                    Toggle("profile.health.is_diabetic", isOn: $isDiabetic.animation())
                    if isDiabetic {
                        Picker("profile.health.diabetes_type", selection: $diabetesType) {
                            Text("Tipo 1").tag("T1")
                            Text("Tipo 2").tag("T2")
                            Text("LADA").tag("LADA")
                            Text("MODY").tag("MODY")
                            Text("Altro").tag("other")
                        }
                        Picker("profile.health.therapy", selection: $therapyType) {
                            Text("MDI").tag("MDI")
                            Text("Microinfusore").tag("pump")
                            Text("Orale").tag("oral")
                            Text("Dieta").tag("diet")
                        }
                        HStack {
                            Text("HbA1c")
                            Spacer()
                            TextField("5.5", text: $hba1c)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("%").font(.caption).foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("profile.health.cgm")
                            Spacer()
                            TextField("es. Dexcom G7", text: $cgmDevice)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("profile.health.pump")
                            Spacer()
                            TextField("es. Omnipod 5", text: $insulinPump)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("profile.health.general") {
                    Picker("profile.health.blood_type", selection: $bloodType) {
                        Text("—").tag("")
                        ForEach(["A+","A-","B+","B-","AB+","AB-","0+","0-"], id: \.self) { bt in
                            Text(bt).tag(bt)
                        }
                    }
                }

                Section("profile.health.allergies") {
                    TextEditor(text: $allergies).frame(minHeight: 60)
                }

                Section("profile.health.medications") {
                    TextEditor(text: $medications).frame(minHeight: 60)
                }

                Section("profile.health.notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .navigationTitle("profile.health.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        var body: [String: Any] = [
                            "is_diabetic":  isDiabetic,
                            "blood_type":   bloodType,
                            "allergies":    allergies,
                            "medications":  medications,
                            "notes":        notes
                        ]
                        if isDiabetic {
                            body["diabetes_type"]  = diabetesType
                            body["therapy_type"]   = therapyType
                            if let v = Double(hba1c) { body["hba1c"] = v }
                            if !cgmDevice.isEmpty   { body["cgm_device"] = cgmDevice }
                            if !insulinPump.isEmpty  { body["insulin_pump_model"] = insulinPump }
                        }
                        onSave(body)
                        dismiss()
                    }
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let h = existing else { return }
        isDiabetic   = h.isDiabetic ?? false
        diabetesType = h.diabetesType ?? "T1"
        therapyType  = h.therapyType ?? "MDI"
        hba1c        = h.hba1c.map { "\($0)" } ?? ""
        cgmDevice    = h.cgmDevice ?? ""
        insulinPump  = h.insulinPumpModel ?? ""
        bloodType    = h.bloodType ?? ""
        allergies    = h.allergies ?? ""
        medications  = h.medications ?? ""
        notes        = h.notes ?? ""
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - CertificationFormView
// ─────────────────────────────────────────────────────────────────────────────

struct CertificationFormView: View {
    let existing: Certification?
    let onSave:   ([String: Any]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var level  = ""
    @State private var agency = "PADI"
    @State private var date   = Date()
    @State private var number = ""
    @State private var notes  = ""

    private let agencies = ["PADI","SSI","CMAS","NAUI","BSAC","TDI","IANTD","GUE","SDI","ESA","Altro"]

    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("profile.cert.section.info") {
                    HStack {
                        Text("profile.cert.level")
                        Spacer()
                        TextField("es. Open Water Diver", text: $level)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("profile.cert.agency", selection: $agency) {
                        ForEach(agencies, id: \.self) { Text($0).tag($0) }
                    }
                    DatePicker("profile.cert.date", selection: $date, displayedComponents: .date)
                    HStack {
                        Text("profile.cert.number")
                        Spacer()
                        TextField("opzionale", text: $number)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("profile.cert.notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .navigationTitle(existing == nil ? "profile.cert.title_add" : "profile.cert.title_edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        var body: [String: Any] = [
                            "level":  level.trimmingCharacters(in: .whitespaces),
                            "agency": agency,
                            "date":   df.string(from: date)
                        ]
                        if !number.isEmpty { body["number"] = number }
                        if !notes.isEmpty  { body["notes"]  = notes }
                        if let id = existing?.id { body["id"] = id }
                        onSave(body)
                        dismiss()
                    }
                    .disabled(level.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let c = existing else { return }
        level  = c.level
        agency = c.agency
        if let d = df.date(from: c.date) { date = d }
        number = c.number ?? ""
        notes  = c.notes ?? ""
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - ClearanceFormView
// ─────────────────────────────────────────────────────────────────────────────

struct ClearanceFormView: View {
    let existing: MedicalClearance?
    let onSave:   ([String: Any]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var year       = Calendar.current.component(.year, from: Date())
    @State private var validUntil = Date().addingTimeInterval(365 * 24 * 3600)
    @State private var doctor     = ""
    @State private var outcome    = "fit"
    @State private var notes      = ""

    private let df: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("profile.clearance.section.info") {
                    Stepper("profile.clearance.year \(year)", value: $year,
                            in: 2000...Calendar.current.component(.year, from: Date()) + 1)

                    DatePicker("profile.clearance.valid_until", selection: $validUntil,
                               displayedComponents: .date)

                    HStack {
                        Text("profile.clearance.doctor")
                        Spacer()
                        TextField("profile.clearance.doctor_ph", text: $doctor)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("profile.clearance.outcome", selection: $outcome) {
                        Label("profile.clearance.fit",         systemImage: "checkmark.circle.fill").tag("fit")
                        Label("profile.clearance.fit_limited", systemImage: "exclamationmark.circle.fill").tag("fit_limited")
                        Label("profile.clearance.unfit",       systemImage: "xmark.circle.fill").tag("unfit")
                    }
                    .pickerStyle(.inline)
                }

                Section("profile.clearance.notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .navigationTitle(existing == nil ? "profile.clearance.title_add" : "profile.clearance.title_edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        var body: [String: Any] = [
                            "year":        year,
                            "valid_until": df.string(from: validUntil),
                            "outcome":     outcome
                        ]
                        if !doctor.isEmpty { body["doctor"] = doctor }
                        if !notes.isEmpty  { body["notes"]  = notes }
                        if let id = existing?.id { body["id"] = id }
                        onSave(body)
                        dismiss()
                    }
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let c = existing else { return }
        year    = c.year
        if let d = df.date(from: c.validUntil) { validUntil = d }
        doctor  = c.doctor ?? ""
        outcome = c.outcome ?? "fit"
        notes   = c.notes ?? ""
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - EmergencyContactFormView
// ─────────────────────────────────────────────────────────────────────────────

struct EmergencyContactFormView: View {
    let existing: EmergencyContact?
    let onSave:   ([String: Any]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var name         = ""
    @State private var phone        = ""
    @State private var relationship = ""
    @State private var email        = ""
    @State private var notes        = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("profile.emergency.section.info") {
                    HStack {
                        Text("profile.emergency.name")
                        Spacer()
                        TextField("profile.emergency.name_ph", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("profile.emergency.phone")
                        Spacer()
                        TextField("+41 79 000 00 00", text: $phone)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("profile.emergency.relationship")
                        Spacer()
                        TextField("profile.emergency.relationship_ph", text: $relationship)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("profile.emergency.email")
                        Spacer()
                        TextField("email@esempio.ch", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("profile.emergency.notes") {
                    TextEditor(text: $notes).frame(minHeight: 60)
                }
            }
            .navigationTitle(existing == nil ? "profile.emergency.title_add" : "profile.emergency.title_edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        var body: [String: Any] = [
                            "name":  name.trimmingCharacters(in: .whitespaces),
                            "phone": phone.trimmingCharacters(in: .whitespaces)
                        ]
                        if !relationship.isEmpty { body["relationship"] = relationship }
                        if !email.isEmpty        { body["email"]        = email }
                        if !notes.isEmpty        { body["notes"]        = notes }
                        if let id = existing?.id { body["id"]           = id }
                        onSave(body)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty ||
                              phone.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let c = existing else { return }
        name         = c.name
        phone        = c.phone
        relationship = c.relationship ?? ""
        email        = c.email ?? ""
        notes        = c.notes ?? ""
    }
}
