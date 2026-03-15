import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Componenti UI condivisi tra tutte le Views
// ─────────────────────────────────────────────────────────────────────────────

struct SDTextField: View {
    let icon: String
    let placeholder: LocalizedStringKey
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(14)
        .background(Color(.systemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }
}

struct SDSecureField: View {
    let icon: String
    let placeholder: LocalizedStringKey
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Group {
                if isVisible { TextField(placeholder, text: $text) }
                else         { SecureField(placeholder, text: $text) }
            }
            .textContentType(.password)
            .autocapitalization(.none)
            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }
}

struct SDButton: View {
    let title: LocalizedStringKey
    var isLoading = false
    var style: Style = .primary
    let action: () -> Void

    enum Style { case primary, secondary, destructive }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading { ProgressView().tint(.white) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return Color("AccentColor")
        case .secondary:   return Color(.systemGray5)
        case .destructive: return .red
        }
    }
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary:             return Color(.label)
        }
    }
}

struct SDCard<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        content()
            .padding(AppConstants.Design.cardPadding)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Design.cornerRadius))
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.4)
            Text("loading").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle).foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
            SDButton(title: "retry", action: retry)
                .frame(maxWidth: 200)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RoleBadge: View {
    let role: AppConstants.Role

    var body: some View {
        Text(role.displayName)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch role {
        case .diabeticDiver:  return .red
        case .diver:          return .blue
        case .medical:        return .green
        case .staff:          return .orange
        case .administrator:  return .purple
        case .subscriber:     return .gray
        }
    }
}
