//
//  PostDetailView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 帖子详情页：完整媒体、评论、点赞、举报。
struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var app: AppState

    @State private var showReport = false
    @State private var showLogin = false
    @State private var commentText = ""
    @State private var reportComment: Comment?
    @State private var fullscreenImage: FullscreenImage?

    private var currentPost: Post {
        app.posts.first(where: { $0.id == post.id }) ?? post
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    authorRow
                    Text(currentPost.content)
                        .font(.body)
                        .foregroundColor(Theme.dark)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if !currentPost.mediaNames.isEmpty {
                        mediaGallery
                    }

                    actionRow
                    Divider()
                    commentsSection
                }
                .padding(Theme.pagePadding)
                .padding(.bottom, 12)
            }

            commentInputBar
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { requireLogin { showReport = true } }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Theme.dark)
                }
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .fullScreenCover(item: $reportComment) { comment in
            ReportView(target: .comment(postId: currentPost.id, commentId: comment.id))
        }
        .sheet(isPresented: $showReport) {
            ReportView(target: .post(currentPost.id))
        }
        .fullScreenCover(item: $fullscreenImage) { image in
            ImageFullscreenView(name: image.id)
        }
    }

    // MARK: - 作者

    private var authorRow: some View {
        PostAuthorRow(post: currentPost, avatarSize: 42)
    }

    // MARK: - 媒体

    private var mediaGallery: some View {
        TabView {
            ForEach(currentPost.mediaNames.indices, id: \.self) { index in
                let name = currentPost.mediaNames[index]
                let isVideo = currentPost.mediaIsVideo[index]
                if isVideo {
                    AssetVideo(name: name)
                        .frame(height: 320)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(Theme.cornerRadius)
                } else {
                    AssetImage(name: name, fallbackSystemImage: "photo")
                        .frame(height: 320)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(Theme.cornerRadius)
                        .onTapGesture { fullscreenImage = FullscreenImage(id: name) }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 340)
    }

    // MARK: - 点赞

    private var actionRow: some View {
        HStack(spacing: 24) {
            Button(action: { requireLogin { app.toggleLike(currentPost.id) } }) {
                Label("\(currentPost.likeCount)", systemImage: currentPost.isLiked ? "heart.fill" : "heart")
                    .foregroundColor(currentPost.isLiked ? Theme.danger : Theme.dark)
            }
            Label("\(currentPost.comments.count)", systemImage: "bubble.left")
                .foregroundColor(Theme.dark)
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(Theme.dark)
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }

    // MARK: - 评论

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comments (\(currentPost.comments.count))")
                .font(.headline)
                .foregroundColor(Theme.dark)

            if currentPost.comments.isEmpty {
                EmptyStateView(icon: "bubble.left", message: "No comments yet. Be the first to comment.")
            } else {
                ForEach(currentPost.comments) { comment in
                    CommentRow(
                        comment: comment,
                        isOwn: comment.authorId == app.currentUser.id,
                        onReport: { requireLogin { reportComment = comment } },
                        onDelete: {
                            app.deleteComment(from: currentPost.id, commentId: comment.id)
                            toast("Comment deleted")
                        }
                    )
                }
            }
        }
    }

    // MARK: - 评论输入

    private var commentInputBar: some View {
        HStack(spacing: 10) {
            TextField("Add a comment...", text: $commentText)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.divider.opacity(0.6))
                .cornerRadius(20)
            Button(action: { requireLogin { sendComment() } }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.primary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.card)
    }

    private func sendComment() {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        app.addComment(to: currentPost.id, content: commentText)
        commentText = ""
    }

    private func requireLogin(_ action: () -> Void) {
        if app.isLoggedIn { action() } else { showLogin = true }
    }
}

// MARK: - 评论行

struct CommentRow: View {
    let comment: Comment
    /// 是否为我自己的评论（自己的评论可删除，他人的可举报）
    let isOwn: Bool
    let onReport: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            avatar
            VStack(alignment: .leading, spacing: 3) {
                Text(comment.authorName)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Theme.dark)
                Text(comment.content)
                    .font(.subheadline)
                    .foregroundColor(Theme.dark)
                Text(comment.timestamp.relativeTime())
                    .font(.caption2)
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
            Menu {
                if isOwn {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } else {
                    Button(action: onReport) {
                        Label("Report", systemImage: "flag")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
        }
    }

    /// 评论者头像：他人的头像可点进其个人主页。
    @ViewBuilder
    private var avatar: some View {
        if isOwn {
            AvatarView(name: comment.authorAvatar, size: 34)
        } else {
            NavigationLink(destination: UserProfileView(user: comment.author)) {
                AvatarView(name: comment.authorAvatar, size: 34)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - 图片全屏

/// 待全屏查看的图片。
///
/// 用 `fullScreenCover(item:)` 承载：资源名与「是否呈现」由同一个状态驱动，
/// 避免 `isPresented` + 另一个 `@State` 分开赋值时，cover 闭包读到旧的空资源名
/// （表现为大图只显示占位渐变，看不到实际图片）。
struct FullscreenImage: Identifiable {
    /// 资源名，同时作为 `item` 的身份标识。
    let id: String
}

struct ImageFullscreenView: View {
    let name: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AssetImage(name: name, fallbackSystemImage: "photo", contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBar(hidden: true)
        .onTapGesture { presentationMode.wrappedValue.dismiss() }
        .overlay(alignment: .topTrailing) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
    }
}
