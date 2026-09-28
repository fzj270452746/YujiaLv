//
//  Theme.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import UIKit

/// 全局主题：颜色、字体、通用样式常量。
enum Theme {

    // MARK: - 品牌色

    /// 主色：草地绿
    static let primary = Color(hex: 0x4CAF50)
    /// 强调色：网球荧光黄绿
    static let accent = Color(hex: 0xC6F432)
    /// 深色：文字 / 深色元素
    static let dark = Color(hex: 0x1B1B2F)
    /// 次级文字
    static let secondaryText = Color(hex: 0x8A8A9E)
    /// 背景：浅灰白
    static let background = Color(hex: 0xF7F8FA)
    /// 卡片背景
    static let card = Color.white
    /// 分割线
    static let divider = Color(hex: 0xECECF2)
    /// 危险色（举报 / 注销）
    static let danger = Color(hex: 0xE5484D)
    /// 在线状态色
    static let online = Color(hex: 0x22C55E)

    // MARK: - 渐变

    /// 品牌渐变（主色 -> 深绿）
    static let brandGradient = LinearGradient(
        colors: [Color(hex: 0x66BB6A), Color(hex: 0x1E5A3A)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 资源缺失时的兜底渐变
    static let fallbackGradient = LinearGradient(
        colors: [Color(hex: 0xE8F5E9), Color(hex: 0xC8E6C9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - 圆角

    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10

    // MARK: - 间距

    static let pagePadding: CGFloat = 16
}

// MARK: - Color 十六进制扩展

extension Color {
    /// 使用 0xRRGGBB 形式初始化颜色。
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - 视图修饰符

extension View {
    /// 标准卡片样式。
    func cardStyle() -> some View {
        self
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    /// 点击空白处收起键盘。
    ///
    /// ⚠️ 只对**纯 SwiftUI** 的内容用。这个手势会把子树里 UIKit 视图的点击整个吃掉
    /// （`onTapGesture` 与 `simultaneousGesture` 实测都会），官方
    /// `ASAuthorizationAppleIDButton` 这类控件一旦被它包住就会「点了完全没反应」。
    /// 所以登录页把 Apple 按钮留在了手势之外。
    func dismissKeyboardOnTap() -> some View {
        self
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
    }
}
