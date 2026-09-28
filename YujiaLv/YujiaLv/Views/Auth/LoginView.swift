//
//  LoginView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var loadingMessage = ""
    @StateObject private var appleSignIn = AppleSignInController()

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 22) {
                            // 「点空白收键盘」只包住表单这一段：官方 Apple 按钮是 UIKit 视图，
                            // 被带 tap 手势的父视图包住就收不到点击（详见 Theme.dismissKeyboardOnTap）。
                            VStack(spacing: 22) {
                                header
                                inputs
                                loginButton
                                divider
                            }
                            .dismissKeyboardOnTap()

                            appleButton

                            registerLink.dismissKeyboardOnTap()
                        }
                        .padding(.horizontal, Theme.pagePadding)
                        .padding(.top, 48)
                        .padding(.bottom, 24)
                    }
                    LegalFooter()
                }

                if isLoading {
                    LoadingOverlay(message: loadingMessage)
                }
            }
            // 登录页是 fullScreenCover 弹出来的，会盖住 ContentView 上挂的全局 ToastView，
            // 所以这里自己挂一份，否则「用户名或密码错误」之类的提示根本看不见。
            .overlay(ToastView().allowsHitTesting(false))
            .onAppear(perform: bindAppleSignIn)
            .overlay(alignment: .topLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(Theme.card)
                        .clipShape(Circle())
                }
                .padding(.top, 12)
                .padding(.leading, 16)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .onChange(of: app.isLoggedIn) { loggedIn in
            if loggedIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // MARK: - 头部

    private var header: some View {
        VStack(spacing: 12) {
            // 用 Assets 里的 `logo` 素材：图标本身自带圆角与渐变底，不要再套圆形背景
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
            Text("Kenis")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.dark)
            Text("Live tennis coaching, anytime, anywhere")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - 输入框

    private var inputs: some View {
        VStack(spacing: 14) {
            TextField("Username", text: $username)
                .textFieldStyle(KTextFieldStyle(icon: "person"))
                .autocapitalization(.none)
                .disableAutocorrection(true)
            SecureField("Password", text: $password)
                .textFieldStyle(KTextFieldStyle(icon: "lock"))
        }
    }

    // MARK: - 登录按钮

    private var loginButton: some View {
        Button(action: performLogin) {
            Text("Sign In")
                .font(.body.weight(.semibold))
                .foregroundColor(Theme.dark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accent)
                .cornerRadius(Theme.cornerRadius)
        }
    }

    private var divider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Theme.divider).frame(height: 1)
            Text("or")
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
            Rectangle().fill(Theme.divider).frame(height: 1)
        }
    }

    // MARK: - Apple 登录

    /// 用 Apple 官方的 `ASAuthorizationAppleIDButton`（不能自绘），高度对齐上面的 Sign In。
    private var appleButton: some View {
        AppleSignInButton(cornerRadius: Theme.cornerRadius) {
            performAppleLogin()
        }
        .frame(height: 52)
    }

    // MARK: - 注册入口

    private var registerLink: some View {
        NavigationLink(destination: RegisterView()) {
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(Theme.secondaryText)
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primary)
            }
            .font(.subheadline)
        }
    }

    // MARK: - 行为

    private func performLogin() {
        guard !username.isEmpty, !password.isEmpty else {
            toast("Please enter your username and password")
            return
        }
        loadingMessage = "Signing in..."
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            if app.login(username: username, password: password) {
                // 登录成功，根视图由 isLoggedIn 自动切换
            } else {
                toast("Invalid username or password")
            }
        }
    }

    /// 把授权结果接回登录态。成功 / 失败 / 取消都会走其中之一，所以 loading 一定会收掉。
    private func bindAppleSignIn() {
        appleSignIn.onSuccess = { userIdentifier, fullName, email in
            isLoading = false
            app.signInWithApple(userIdentifier: userIdentifier, fullName: fullName, email: email)
        }
        appleSignIn.onFailure = { message in
            isLoading = false
            // 用户自己在系统弹窗里点了取消，不打扰
            if let message { toast(message) }
        }
    }

    private func performAppleLogin() {
        loadingMessage = "Signing in with Apple..."
        isLoading = true
        appleSignIn.start()
    }
}

/// 统一输入框样式。
struct KTextFieldStyle: TextFieldStyle {
    let icon: String

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Theme.secondaryText)
                .frame(width: 18)
            configuration
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.divider, lineWidth: 1)
        )
    }
}
