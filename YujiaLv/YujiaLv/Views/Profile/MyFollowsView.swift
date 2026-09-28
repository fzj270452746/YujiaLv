//
//  MyFollowsView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 我的关注页：展示已关注的教练与用户。
struct MyFollowsView: View {
    @EnvironmentObject var app: AppState

    private var followedCoaches: [Coach] {
        app.coaches.filter { app.isFollowing($0.id) }
    }

    private var followedUsers: [User] {
        var seen = Set<String>()
        var users: [User] = []
        for post in app.posts {
            let id = post.authorId
            if seen.contains(id) || !app.isFollowing(id) { continue }
            seen.insert(id)
            users.append(User(id: id, username: post.authorName, nickname: post.authorName, bio: "", avatarName: post.authorAvatar, isCoach: false))
        }
        return users
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !followedCoaches.isEmpty {
                    section(title: "Coaches") {
                        ForEach(followedCoaches) { coach in
                            NavigationLink(destination: CoachDetailView(coach: coach)) {
                                followRow(avatar: coach.avatarName, name: coach.name, subtitle: coach.title)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !followedUsers.isEmpty {
                    section(title: "Players") {
                        ForEach(followedUsers) { user in
                            NavigationLink(destination: UserProfileView(user: user)) {
                                followRow(avatar: user.avatarName, name: user.nickname, subtitle: user.bio)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if followedCoaches.isEmpty && followedUsers.isEmpty {
                    EmptyStateView(icon: "person.2", message: "You're not following anyone yet")
                        .padding(.top, 60)
                }
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Following")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.dark)
            VStack(spacing: 0) {
                content()
            }
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
        }
    }

    private func followRow(avatar: String, name: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            AvatarView(name: avatar, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.dark)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.secondaryText.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
