import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ProfileViewModel()
    @State private var showHealthForm       = false
    @State private var showCertForm         = false
    @State private var showClearanceForm    = false
    @State private var showEmergencyForm    = false
    @State private var editingCert: Certification?
    @State private var editingClearance: MedicalClearance?
    @State private var editingContact: EmergencyContact?

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.profile == nil {
                    LoadingView()
                } else if let err = vm.errorMessage, vm.profile == nil {
                    ErrorView(message: err) { Task { await vm.load() } }
                } else if let profile = vm.profile {
                    profileContent(profile)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("nav.profile")
            .task { await vm.load() }
            .refreshable { await vm.load() }
            .sheet(isPresented: $showHealthForm) {
                if let p = vm.profile {
                    HealthProfileFormView(existing: p.health) { body in
                        Task { await vm.saveHealth(body) }
                    }
                }
            }
            .sheet(isPresented: $showCertForm) {
                CertificationFormView(existing: nil) { body in
                    Task { _ = await vm.addCertification(body) }
                }
            }
            .sheet(item: $editingCert) { cert in
                CertificationFormView(existing: cert) { body in
                    Task { _ = await vm.addCertification(body) }
                }
            }
            .sheet(isPresented: $showClearanceForm) {
                ClearanceFormView(existing: nil) { body in
                    Task { _ = await vm.addClearance(body) }
                }
            }
            .sheet(item: $editingClearance) { cl in
                ClearanceFormView(existing: cl) { body in
                    Task { _ = await vm.addClearance(body) }
                }
            }
            .sheet(isPresented: $showEmergencyForm) {
                EmergencyContactFormView(existing: nil) { body in
                    Task { _ = await vm.addEmergencyContact(body) }
                }
            }
            .sheet(item: $editingContact) { ec in
                EmergencyContactFormView(existing: ec) { body in
                    Task { _ = await vm.addEmergencyContact(body) }
                }
            }
        }
    }

    // ── Contenuto profilo ─────────────────────────────────────────────────

    private func profileContent(_ profile: DiverProfile) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // ── Header utente ─────────────────────────────────────────
                userHeader(profile.user)
                    .padding(.horizontal, 16)

                // ── Sezione salute ────────────────────────────────────────
                ProfileSection(
                    title: "profile.section.health",
                    icon: "heart.text.square.fill",
                    iconColor: .red,
                    isExpanded: vm.expandedSection == .health,
                    onToggle: { vm.expandedSection = vm.expandedSection == .health ? nil : .health },
                    action: ("pencil", { showHealthForm = true })
                ) {
                    HealthSectionContent(health: profile.health)
                }
                .padding(.horizontal, 16)

                // ── Certificazioni ────────────────────────────────────────
                ProfileSection(
                    title: "profile.section.certs",
                    icon: "rosette",
                    iconColor: .blue,
                    isExpanded: vm.expandedSection == .certifications,
                    onToggle: { vm.expandedSection = vm.expandedSection == .certifications ? nil : .certifications },
                    action: ("plus", { showCertForm = true })
                ) {
                    CertificationsSectionContent(
                        certs: profile.certifications,
                        onEdit: { editingCert = $0 },
                        onDelete: { id in Task { await vm.deleteCertification(id: id) } }
                    )
                }
                .padding(.horizontal, 16)

                // ── Clearance mediche ─────────────────────────────────────
                ProfileSection(
                    title: "profile.section.clearances",
                    icon: "stethoscope",
                    iconColor: .green,
                    isExpanded: vm.expandedSection == .clearances,
                    onToggle: { vm.expandedSection = vm.expandedSection == .clearances ? nil : .clearances },
                    action: ("plus", { showClearanceForm = true })
                ) {
                    ClearancesSectionContent(
                        clearances: profile.clearances,
                        onEdit: { editingClearance = $0 },
                        onDelete: { id in Task { await vm.deleteClearance(id: id) } }
                    )
                }
                .padding(.horizontal, 16)

                // ── Contatti emergenza ────────────────────────────────────
                ProfileSection(
                    title: "profile.section.emergency",
                    icon: "phone.fill",
                    iconColor: .orange,
                    isExpanded: vm.expandedSection == .emergency,
                    onToggle: { vm.expandedSection = vm.expandedSection == .emergency ? nil : .emergency },
                    action: ("plus", { showEmergencyForm = true })
                ) {
                    EmergencySectionContent(
                        contacts: profile.emergencyContacts,
                        onEdit: { editingContact = $0 },
                        onDelete: { id in Task { await vm.deleteEmergencyContact(id: id) } }
                    )
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }

    // ── Header utente ─────────────────────────────────────────────────────

    private func userHeader(_ user: SDUser) -> some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color("OceanMid"), Color("OceanDeep")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 72, height: 72)
                Text(initials(user))
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName.isEmpty ? (user.displayName ?? user.email) : user.fullName)
                    .font(.title3.bold())
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                RoleBadge(role: user.sdRole)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }

    private func initials(_ user: SDUser) -> String {
        let f = user.firstName.first.map(String.init) ?? ""
        let l = user.lastName.first.map(String.init) ?? ""
        return (f + l).uppercased().isEmpty ? "?" : (f + l).uppercased()
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - ProfileSection container
// ─────────────────────────────────────────────────────────────────────────────

struct ProfileSection<Content: View>: View {
    let title:      LocalizedStringKey
    let icon:       String
    let iconColor:  Color
    let isExpanded: Bool
    let onToggle:   () -> Void
    let action:     (String, () -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .frame(width: 24)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    if let (actionIcon, actionHandler) = action {
                        Button { actionHandler() } label: {
                            Image(systemName: actionIcon)
                                .foregroundStyle(Color("AccentColor"))
                        }
                        .onTapGesture { actionHandler() }
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().padding(.horizontal, 14)
                content()
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sezione Salute
// ─────────────────────────────────────────────────────────────────────────────

struct HealthSectionContent: View {
    let health: HealthProfile?

    var body: some View {
        if let h = health {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                if let d = h.diabetesType {
                    ProfileInfoCell(label: "profile.health.diabetes_type", value: d)
                }
                if let t = h.therapyType {
                    ProfileInfoCell(label: "profile.health.therapy", value: t)
                }
                if let hba = h.hba1c {
                    ProfileInfoCell(label: "HbA1c", value: "\(hba)%")
                }
                if let bt = h.bloodType {
                    ProfileInfoCell(label: "profile.health.blood_type", value: bt)
                }
                if let cgm = h.cgmDevice, !cgm.isEmpty {
                    ProfileInfoCell(label: "profile.health.cgm", value: cgm)
                }
                if let pump = h.insulinPumpModel, !pump.isEmpty {
                    ProfileInfoCell(label: "profile.health.pump", value: pump)
                }
            }
            if let allergies = h.allergies, !allergies.isEmpty {
                ProfileTextCell(label: "profile.health.allergies", value: allergies)
            }
            if let meds = h.medications, !meds.isEmpty {
                ProfileTextCell(label: "profile.health.medications", value: meds)
            }
            if let notes = h.notes, !notes.isEmpty {
                ProfileTextCell(label: "profile.health.notes", value: notes)
            }
        } else {
            EmptySectionView(message: "profile.health.empty", icon: "heart.slash")
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sezione Certificazioni
// ─────────────────────────────────────────────────────────────────────────────

struct CertificationsSectionContent: View {
    let certs:    [Certification]
    let onEdit:   (Certification) -> Void
    let onDelete: (Int) -> Void

    var body: some View {
        if certs.isEmpty {
            EmptySectionView(message: "profile.certs.empty", icon: "rosette")
        } else {
            VStack(spacing: 8) {
                ForEach(certs) { cert in
                    CertificationRow(cert: cert, onEdit: { onEdit(cert) }, onDelete: { onDelete(cert.id) })
                }
            }
        }
    }
}

struct CertificationRow: View {
    let cert:     Certification
    let onEdit:   () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "rosette")
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(cert.level)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 6) {
                    Text(cert.agency).font(.caption).foregroundStyle(.secondary)
                    Text("•").font(.caption).foregroundStyle(.secondary)
                    Text(formattedDate(cert.date)).font(.caption).foregroundStyle(.secondary)
                }
                if let num = cert.number, !num.isEmpty {
                    Text("N° \(num)").font(.caption2).foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Spacer()

            Menu {
                Button { onEdit() } label: { Label("edit", systemImage: "pencil") }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(.secondary).padding(8)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog("profile.cert.delete_confirm", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("delete", role: .destructive) { onDelete() }
            Button("cancel", role: .cancel) {}
        }
    }

    private func formattedDate(_ s: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        guard let d = df.date(from: s) else { return s }
        df.dateFormat = "MMM yyyy"; return df.string(from: d)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sezione Clearance
// ─────────────────────────────────────────────────────────────────────────────

struct ClearancesSectionContent: View {
    let clearances: [MedicalClearance]
    let onEdit:     (MedicalClearance) -> Void
    let onDelete:   (Int) -> Void

    var body: some View {
        if clearances.isEmpty {
            EmptySectionView(message: "profile.clearances.empty", icon: "stethoscope")
        } else {
            VStack(spacing: 8) {
                ForEach(clearances.sorted { $0.year > $1.year }) { cl in
                    ClearanceRow(clearance: cl, onEdit: { onEdit(cl) }, onDelete: { onDelete(cl.id) })
                }
            }
        }
    }
}

struct ClearanceRow: View {
    let clearance: MedicalClearance
    let onEdit:    () -> Void
    let onDelete:  () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // Anno badge
            Text("\(clearance.year)")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(statusColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                if let outcome = clearance.outcome {
                    Text(outcomeLabel(outcome))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(statusColor)
                }
                if let doctor = clearance.doctor, !doctor.isEmpty {
                    Text("Dr. \(doctor)").font(.caption).foregroundStyle(.secondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text("profile.clearance.valid_until \(formattedDate(clearance.validUntil))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Approvazione badge
            if clearance.approvedBy != nil {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }

            Menu {
                Button { onEdit() } label: { Label("edit", systemImage: "pencil") }
                if let url = clearance.documentUrl, !url.isEmpty {
                    Link(destination: URL(string: url)!) {
                        Label("profile.clearance.view_doc", systemImage: "doc.fill")
                    }
                }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(.secondary).padding(8)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog("profile.clearance.delete_confirm", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("delete", role: .destructive) { onDelete() }
            Button("cancel", role: .cancel) {}
        }
    }

    private var statusColor: Color {
        switch clearance.outcome {
        case "fit":         return .green
        case "fit_limited": return .orange
        case "unfit":       return .red
        default:            return .gray
        }
    }

    private func outcomeLabel(_ s: String) -> String {
        switch s {
        case "fit":         return String(localized: "profile.clearance.fit")
        case "fit_limited": return String(localized: "profile.clearance.fit_limited")
        case "unfit":       return String(localized: "profile.clearance.unfit")
        default:            return s
        }
    }

    private func formattedDate(_ s: String) -> String {
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        guard let d = df.date(from: s) else { return s }
        df.dateStyle = .medium; df.dateFormat = nil
        return df.string(from: d)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Sezione Emergenza
// ─────────────────────────────────────────────────────────────────────────────

struct EmergencySectionContent: View {
    let contacts: [EmergencyContact]
    let onEdit:   (EmergencyContact) -> Void
    let onDelete: (Int) -> Void

    var body: some View {
        if contacts.isEmpty {
            EmptySectionView(message: "profile.emergency.empty", icon: "phone.badge.xmark")
        } else {
            VStack(spacing: 8) {
                ForEach(contacts) { ec in
                    EmergencyContactRow(contact: ec, onEdit: { onEdit(ec) }, onDelete: { onDelete(ec.id) })
                }
            }
        }
    }
}

struct EmergencyContactRow: View {
    let contact:  EmergencyContact
    let onEdit:   () -> Void
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.subheadline.weight(.semibold))
                if let rel = contact.relationship, !rel.isEmpty {
                    Text(rel).font(.caption).foregroundStyle(.secondary)
                }
                Button {
                    if let url = URL(string: "tel:\(contact.phone)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(contact.phone, systemImage: "phone.fill")
                        .font(.caption)
                        .foregroundStyle(Color("AccentColor"))
                }
            }

            Spacer()

            Menu {
                Button { onEdit() } label: { Label("edit", systemImage: "pencil") }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(.secondary).padding(8)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog("profile.emergency.delete_confirm", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("delete", role: .destructive) { onDelete() }
            Button("cancel", role: .cancel) {}
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Componenti condivisi
// ─────────────────────────────────────────────────────────────────────────────

struct ProfileInfoCell: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ProfileTextCell: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct EmptySectionView: View {
    let message: LocalizedStringKey
    let icon:    String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color(.tertiaryLabel))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}
