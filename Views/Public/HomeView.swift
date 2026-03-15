import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM:    AuthViewModel
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // ── Hero ─────────────────────────────────────────────
                    heroSection

                    VStack(spacing: AppConstants.Design.sectionSpacing) {
                        // ── Missione ─────────────────────────────────────
                        missionSection

                        // ── Quick Actions per utenti autenticati ─────────
                        if let user = authVM.currentUser {
                            quickActionsSection(user: user)
                        }

                        // ── Stats association ────────────────────────────
                        statsSection

                        // ── Contatti ─────────────────────────────────────
                        contactSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, AppConstants.Design.sectionSpacing)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let user = authVM.currentUser {
                        NavigationLink(destination: UserProfileSheetView()) {
                            AsyncImage(url: URL(string: user.avatarUrl ?? "")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundStyle(Color("AccentColor"))
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }

    // ── Hero section ──────────────────────────────────────────────────────
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color("OceanDeep"), Color("OceanMid")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 260)

            VStack(spacing: 8) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.3), radius: 8)

                Text("ScubaDiabetes")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("home.hero.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 32)
        }
    }

    // ── Missione ──────────────────────────────────────────────────────────
    private var missionSection: some View {
        SDCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("home.mission.title", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))

                Text("home.mission.body")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // ── Quick Actions ─────────────────────────────────────────────────────
    @ViewBuilder
    private func quickActionsSection(user: SDUser) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: String(localized: "home.welcome"), (user.displayName ?? "").isEmpty ? user.email : (user.displayName ?? user.email)))
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if user.sdRole.isDiver {
                    QuickActionCard(icon: "book.closed.fill", color: .blue, title: "home.action.logbook") {
                        appRouter.navigate(to: .logbook)
                    }
                }
                QuickActionCard(icon: "person.fill", color: .teal, title: "home.action.profile") {
                    appRouter.navigate(to: .profile)
                }
                if user.sdRole.canViewAll {
                    QuickActionCard(icon: "cross.case.fill", color: .green, title: "home.action.medical") {
                        appRouter.navigate(to: .medical)
                    }
                }
                if user.sdRole == .staff || user.sdRole == .administrator {
                    QuickActionCard(icon: "person.3.fill", color: .orange, title: "home.action.members") {
                        appRouter.navigate(to: .members)
                    }
                }
            }
        }
    }

    // ── Stats ─────────────────────────────────────────────────────────────
    private var statsSection: some View {
        SDCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("home.stats.title", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))

                HStack(spacing: 0) {
                    StatItem(value: "500+", label: "home.stats.dives")
                    Divider().frame(height: 40)
                    StatItem(value: "50+",  label: "home.stats.members")
                    Divider().frame(height: 40)
                    StatItem(value: "4",    label: "home.stats.languages")
                }
            }
        }
    }

    // ── Contatti ─────────────────────────────────────────────────────────
    private var contactSection: some View {
        SDCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("home.contact.title", systemImage: "envelope.fill")
                    .font(.headline)
                    .foregroundStyle(Color("AccentColor"))

                Link("info@scubadiabetes.ch", destination: URL(string: "mailto:info@scubadiabetes.ch")!)
                    .font(.subheadline)

                Link("scubadiabetes.ch", destination: URL(string: "https://scubadiabetes.ch")!)
                    .font(.subheadline)
            }
        }
    }
}

// ── Quick Action Card ─────────────────────────────────────────────────────

struct QuickActionCard: View {
    let icon:  String
    let color: Color
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

struct StatItem: View {
    let value: String
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AccentColor"))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
