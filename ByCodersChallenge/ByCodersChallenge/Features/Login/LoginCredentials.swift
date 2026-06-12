//
//  LoginCredentials.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

struct LoginCredentials: Equatable {
    var email: String
    var password: String

    /// Intentionally light client-side validation (just enough to enable the
    /// button): Firebase Auth is the authority on credential correctness, and
    /// 6 characters mirrors its minimum password length.
    var isValid: Bool {
        email.contains("@") && password.count >= 6
    }
}
