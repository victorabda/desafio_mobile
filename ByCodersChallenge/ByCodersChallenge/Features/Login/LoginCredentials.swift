//
//  LoginCredentials.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

struct LoginCredentials: Equatable {
    var email: String
    var password: String

    var isValid: Bool {
        email.contains("@") && password.count >= 6
    }
}
