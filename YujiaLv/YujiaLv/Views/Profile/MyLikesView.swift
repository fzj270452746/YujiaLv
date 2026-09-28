//
//  MyLikesView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 我的点赞页。
struct MyLikesView: View {
    @EnvironmentObject var app: AppState

    private var likedPosts: [Post] {
        app.posts.filter { app.isLiked($0.id) }
    }

    var body: some View {
        ScrollView {
            if likedPosts.isEmpty {
                EmptyStateView(icon: "heart", message: "You haven't liked any posts yet")
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(likedPosts) { post in
                        PostCard(post: post)
                    }
                }
                .padding(Theme.pagePadding)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Likes")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }
}
