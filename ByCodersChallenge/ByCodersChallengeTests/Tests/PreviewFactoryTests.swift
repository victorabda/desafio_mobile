//
//  PreviewFactoryTests.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Testing
@testable import ByCodersChallenge

@MainActor
struct PreviewFactoryTests {
    @Test
    func loginViewModelCompletesPreviewLoginFlow() async {
        let sut = PreviewFactory.makeLoginViewModel()
        sut.email = "teste@teste.com"
        sut.password = "123456"
        #expect(sut.isLoginButtonEnabled)

        await sut.login()

        #expect(sut.errorMessage == nil)
        #expect(!sut.isLoading)
    }

    @Test
    func homeViewModelLoadsPreviewLocation() async {
        let sut = PreviewFactory.makeHomeViewModel()
        #expect(sut.userDisplayName == "Usuário Preview")

        await sut.load()

        #expect(sut.state == .loaded(UserLocation(latitude: -23.5505, longitude: -46.6333)))
    }

    @Test
    func homeViewModelCompletesPreviewLogoutFlow() async {
        let sut = PreviewFactory.makeHomeViewModel()

        await sut.logout()

        #expect(sut.logoutErrorMessage == nil)
        #expect(!sut.isLoggingOut)
        #expect(sut.userDisplayName == L10n.genericUser)
    }
}
