//
//  RegisterView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

struct RegisterView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.dark)
                        Text("Join Kenis to start your tennis journey")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 12)

                    VStack(spacing: 14) {
                        TextField("Username", text: $username)
                            .textFieldStyle(KTextFieldStyle(icon: "person"))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        SecureField("Password", text: $password)
                            .textFieldStyle(KTextFieldStyle(icon: "lock"))
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(KTextFieldStyle(icon: "lock.fill"))
                    }

                    Button(action: performRegister) {
                        Text("Sign Up")
                            .font(.body.weight(.semibold))
                            .foregroundColor(Theme.dark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.accent)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.top, 4)

                    LegalFooter()
                }
                .padding(.horizontal, Theme.pagePadding)
            }

            if isLoading {
                LoadingOverlay(message: "Creating account...")
            }
        }
        .dismissKeyboardOnTap()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func performRegister() {
        guard !username.isEmpty, !password.isEmpty else {
            toast("Please fill in all fields")
            return
        }
        guard password == confirmPassword else {
            toast("Passwords do not match")
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            if let error = app.register(username: username, password: password) {
                toast(error)
            } else {
                toast("Account created successfully")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
