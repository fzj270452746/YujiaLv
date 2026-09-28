//
//  UserProfileView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 用户个人主页（三级页面）。
struct UserProfileView: View {
    let user: User
    var presentedModally: Bool = false
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var showReport = false
    @State private var showLogin = false

    private var userPosts: [Post] {
        app.posts.filter { $0.authorId == user.id }
    }

    var body: some View {
        Group {
            if presentedModally {
                NavigationView { content }
                    .navigationViewStyle(.stack)
            } else {
                content
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    AvatarView(name: user.avatarName, size: 88)
                    VStack(spacing: 4) {
                        Text(user.nickname)
                            .font(.title3.bold())
                            .foregroundColor(Theme.dark)
                        if !user.bio.isEmpty {
                            Text(user.bio)
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                }
                .padding(.top, 8)

                HStack(spacing: 0) {
                    statItem(value: 86, label: "Followers")
                    statItem(value: 24, label: "Following")
                    statItem(value: userPosts.count, label: "Posts")
                }
                .padding(.vertical, 12)
                .background(Theme.card)
                .cornerRadius(Theme.cornerRadius)

                actionButtons

                VStack(alignment: .leading, spacing: 12) {
                    Text("Posts")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    if userPosts.isEmpty {
                        EmptyStateView(icon: "square.grid.2x2", message: "No posts yet")
                    } else {
                        ForEach(userPosts) { post in
                            // 这里展示的本来就是该用户的帖子，作者行不必再跳一次同一主页
                            PostCard(post: post, linkAuthorProfile: false)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(user.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if presentedModally {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.dark)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { requireLogin { showReport = true } }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Theme.dark)
                }
            }
        }
        .sheet(isPresented: $showReport) {
            ReportView(target: .user(user.id)) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
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

    /// 本应用没有好友/私信体系，他人主页只保留关注（交流走帖子评论回复）。
    private var actionButtons: some View {
        Button(action: { requireLogin { app.toggleFollow(user.id) } }) {
            Text(app.isFollowing(user.id) ? "Following" : "Follow")
                .font(.body.weight(.semibold))
                .foregroundColor(app.isFollowing(user.id) ? Theme.primary : Theme.dark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(app.isFollowing(user.id) ? Theme.primary.opacity(0.12) : Theme.accent)
                .cornerRadius(Theme.cornerRadius)
        }
    }

    private func requireLogin(_ action: () -> Void) {
        if app.isLoggedIn { action() } else { showLogin = true }
    }
}
