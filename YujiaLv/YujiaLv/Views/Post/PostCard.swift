//
//  PostCard.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI

/// 帖子卡片：列表、作品页、用户主页复用。
///
/// 卡片自带两处跳转：作者头像 / 昵称 → 作者个人主页，卡片正文 → 帖子详情。
/// 两者是并列的 `NavigationLink` 而不是嵌套（嵌套时 iOS 15 上内层链接的点按会被外层吞掉），
/// 因此调用方只需放一张 `PostCard`，不要再往外套 `NavigationLink`。
struct PostCard: View {
    let post: Post
    var showAuthor: Bool = true
    /// 作者头像是否可点进其个人主页。在「该用户自己的主页」里展示其帖子时置为 false，避免推入重复页面。
    var linkAuthorProfile: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showAuthor {
                PostAuthorRow(post: post, linkProfile: linkAuthorProfile)
            }

            NavigationLink(destination: PostDetailView(post: post)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.content)
                        .font(.body)
                        .foregroundColor(Theme.dark)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let firstName = post.mediaNames.first {
                        if post.mediaIsVideo.first == true {
                            AssetVideo(name: firstName)
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(Theme.cornerRadiusSmall)
                        } else {
                            AssetImage(name: firstName, fallbackSystemImage: "photo")
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                    }

                    statsRow
                }
                // 让正文整块可点，包括文字与图片之间的空隙
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var statsRow: some View {
        HStack(spacing: 20) {
            Label("\(post.likeCount)", systemImage: post.isLiked ? "heart.fill" : "heart")
                .foregroundColor(post.isLiked ? Theme.danger : Theme.secondaryText)
            Label("\(post.comments.count)", systemImage: "bubble.left")
                .foregroundColor(Theme.secondaryText)
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(Theme.secondaryText)
        }
        .font(.caption)
    }
}

// MARK: - 作者行

/// 帖子作者行：头像 + 昵称 + 时间。作者不是本人时，头像与昵称可点进其个人主页。
/// 帖子卡片与帖子详情页共用。
struct PostAuthorRow: View {
    let post: Post
    var avatarSize: CGFloat = 40
    /// 是否允许点进作者个人主页。在「本人的帖子」或「该用户自己的主页」里展示时关掉。
    var linkProfile: Bool = true

    @EnvironmentObject var app: AppState

    private var canOpenProfile: Bool {
        linkProfile && !post.authorId.isEmpty && post.authorId != app.currentUser.id
    }

    var body: some View {
        Group {
            if canOpenProfile {
                NavigationLink(destination: UserProfileView(user: post.author)) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        HStack(spacing: 10) {
            AvatarView(name: post.authorAvatar, size: avatarSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(post.authorName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.dark)
                Text(post.timestamp.relativeTime())
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
        }
    }
}

// MARK: - Date 相对时间

extension Date {
    func relativeTime() -> String {
        let interval = -timeIntervalSinceNow
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}
