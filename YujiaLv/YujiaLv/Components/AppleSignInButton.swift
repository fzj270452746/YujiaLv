//
//  AppleSignInButton.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI
import AuthenticationServices

/// 官方「Sign in with Apple」按钮。
///
/// 必须用 Apple 提供的 `ASAuthorizationAppleIDButton`，不能自绘（图标、字号、
/// 文字与图标间距、配色都有硬性规定），否则审核可能被拒。
/// 这里只按 App 的卡片风格改圆角，其余保持官方默认。
struct AppleSignInButton: UIViewRepresentable {
    let cornerRadius: CGFloat
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.cornerRadius = cornerRadius
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.tapped),
            for: .touchUpInside
        )
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        uiView.cornerRadius = cornerRadius
        context.coordinator.action = action
    }

    final class Coordinator {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func tapped() {
            action()
        }
    }
}
