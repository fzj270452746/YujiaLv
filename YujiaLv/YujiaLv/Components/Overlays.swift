//
//  Overlays.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI

/// 全屏加载遮罩：登录/注册/退出/注销等操作展示约 1 秒加载动画。
struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(Theme.primary)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Theme.dark)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
        }
    }
}

/// 自定义二次确认弹窗。
struct ConfirmDialog: View {
    let title: String
    let message: String
    let confirmTitle: String
    var destructive: Bool = true
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture { onCancel() }
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(20)

                Divider()

                HStack(spacing: 0) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.body.weight(.medium))
                            .foregroundColor(Theme.secondaryText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    Rectangle()
                        .fill(Theme.divider)
                        .frame(width: 1)
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.body.weight(.semibold))
                            .foregroundColor(destructive ? Theme.danger : Theme.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 52)
            }
            .frame(maxWidth: 320)
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

/// 底部固定服务条款 / 隐私政策文案。
struct LegalFooter: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("By continuing you agree with Terms of Service & Privacy Policy")
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
            HStack(spacing: 6) {
                Text("Terms of Service")
                    .font(.caption)
                    .foregroundColor(Theme.primary)
                Text("·")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                Text("Privacy Policy")
                    .font(.caption)
                    .foregroundColor(Theme.primary)
            }
        }
        .padding(.bottom, 12)
    }
}
