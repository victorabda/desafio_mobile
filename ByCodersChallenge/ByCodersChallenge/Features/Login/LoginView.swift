//
//  LoginView.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    hero
                    loginCard
                    privacyNote
                }
                .frame(maxWidth: 560)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)

                copyrightNote
            }
            .background(background)
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var hero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.12))
                    .frame(width: 112, height: 112)

                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text("login.title")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("login.description")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("login.welcome")
                    .font(.title2.bold())

                Text("login.instructions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 14) {
                fieldContainer {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.blue)

                    TextField("login.email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("login_email_textfield")
                }

                fieldContainer {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.blue)

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
                    .font(.subheadline)
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
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isLoginButtonEnabled)
            .accessibilityIdentifier("login_button")
        }
        .padding(22)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.primary.opacity(0.08))
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24))
                .foregroundStyle(.blue)

            Text("login.privacy")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var copyrightNote: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "figure.wave.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.black)

            Text("login.copyright")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.10),
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
        HStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.primary.opacity(0.12))
        }
    }
}

#Preview("Login") {
    LoginView(viewModel: PreviewFactory.makeLoginViewModel())
}
