//
//  LoginView.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var viewModel: LoginViewModel
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: isRegularWidth ? 48 : 32) {
                    if isRegularWidth {
                        HStack(alignment: .center, spacing: 64) {
                            VStack(spacing: 32) {
                                hero
                                privacyNote
                            }
                            .frame(maxWidth: 420)

                            loginCard
                                .frame(maxWidth: 520)
                        }
                    } else {
                        VStack(spacing: 32) {
                            hero
                            loginCard
                            privacyNote
                        }
                    }

                    copyrightNote
                }
                .frame(maxWidth: isRegularWidth ? 1080 : 560)
                .padding(.horizontal, isRegularWidth ? 48 : 24)
                .padding(.vertical, isRegularWidth ? 64 : 32)
                .frame(maxWidth: .infinity)
            }
            .background(background)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    private var hero: some View {
        VStack(spacing: isRegularWidth ? 24 : 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.12))
                    .frame(
                        width: isRegularWidth ? 168 : 112,
                        height: isRegularWidth ? 168 : 112
                    )

                Image(systemName: "map.fill")
                    .font(.system(size: isRegularWidth ? 72 : 48))
                    .foregroundStyle(.brandPrimary)
            }

            VStack(spacing: isRegularWidth ? 12 : 8) {
                Text("login.title")
                    .font(isRegularWidth ? .system(size: 46, weight: .bold) : .largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("login.description")
                    .font(isRegularWidth ? .title3 : .subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: isRegularWidth ? 28 : 20) {
            VStack(alignment: .leading, spacing: isRegularWidth ? 8 : 4) {
                Text("login.welcome")
                    .font(isRegularWidth ? .title.bold() : .title2.bold())

                Text("login.instructions")
                    .font(isRegularWidth ? .body : .subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: isRegularWidth ? 18 : 14) {
                fieldContainer {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.brandPrimary)

                    TextField("login.email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("login_email_textfield")
                }

                fieldContainer {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.brandPrimary)

                    Group {
                        if isPasswordVisible {
                            TextField("login.password", text: $viewModel.password)
                        } else {
                            SecureField("login.password", text: $viewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("login_password_securefield")

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        isPasswordVisible
                            ? Text("login.password.hide")
                            : Text("login.password.show")
                    )
                    .accessibilityIdentifier("login_password_visibility_button")
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(isRegularWidth ? .body : .subheadline)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("login_error_text")
            }

            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("login.sign_in")
                        Image(systemName: "arrow.right")
                    }
                }
                .font(isRegularWidth ? .headline : .body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isLoginButtonEnabled)
            .accessibilityIdentifier("login_button")
        }
        .padding(isRegularWidth ? 32 : 22)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: isRegularWidth ? 30 : 24))
        .overlay {
            RoundedRectangle(cornerRadius: isRegularWidth ? 30 : 24)
                .stroke(.primary.opacity(0.08))
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .center, spacing: isRegularWidth ? 16 : 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: isRegularWidth ? 36 : 24))
                .foregroundStyle(.brandPrimary)

            Text("login.privacy")
                .font(isRegularWidth ? .body : .caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var copyrightNote: some View {
        HStack(alignment: .center, spacing: isRegularWidth ? 16 : 12) {
            Image(systemName: "figure.wave.circle.fill")
                .font(.system(size: isRegularWidth ? 40 : 32))
                .foregroundStyle(.primary)

            Text("login.copyright")
                .font(isRegularWidth ? .body : .footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.top, isRegularWidth ? 32 : 0)
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.brandPrimary.opacity(0.10),
                Color(.systemBackground),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func fieldContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: isRegularWidth ? 16 : 12) {
            content()
        }
        .font(isRegularWidth ? .body : .callout)
        .padding(.horizontal, isRegularWidth ? 18 : 14)
        .frame(minHeight: isRegularWidth ? 62 : 52)
        .background(.background, in: RoundedRectangle(cornerRadius: isRegularWidth ? 18 : 14))
        .overlay {
            RoundedRectangle(cornerRadius: isRegularWidth ? 18 : 14)
                .stroke(.primary.opacity(0.12))
        }
    }
}

#Preview("Login") {
    LoginView(viewModel: PreviewFactory.makeLoginViewModel())
}

#Preview("Login - iPad", traits: .fixedLayout(width: 1180, height: 820)) {
    LoginView(viewModel: PreviewFactory.makeLoginViewModel())
        .environment(\.horizontalSizeClass, .regular)
}
