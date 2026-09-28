//
//  HomeView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 首页：顶部为 Live / Posts 分段，直播列表 + 帖子社区。
struct HomeView: View {
    @EnvironmentObject var app: AppState
    @State private var segment = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            segmentPicker
            if segment == 0 {
                LiveFeed()
            } else {
                PostsFeed()
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Kenis")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.dark)
                Text("Live tennis coaching & community")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, Theme.pagePadding)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private var segmentPicker: some View {
        HStack(spacing: 6) {
            segmentButton(title: "Live", index: 0)
            segmentButton(title: "Posts", index: 1)
        }
        .padding(4)
        .background(Theme.divider.opacity(0.6))
        .cornerRadius(24)
        .padding(.horizontal, Theme.pagePadding)
        .padding(.bottom, 12)
    }

    private func segmentButton(title: String, index: Int) -> some View {
        Button(action: { withAnimation { segment = index } }) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(segment == index ? Theme.dark : Theme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(segment == index ? Theme.card : Color.clear)
                .cornerRadius(20)
                .shadow(color: segment == index ? Color.black.opacity(0.06) : .clear, radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 直播列表

struct LiveFeed: View {
    @EnvironmentObject var app: AppState
    @State private var selectedStream: LiveStream?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let featured = app.liveStreams.first {
                    LiveFeaturedCard(stream: featured) {
                        selectedStream = featured
                    }
                }
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(app.liveStreams.dropFirst()) { stream in
                        LiveCard(stream: stream) {
                            selectedStream = stream
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.bottom, 24)
        }
        .fullScreenCover(item: $selectedStream) { stream in
            LivePlayerView(stream: stream)
        }
    }
}

// MARK: - 帖子列表

struct PostsFeed: View {
    @EnvironmentObject var app: AppState
    @State private var visibleCount = 7

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(app.posts.prefix(visibleCount)) { post in
                    PostCard(post: post)
                }

                if visibleCount < app.posts.count {
                    ProgressView()
                        .padding(.vertical, 12)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                visibleCount = min(visibleCount + 5, app.posts.count)
                            }
                        }
                } else {
                    Text("No more posts")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.bottom, 24)
        }
        .refreshable {
            visibleCount = 7
        }
    }
}

// MARK: - 直播卡片

struct LiveFeaturedCard: View {
    let stream: LiveStream
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AssetImage(name: stream.coverName, fallbackSystemImage: "sportscourt")
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(colors: [.clear, Color.black.opacity(0.75)], startPoint: .center, endPoint: .bottom)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        liveBadge
                        Spacer()
                        Label("\(stream.viewerCount)", systemImage: "eye.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    Text(stream.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    HStack(spacing: 6) {
                        AvatarView(name: stream.coachAvatar, size: 20)
                        Text(stream.coachName)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(14)
            }
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var liveBadge: some View {
        HStack(spacing: 4) {
            Circle().fill(Color.white).frame(width: 6, height: 6)
            Text("LIVE").font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red)
        .cornerRadius(6)
    }
}

struct LiveCard: View {
    let stream: LiveStream
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    AssetImage(name: stream.coverName, fallbackSystemImage: "sportscourt")
                        .aspectRatio(16 / 9, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    HStack(spacing: 4) {
                        Circle().fill(Color.white).frame(width: 5, height: 5)
                        Text("LIVE").font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(5)
                    .padding(8)

                    Label("\(stream.viewerCount)", systemImage: "eye.fill")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.55))
                        .cornerRadius(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(8)
                }
                .cornerRadius(Theme.cornerRadiusSmall)

                Text(stream.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.dark)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 5) {
                    AvatarView(name: stream.coachAvatar, size: 18)
                    Text(stream.coachName)
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
