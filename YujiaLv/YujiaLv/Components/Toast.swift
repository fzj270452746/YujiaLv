//
//  Toast.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 全局文本提示管理器：所有提示场景统一复用。
final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var message: String = ""
    @Published var isPresented: Bool = false

    private var workItem: DispatchWorkItem?

    func show(_ message: String) {
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.isPresented = false
            }
        }
        workItem = item
        withAnimation(.easeIn(duration: 0.2)) {
            self.message = message
            self.isPresented = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: item)
    }
}

/// Toast 视图：悬浮在顶部的小卡片。
struct ToastView: View {
    @ObservedObject private var manager = ToastManager.shared

    var body: some View {
        VStack {
            if manager.isPresented {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.accent)
                    Text(manager.message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Theme.dark.opacity(0.92))
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 4)
                .padding(.top, 8)
            }
            Spacer()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: manager.isPresented)
    }
}

// MARK: - 便捷方法

extension View {
    /// 弹出一个全局 Toast 提示。
    func toast(_ message: String) {
        ToastManager.shared.show(message)
    }
}
