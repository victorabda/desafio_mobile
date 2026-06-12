//
//  HomeView.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject var viewModel: HomeViewModel
    @State private var isShowingLogoutConfirmation = false

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                statusView(
                    icon: "location.magnifyingglass",
                    title: "home.loading.title",
                    message: Text("home.loading.message")
                ) {
                    ProgressView()
                        .controlSize(.large)
                }
                .accessibilityIdentifier("home_loading")

            case let .loaded(location):
                UserLocationMapView(location: location)
                    .ignoresSafeArea(edges: .bottom)
                    .accessibilityIdentifier("home_map")

            case let .staleLocation(location, reason):
                UserLocationMapView(location: location)
                    .ignoresSafeArea(edges: .bottom)
                    .accessibilityIdentifier("home_map")
                    .overlay(alignment: .top) {
                        staleLocationBanner(reason: reason)
                    }

            case .permissionDenied:
                locationPermissionView

            case let .failed(message):
                statusView(
                    icon: "exclamationmark.triangle.fill",
                    title: "home.error.title",
                    message: Text(message)
                ) {
                    Button("common.retry") {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .accessibilityIdentifier("home_error")
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            userHeader
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.load()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, shouldReloadOnForeground else { return }

            Task {
                await viewModel.load()
            }
        }
        .confirmationDialog(
            "home.logout.confirmation",
            isPresented: $isShowingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("common.logout", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
            Button("common.cancel", role: .cancel) {}
        }
        .alert(
            "home.logout.error.title",
            isPresented: Binding(
                get: { viewModel.logoutErrorMessage != nil },
                set: { if !$0 { viewModel.logoutErrorMessage = nil } }
            )
        ) {
            Button("common.ok") {
                viewModel.logoutErrorMessage = nil
            }
        } message: {
            Text(viewModel.logoutErrorMessage ?? "")
        }
    }

    /// Permission-blocked states are retried when the app returns to the
    /// foreground, since the user may have just granted access in Settings.
    private var shouldReloadOnForeground: Bool {
        switch viewModel.state {
        case .permissionDenied, .staleLocation(_, reason: .permissionDenied):
            true
        default:
            false
        }
    }

    /// Shown over the map when displaying a persisted (possibly outdated)
    /// location; the action adapts to the failure that caused the fallback.
    private func staleLocationBanner(reason: HomeViewModel.StaleLocationReason) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title3)
                .foregroundStyle(.brandWarning)

            VStack(alignment: .leading, spacing: 8) {
                Text("home.stale_location.message")
                    .font(.subheadline)

                if reason == .permissionDenied {
                    Button {
                        openSettings()
                    } label: {
                        Label("permission.open_settings", systemImage: "gear")
                    }
                    .font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier("home_stale_open_settings_button")
                } else {
                    Button("common.retry") {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier("home_stale_retry_button")
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .frame(maxWidth: 560)
        .padding()
        // `children: .contain` keeps the banner as a queryable container
        // without propagating its identifier over the buttons' own ones.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home_stale_location_banner")
    }

    private var userHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.brandPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text("home.greeting")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(viewModel.userDisplayName)
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                isShowingLogoutConfirmation = true
            } label: {
                if viewModel.isLoggingOut {
                    ProgressView()
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isLoggingOut)
            .accessibilityLabel(Text("common.logout"))
            .accessibilityIdentifier("home_logout_button")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private var locationPermissionView: some View {
        ScrollView {
            Group {
                if horizontalSizeClass == .regular {
                    HStack(alignment: .center, spacing: 64) {
                        permissionIntroduction
                            .frame(maxWidth: 380)

                        VStack(spacing: 28) {
                            permissionBenefits
                            openSettingsButton
                        }
                        .frame(maxWidth: 520)
                    }
                } else {
                    VStack(spacing: 24) {
                        permissionIntroduction
                        permissionBenefits
                        openSettingsButton
                    }
                }
            }
            .frame(maxWidth: 1040)
            .padding(.horizontal, horizontalSizeClass == .regular ? 48 : 24)
            .padding(.vertical, horizontalSizeClass == .regular ? 64 : 24)
            .frame(maxWidth: .infinity)
        }
        .background(permissionBackground)
    }

    private var permissionIntroduction: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 24 : 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.12))
                    .frame(
                        width: horizontalSizeClass == .regular ? 176 : 120,
                        height: horizontalSizeClass == .regular ? 176 : 120
                    )

                Image(systemName: "map.fill")
                    .font(.system(size: horizontalSizeClass == .regular ? 76 : 52))
                    .foregroundStyle(.brandPrimary)
            }

            VStack(spacing: horizontalSizeClass == .regular ? 12 : 8) {
                Text("permission.title")
                    .font(horizontalSizeClass == .regular ? .system(size: 40, weight: .bold) : .title2.bold())
                    .multilineTextAlignment(.center)

                Text("permission.description")
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var permissionBenefits: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 24 : 16) {
            permissionBenefit(
                icon: "mappin.and.ellipse",
                title: "permission.show_position.title",
                message: "permission.show_position.message"
            )

            Divider()

            permissionBenefit(
                icon: "externaldrive.fill",
                title: "permission.save_location.title",
                message: "permission.save_location.message"
            )

            Divider()

            permissionBenefit(
                icon: "lock.shield.fill",
                title: "permission.privacy.title",
                message: "permission.privacy.message"
            )
        }
        .padding(horizontalSizeClass == .regular ? 32 : 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.primary.opacity(0.08))
        }
    }

    private var openSettingsButton: some View {
        Button {
            openSettings()
        } label: {
            Label("permission.open_settings", systemImage: "gear")
                .fontWeight(.semibold)
                .frame(maxWidth: horizontalSizeClass == .regular ? 280 : .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityIdentifier("home_open_settings_button")
    }

    private var permissionBackground: some View {
        LinearGradient(
            colors: [
                Color.brandPrimary.opacity(0.08),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func permissionBenefit(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: horizontalSizeClass == .regular ? 18 : 12) {
            Image(systemName: icon)
                .font(horizontalSizeClass == .regular ? .title2 : .title3)
                .foregroundStyle(.brandPrimary)
                .frame(width: horizontalSizeClass == .regular ? 38 : 28)

            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 6 : 3) {
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title3.weight(.semibold) : .headline)

                Text(message)
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusView<Accessory: View>(
        icon: String,
        title: LocalizedStringKey,
        message: Text,
        @ViewBuilder accessory: () -> Accessory
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            message
        } actions: {
            accessory()
        }
        .padding()
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

#Preview("Home") {
    NavigationStack {
        HomeView(viewModel: PreviewFactory.makeHomeViewModel())
    }
}

#Preview("Permission Denied - iPad", traits: .fixedLayout(width: 1180, height: 820)) {
    NavigationStack {
        HomeView(viewModel: PreviewFactory.makePermissionDeniedHomeViewModel())
            .environment(\.horizontalSizeClass, .regular)
    }
}
