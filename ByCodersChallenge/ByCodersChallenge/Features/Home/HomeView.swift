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
            guard newPhase == .active, viewModel.state == .permissionDenied else { return }

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

    private var userHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)

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
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.12))
                        .frame(width: 120, height: 120)

                    Image(systemName: "map.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.blue)
                }

                VStack(spacing: 8) {
                    Text("permission.title")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("permission.description")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 16) {
                    permissionBenefit(
                        icon: "mappin.and.ellipse",
                        title: "permission.show_position.title",
                        message: "permission.show_position.message"
                    )

                    permissionBenefit(
                        icon: "externaldrive.fill",
                        title: "permission.save_location.title",
                        message: "permission.save_location.message"
                    )

                    permissionBenefit(
                        icon: "lock.shield.fill",
                        title: "permission.privacy.title",
                        message: "permission.privacy.message"
                    )
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))

                Button {
                    openSettings()
                } label: {
                    Label("permission.open_settings", systemImage: "gear")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("home_open_settings_button")
            }
            .padding(24)
        }
    }

    private func permissionBenefit(
        icon: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
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
