//
//  SafariView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI
import SafariServices

/// `.sheet(item:)` 需要 `Identifiable`，而 `URL` 本身不是，包一层。
///
/// 每次点击都新建一个实例（`id` 是新的 UUID），同一个链接才能反复弹出。
struct SafariItem: Identifiable {
    let id = UUID()
    let url: URL
}

/// 应用内 Safari：打开外部链接而不离开 App。
///
/// 只支持 http/https —— 遇到 `mailto:` 之类的 scheme 会**直接崩溃**，
/// 发邮件请走 `openURL`。
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    /// SFSafariViewController 自带的 Done 按钮不会清空 SwiftUI 的 binding，
    /// 必须在这里回调清零，否则关掉一次后再也弹不出来。
    var onFinish: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let onFinish: () -> Void

        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onFinish()
        }
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false

        let controller = SFSafariViewController(url: url, configuration: configuration)
        controller.delegate = context.coordinator
        controller.preferredControlTintColor = UIColor(Theme.primary)
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
