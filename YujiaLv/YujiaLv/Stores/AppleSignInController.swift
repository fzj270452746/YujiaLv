//
//  AppleSignInController.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import Foundation
import Combine
import AuthenticationServices
import UIKit

/// 发起真实的 Sign in with Apple 授权，并把结果回传给调用方。
///
/// 这里自己驱动 `ASAuthorizationController`（而不是用 SwiftUI 的
/// `SignInWithAppleButton`），因为按钮要走官方的 `ASAuthorizationAppleIDButton`，
/// 授权流程则集中在这一处，方便统一处理取消与各类失败。
///
/// 前置条件（缺一个都会走到 `.unknown` 失败分支）：
/// 1. 开发者后台的 App ID 勾选了 Sign in with Apple；
/// 2. 工程里带 `com.apple.developer.applesignin` 权限（见 `YujiaLv.entitlements`）；
/// 3. 真机 / 模拟器已登录 iCloud 账号。
final class AppleSignInController: NSObject, ObservableObject {

    /// 授权成功。`userIdentifier` 是 Apple 发给这个 App 的稳定用户标识，
    /// 同一个 Apple ID 每次返回都相同；`fullName` / `email` **只在首次授权时返回**，
    /// 之后都是 nil，所以拿到就要存下来。
    var onSuccess: ((_ userIdentifier: String, _ fullName: PersonNameComponents?, _ email: String?) -> Void)?

    /// 授权失败。参数为给用户看的一句话；**用户主动取消时为 nil**（不该弹提示）。
    /// 无论成功、失败还是取消，两个回调必定触发其中之一，调用方据此收尾 loading。
    var onFailure: ((_ message: String?) -> Void)?

    /// 防止按钮连点导致重复发起授权。
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private static func message(for error: Error) -> String {
        guard let authError = error as? ASAuthorizationError else {
            return "Apple Sign-In failed. Please try again."
        }
        switch authError.code {
        case .failed:
            return "Apple Sign-In failed. Please try again."
        case .invalidResponse:
            return "Apple returned an unexpected response. Please try again."
        case .notHandled:
            return "Apple Sign-In could not be completed."
        case .unknown:
            // 绝大多数情况是工程没配好 capability，或设备没登录 Apple ID
            return "Apple Sign-In is unavailable right now. Please sign in with your username instead."
        default:
            return "Apple Sign-In failed. Please try again."
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInController: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        isRunning = false

        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            // 请求里只有 Apple ID 一种凭据，正常不会走到这里
            onFailure?("Apple Sign-In failed. Please try again.")
            return
        }
        onSuccess?(credential.user, credential.fullName, credential.email)
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        isRunning = false

        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            // 用户在系统弹窗里点了取消，不是错误
            onFailure?(nil)
            return
        }
        onFailure?(Self.message(for: error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInController: ASAuthorizationControllerPresentationContextProviding {

    /// 授权弹窗的锚点窗口。取当前活跃的 key window——App 有
    /// `fullScreenCover`（登录页就是这么弹出来的），不能写死第一个 window。
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }

        return windows.first { $0.isKeyWindow } ?? windows.first ?? ASPresentationAnchor()
    }
}
