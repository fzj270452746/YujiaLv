//
//  MyPostsView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 我的作品页。
struct MyPostsView: View {
    @EnvironmentObject var app: AppState

    private var myPosts: [Post] {
        app.posts.filter { $0.authorId == app.currentUser.id }
    }

    var body: some View {
        ScrollView {
            if myPosts.isEmpty {
                EmptyStateView(icon: "square.grid.2x2", message: "You haven't posted anything yet")
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(myPosts) { post in
                        VStack(alignment: .trailing, spacing: 6) {
                            PostCard(post: post)

                            Button(action: { delete(post) }) {
                                Label("Delete", systemImage: "trash")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Theme.danger)
                            }
                        }
                    }
                }
                .padding(Theme.pagePadding)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Posts")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }

    private func delete(_ post: Post) {
        app.deletePost(post.id)
        toast("Post deleted")
    }
}
