//
//  TabBarHidden.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI
import UIKit

extension View {
    /// 进入二级页面时隐藏底部 TabBar，返回上级后自动恢复。
    func hideTabBar() -> some View {
        modifier(TabBarHiddenModifier())
    }
}

/// iOS 16+ 使用原生 API；iOS 15 通过 UIKit 桥接隐藏。
private struct TabBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .tabBar)
        } else {
            content
                .onAppear { TabBarControllerBridge.setHidden(true) }
                .onDisappear { TabBarControllerBridge.setHidden(false) }
        }
    }
}

/// 遍历视图层级找到 UITabBarController 并切换 TabBar 显隐。
private enum TabBarControllerBridge {
    static func setHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows {
                    guard let tab = findTabBarController(in: window.rootViewController) else { continue }
                    tab.tabBar.isHidden = hidden
                }
            }
        }
    }

    private static func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        if let tab = viewController as? UITabBarController { return tab }
        for child in viewController.children {
            if let found = findTabBarController(in: child) { return found }
        }
        return nil
    }
}
