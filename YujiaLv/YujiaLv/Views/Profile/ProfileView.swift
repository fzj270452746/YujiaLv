//
//  ProfileView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 我的页面（设置页）。
struct ProfileView: View {
    @EnvironmentObject var app: AppState

    @State private var showLogin = false
    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var isLoading = false
    @State private var loadingMessage = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    if app.isLoggedIn {
                        loggedInHeader
                        menuList
                        accountActions
                    } else {
                        loggedOutView
                    }
                }
                .padding(.horizontal, Theme.pagePadding)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }

            if isLoading {
                LoadingOverlay(message: loadingMessage)
            }

            if showLogoutConfirm {
                ConfirmDialog(
                    title: "Log Out",
                    message: "Are you sure you want to log out?",
                    confirmTitle: "Log Out",
                    destructive: false,
                    onConfirm: { showLogoutConfirm = false; performLogout() },
                    onCancel: { showLogoutConfirm = false }
                )
            }

            if showDeleteConfirm {
                ConfirmDialog(
                    title: "Delete Account",
                    message: "This will permanently delete your account and all data. This action cannot be undone.",
                    confirmTitle: "Delete",
                    destructive: true,
                    onConfirm: { showDeleteConfirm = false; performDelete() },
                    onCancel: { showDeleteConfirm = false }
                )
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
    }

    // MARK: - 未登录

    private var loggedOutView: some View {
        VStack(spacing: 18) {
            AvatarView(name: "", size: 90)
            VStack(spacing: 8) {
                Text("Join Kenis")
                    .font(.title2.bold())
                    .foregroundColor(Theme.dark)
                Text("Sign in to follow coaches, post moments and book courts.")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            Button(action: { showLogin = true }) {
                Text("Sign In")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Theme.dark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.accent)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(.top, 6)
        }
        .padding(.top, 80)
    }

    // MARK: - 登录头部

    private var loggedInHeader: some View {
        VStack(spacing: 14) {
            NavigationLink(destination: EditProfileView()) {
                AvatarView(name: app.currentUser.avatarName, size: 78)
            }
            VStack(spacing: 4) {
                Text(app.currentUser.nickname)
                    .font(.title3.bold())
                    .foregroundColor(Theme.dark)
                if !app.currentUser.bio.isEmpty {
                    Text(app.currentUser.bio)
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(2)
                }
            }
            HStack(spacing: 0) {
                statItem(value: app.followIds.count, label: "Following")
                statItem(value: 128, label: "Followers")
                statItem(value: myPostsCount, label: "Posts")
            }
            .padding(.vertical, 12)
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
        }
        .padding(.top, 8)
    }

    private var myPostsCount: Int {
        app.posts.filter { $0.authorId == app.currentUser.id }.count
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(Theme.dark)
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 菜单

    private var menuList: some View {
        VStack(spacing: 0) {
            menuRow(icon: "pencil", title: "Edit Profile", destination: AnyView(EditProfileView()))
            Divider().padding(.leading, 48)
            menuRow(icon: "heart", title: "My Likes", destination: AnyView(MyLikesView()))
            Divider().padding(.leading, 48)
            menuRow(icon: "person.2", title: "Following", destination: AnyView(MyFollowsView()))
            Divider().padding(.leading, 48)
            menuRow(icon: "square.grid.2x2", title: "My Posts", destination: AnyView(MyPostsView()))
            Divider().padding(.leading, 48)
            menuRow(icon: "info.circle", title: "About Us", destination: AnyView(AboutView()))
        }
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
    }

    private func menuRow(icon: String, title: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                    .frame(width: 22)
                Text(title)
                    .font(.body)
                    .foregroundColor(Theme.dark)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
    }

    // MARK: - 账号操作

    private var accountActions: some View {
        VStack(spacing: 12) {
            Button(action: { showLogoutConfirm = true }) {
                Text("Log Out")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Theme.dark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.card)
                    .cornerRadius(Theme.cornerRadius)
            }
            Button(action: { showDeleteConfirm = true }) {
                Text("Delete Account")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Theme.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.card)
                    .cornerRadius(Theme.cornerRadius)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - 行为

    private func performLogout() {
        loadingMessage = "Logging out..."
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            app.logout()
        }
    }

    private func performDelete() {
        loadingMessage = "Deleting account..."
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            app.deleteAccount()
            toast("Account deleted")
        }
    }
}
