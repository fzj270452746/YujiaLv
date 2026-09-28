//
//  AssetViews.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import AVKit
import UIKit

/// 资源图片：优先加载 Assets 中的同名图片，缺失时显示渐变与系统图标。
struct AssetImage: View {
    let name: String
    var fallbackSystemImage: String = "photo"
    /// 填充方式：卡片/列表用 `fill` 铺满并裁切；全屏查看用 `fit`，否则会被放大裁切只能看到局部。
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    Theme.fallbackGradient
                    Image(systemName: fallbackSystemImage)
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(Theme.secondaryText.opacity(0.6))
                }
            }
        }
    }
}

/// 圆形头像：优先加载用户自设头像与内置资源，均缺失时显示 person 图标（未设置头像的初始状态）。
struct AvatarView: View {
    let name: String
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let uiImage = AvatarStore.image(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Theme.fallbackGradient
                    Image(systemName: "person.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundColor(Theme.primary.opacity(0.7))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

/// 视频资源解析：优先从 Bundle 资源加载，其次从 Assets.xcassets 数据集加载。
enum VideoResolver {
    private static var cache: [String: URL] = [:]

    static func url(for name: String) -> URL? {
        guard !name.isEmpty else { return nil }
        if let cached = cache[name] { return cached }

        // 1. 直接加入工程（Target 资源）的 mp4 / mov
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4") {
            cache[name] = url
            return url
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "mov") {
            cache[name] = url
            return url
        }

        // 2. 拖入 Assets.xcassets 的数据集 → 写入临时文件后播放
        if let asset = NSDataAsset(name: name) {
            let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent("kenis_" + name)
                .appendingPathExtension("mp4")
            do {
                try asset.data.write(to: tmp, options: .atomic)
                cache[name] = tmp
                return tmp
            } catch {
                // 写入失败则按无视频处理
            }
        }

        return nil
    }
}

/// 资源视频：优先播放本地同名视频，缺失时显示提示。
struct AssetVideo: View {
    let name: String

    var body: some View {
        Group {
            if let url = VideoResolver.url(for: name) {
                VideoPlayer(player: AVPlayer(url: url))
            } else {
                ZStack {
                    Theme.fallbackGradient
                    VStack(spacing: 8) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Theme.secondaryText.opacity(0.6))
                        Text("Video unavailable")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                    }
                }
            }
        }
    }
}

/// 空状态视图。
struct EmptyStateView: View {
    let icon: String
    let message: String

    init(icon: String = "tray", message: String) {
        self.icon = icon
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(Theme.secondaryText.opacity(0.5))
            Text(message)
                .font(.subheadline)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
