//
//  YujiaLvApp.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

@main
struct YujiaLvApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var giftStore = GiftStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(giftStore)
        }
    }
}
