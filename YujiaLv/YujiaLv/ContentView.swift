//
//  ContentView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // 主界面在启动页底下提前挂载好：淡出时它已经渲染完，
            // 露出来的是画好的首屏，而不是一帧空白。
            MainTabView()

            if showSplash {
                SplashView { showSplash = false }
                    .zIndex(1)
            }
        }
        .overlay(ToastView().allowsHitTesting(false))
    }
}
