import SwiftUI

/// Scheda profilo utente accessibile dall'icona in alto a destra
struct UserProfileSheetView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirm = false
    @State private var showLogoutAllConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // ── Avatar + nome ─────────────────────────────────────────
                Section {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: authVM.currentUser?.avatarUrl ?? "")) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(Color("AccentColor"))
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .shadow(radius: 4)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(authVM.currentUser?.fullName.isEmpty == false
                                 ? authVM.currentUser!.fullName
                                 : authVM.currentUser?.displayName ?? "")
                                .font(.headline)

                            Text(authVM.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let role = authVM.currentUser?.sdRole {
                                RoleBadge(role: role)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // ── Sessione ──────────────────────────────────────────────
                Section("profile.session") {
                    LabeledContent("profile.user_id") {
                        Text("\(authVM.currentUser?.id ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("profile.role") {
                        Text(authVM.currentUser?.sdRole.displayName ?? "")
                            .foregroundStyle(.secondary)
                    }
                }

                // ── Azioni ────────────────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirm = true
                    } label: {
                        Label("auth.logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button(role: .destructive) {
                        showLogoutAllConfirm = true
                    } label: {
                        Label("auth.logout_all", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("profile.my_account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close") { dismiss() }
                }
            }
            .confirmationDialog("auth.logout_confirm", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("auth.logout", role: .destructive) {
                    authVM.logout()
                    dismiss()
                }
                Button("cancel", role: .cancel) {}
            }
            .confirmationDialog("auth.logout_all_confirm", isPresented: $showLogoutAllConfirm, titleVisibility: .visible) {
                Button("auth.logout_all", role: .destructive) {
                    Task {
                        await authVM.logoutAll()
                        dismiss()
                    }
                }
                Button("cancel", role: .cancel) {}
            }
        }
    }
}
