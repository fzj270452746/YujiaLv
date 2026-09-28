//
//  MainTabView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 底部导航：首页 / 教练 / 发布(中) / 场馆 / 我的。
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var showCreate = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView { HomeView() }
                .navigationViewStyle(.stack)
                .tabItem { Image(systemName: selectedTab == 0 ? "house.fill" : "house") }
                .tag(0)

            NavigationView { CoachesView() }
                .navigationViewStyle(.stack)
                .tabItem { Image(systemName: selectedTab == 1 ? "person.2.fill" : "person.2") }
                .tag(1)

            // 发布入口（点击弹出发布页）
            Color.clear
                .tabItem { Image(systemName: "plus.circle.fill") }
                .tag(2)

            NavigationView { CourtsView() }
                .navigationViewStyle(.stack)
                .tabItem { Image(systemName: selectedTab == 3 ? "sportscourt.fill" : "sportscourt") }
                .tag(3)

            NavigationView { ProfileView() }
                .navigationViewStyle(.stack)
                .tabItem { Image(systemName: selectedTab == 4 ? "person.crop.circle.fill" : "person.crop.circle") }
                .tag(4)
        }
        .accentColor(Theme.primary)
        .onChange(of: selectedTab) { newValue in
            if newValue == 2 {
                showCreate = true
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .fullScreenCover(isPresented: $showCreate) {
            CreateView()
        }
    }
}
