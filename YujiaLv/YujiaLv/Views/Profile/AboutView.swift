//
//  AboutView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI

/// 关于页。
struct AboutView: View {
    @Environment(\.openURL) private var openURL

    /// 法务页面统一走这个线上地址（服务条款与隐私政策是同一个页面）
    private static let legalURLString = "https://www.freeprivacypolicy.com/live/6fb2f7cc-5b40-4af9-b3f1-ddafed3c3b3f"

    /// 非 nil 时弹出应用内 Safari
    @State private var safari: SafariItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    // 与登录页同一份 logo 素材（Assets 里的 `logo`）
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                    Text("Kenis")
                        .font(.title.bold())
                        .foregroundColor(Theme.dark)
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.top, 24)

                Text("Kenis is your home for live tennis coaching, video-call lessons with professional coaches, and easy court reservations — all in one place.")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // 与 ProfileView.menuRow 保持同一种写法（不带 buttonStyle），
                // 保证这里的跳转行为和「我的 → About Us」完全一致。
                VStack(spacing: 0) {
                    NavigationLink(destination: CallHistoryView()) {
                        aboutRow(icon: "video", title: "Video Call Lessons", chevron: true)
                    }
                    .buttonStyle(AboutRowButtonStyle())
                    Divider().padding(.leading, 52)
                    NavigationLink(destination: ReservationsView()) {
                        aboutRow(icon: "calendar", title: "Court Reservations", chevron: true)
                    }
                    .buttonStyle(AboutRowButtonStyle())
                }
                .background(Theme.card)
                .cornerRadius(Theme.cornerRadius)
                .padding(.top, 8)

                VStack(spacing: 0) {
                    Button(action: openLegalPage) {
                        aboutRow(icon: "doc.text", title: "Terms of Service", chevron: true)
                    }
                    .buttonStyle(AboutRowButtonStyle())
                    Divider().padding(.leading, 52)
                    Button(action: openLegalPage) {
                        aboutRow(icon: "lock", title: "Privacy Policy", chevron: true)
                    }
                    .buttonStyle(AboutRowButtonStyle())
                    Divider().padding(.leading, 52)
                    Button(action: openSupportMail) {
                        aboutRow(icon: "envelope", title: "support@kenis.app")
                    }
                    .buttonStyle(AboutRowButtonStyle())
                }
                .background(Theme.card)
                .cornerRadius(Theme.cornerRadius)

                Text("© 2026 Kenis. All rights reserved.")
                    .font(.caption2)
                    .foregroundColor(Theme.secondaryText.opacity(0.7))
                    .padding(.top, 4)
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .sheet(item: $safari) { item in
            // SFSafariViewController 的 Done 不会自动清空 binding，必须回调清零
            SafariView(url: item.url) { safari = nil }
        }
    }

    // MARK: - 行操作

    /// 服务条款与隐私政策：在应用内打开线上页面。
    private func openLegalPage() {
        guard let url = URL(string: Self.legalURLString) else { return }
        safari = SafariItem(url: url)
    }

    /// 发邮件走 `openURL`：`SFSafariViewController` 遇到 `mailto:` 会直接崩溃。
    private func openSupportMail() {
        guard let url = URL(string: "mailto:support@kenis.app") else { return }
        openURL(url) { accepted in
            // 模拟器里没有邮件 App，会走到这里
            if !accepted { toast("No mail app available") }
        }
    }

    private func aboutRow(icon: String, title: String, chevron: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Theme.primary)
                .frame(width: 22)
            Text(title)
                .font(.body)
                .foregroundColor(Theme.dark)
            Spacer()
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        // 整行（含文字右侧的空白区）都算命中区域，避免只有文字能点
        .contentShape(Rectangle())
    }

}

/// About 页每一行的按下反馈。
///
/// 默认样式按下时只是很轻微地淡一下，不容易看出点击有没有落到这一行上，
/// 这里补一层浅底，让"点到了但没跳转"和"根本没点到"能一眼区分开。
private struct AboutRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Theme.divider : Color.clear)
    }
}

/// 纯文本页面（条款 / 隐私）。
struct TextPage: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.dark)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }
}
