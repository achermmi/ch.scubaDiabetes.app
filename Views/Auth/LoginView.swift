import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email       = ""
    @State private var password    = ""
    @State private var show2FA     = false
    @State private var code2FA     = ""
    @FocusState private var focus: Field?

    enum Field { case email, password, code }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradiente subacqueo
                LinearGradient(
                    colors: [Color("OceanDeep"), Color("OceanMid")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 60)

                        // ── Logo ─────────────────────────────────────────
                        VStack(spacing: 12) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .shadow(color: .black.opacity(0.3), radius: 10)

                            Text("ScubaDiabetes")
                                .font(.title.bold())
                                .foregroundStyle(.white)

                            Text("login.tagline")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }

                        // ── Form ─────────────────────────────────────────
                        VStack(spacing: 16) {
                            if !show2FA {
                                credentialsForm
                            } else {
                                twoFAForm
                            }
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onChange(of: authVM.needs2FA) { _, needs in
            if needs { show2FA = true }
        }
    }

    // ── Credenziali ───────────────────────────────────────────────────────
    private var credentialsForm: some View {
        VStack(spacing: 16) {
            Text("login.title")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            SDTextField(
                icon: "envelope.fill",
                placeholder: "login.email",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            .focused($focus, equals: .email)

            SDSecureField(
                icon: "lock.fill",
                placeholder: "login.password",
                text: $password
            )
            .focused($focus, equals: .password)

            if let err = authVM.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            SDButton(title: "login.button", isLoading: authVM.isLoading) {
                focus = nil
                Task { await authVM.login(email: email, password: password) }
            }
            .disabled(email.isEmpty || password.count < 6)
        }
    }

    // ── 2FA ───────────────────────────────────────────────────────────────
    private var twoFAForm: some View {
        VStack(spacing: 16) {
            Text("login.2fa.title")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("login.2fa.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            SDTextField(
                icon: "key.fill",
                placeholder: "login.2fa.code",
                text: $code2FA,
                keyboardType: .numberPad
            )
            .focused($focus, equals: .code)

            if let err = authVM.errorMessage {
                Text(err).font(.caption).foregroundStyle(.red)
            }

            SDButton(title: "login.2fa.verify", isLoading: authVM.isLoading) {
                Task { await authVM.verify2FA(code: code2FA) }
            }
            .disabled(code2FA.count < 6)

            Button("login.2fa.back") {
                show2FA = false
                authVM.needs2FA = false
                authVM.errorMessage = nil
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}
