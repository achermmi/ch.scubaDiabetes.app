import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// Stub Views — saranno implementate negli step successivi
// HomeView è in Views/Public/HomeView.swift
// ─────────────────────────────────────────────────────────────────────────────


struct MedicalPanelView: View {
    var body: some View {
        NavigationStack {
            ComingSoonView(icon: "cross.case.fill",  title: "nav.medical",  subtitle: "medical.coming_soon")
                .navigationTitle("nav.medical")
        }
    }
}

struct MembersListView: View {
    var body: some View {
        NavigationStack {
            ComingSoonView(icon: "person.3.fill",    title: "nav.members",  subtitle: "members.coming_soon")
                .navigationTitle("nav.members")
        }
    }
}

// ── ComingSoon helper ─────────────────────────────────────────────────────

struct ComingSoonView: View {
    let icon:     String
    let title:    LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(Color("AccentColor").opacity(0.6))
            Text(title).font(.title2.bold())
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
    }
}
