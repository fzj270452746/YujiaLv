//
//  LivePlayerView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import AVFoundation
import Combine

/// 直播播放页：循环播放本地视频，记忆播放位置，支持关注/点赞/礼物/弹幕。
///
/// 直播视频为横版 16:9，竖屏下按原始比例完整呈现（画面居中、上下留黑），
/// 不做裁切放大，保证手机竖屏也能看到完整画面。
struct LivePlayerView: View {
    let stream: LiveStream
    @EnvironmentObject var app: AppState
    @EnvironmentObject var giftStore: GiftStore
    @Environment(\.presentationMode) var presentationMode

    /// 直播视频的宽高比（素材统一为横版 16:9）
    private let videoAspect: CGFloat = 16.0 / 9.0

    /// 公屏同时展示的条数（超出的从顶部滚出）
    private let visibleDanmakuCount = 4
    /// 公屏保留的消息上限：只比展示条数多留一点余量，
    /// 够做进出场动画即可，避免直播开久了数组无限增长。
    private let danmakuCapacity = 12

    @State private var currentTime: Double = 0
    @State private var showLogin = false
    @State private var isLiked = false
    @State private var danmakuText = ""
    /// 公屏消息：普通弹幕 + 礼物消息，自己发的会高亮
    @State private var danmakuFeed: [DanmakuItem] = []
    @State private var showGifts = false
    /// 礼物面板滑入动画结束前不接受点击，
    /// 否则「点礼物 → 抬手」这一下会误触到面板底部的购买/赠送按钮。
    @State private var giftPanelReady = false
    /// 刚送出的礼物：屏幕中央的飘屏反馈
    @State private var flyingGift: LiveGift?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // 视频区：固定 16:9，竖屏下完整显示横屏画面
            videoStage

            // 底部暗色渐变：让公屏与操作栏从画面里“浮”出来
            bottomScrim

            // 操作层：顶部主播信息 + 左下角公屏 + 底部互动栏
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 12)
                danmakuBoard
                bottomBar
                    .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // 礼物飘屏反馈
            if let gift = flyingGift {
                flyingGiftView(gift)
            }

            // 礼物面板：自定义底部弹层
            if showGifts {
                ZStack {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { dismissGifts() }

                    GiftPanelView(onClose: { dismissGifts() })
                        .transition(.move(edge: .bottom))
                }
                .allowsHitTesting(giftPanelReady)
            }
        }
        .statusBar(hidden: true)
        .onAppear { deliverUnfulfilledGifts() }
        .onReceive(giftStore.$unfulfilledGiftIds) { _ in deliverUnfulfilledGifts() }
        .onDisappear {
            app.savePlayback(currentTime, for: stream.id)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .task { await runDanmakuStream() }
    }

    // MARK: - 视频区

    /// 16:9 视频画面：封面兜底 + 循环播放的视频。
    ///
    /// 封面与播放器都放在 `overlay` 里——`overlay` 不会把自己的尺寸回报给父视图，
    /// 因此 `scaledToFill` 撑大的尺寸不会外泄、把整页布局撑宽；
    /// 画面溢出部分由 `.clipped()` 裁掉。
    private var videoStage: some View {
        Color.black
            .aspectRatio(videoAspect, contentMode: .fit)
            .overlay(
                ZStack {
                    // 封面兜底：视频加载不到时显示封面，避免黑屏
                    AssetImage(name: stream.coverName, fallbackSystemImage: "sportscourt")
                        .scaledToFill()

                    LoopingVideoPlayer(
                        videoName: stream.videoName,
                        startAt: app.playback(for: stream.id),
                        onTimeChange: { currentTime = $0 }
                    )
                }
            )
            .clipped()
    }

    /// 底部渐变遮罩：画面与操作栏之间加一层过渡，控件在亮画面上也看得清。
    private var bottomScrim: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.5), .black.opacity(0.88)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 260)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - 顶部栏

    private var topBar: some View {
        HStack(spacing: 12) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
            }

            AvatarView(name: stream.coachAvatar, size: 40)
                .overlay(alignment: .bottomTrailing) {
                    Circle().fill(Theme.online).frame(width: 11, height: 11)
                        .overlay(Circle().stroke(Color.black, lineWidth: 1.5))
                }

            VStack(alignment: .leading, spacing: 1) {
                Text(stream.coachName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text("\(stream.viewerCount) watching")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Button(action: { requireLogin { toggleFollow() } }) {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(isFollowing ? .white : Theme.dark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(isFollowing ? Color.gray : Theme.accent)
                    .cornerRadius(16)
            }
        }
    }

    // MARK: - 公屏（左下角实时弹幕）

    /// 左下角公屏：只展示最近几条，新消息立即出现在底部并把最旧的顶出去。
    private var danmakuBoard: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(danmakuFeed.suffix(visibleDanmakuCount))) { item in
                danmakuRow(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: danmakuFeed)
    }

    private func danmakuRow(_ item: DanmakuItem) -> some View {
        (
            Text(item.author)
                .font(.footnote.weight(.semibold))
                .foregroundColor(item.isMine ? Theme.accent : item.authorColor)
            + Text(" " + item.text)
                .font(.footnote)
                .foregroundColor(.white)
        )
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: 260, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(item.isGift ? 0.62 : 0.38))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    item.isGift ? Theme.accent.opacity(0.85) : Color.white.opacity(0.12),
                    lineWidth: 1
                )
        )
    }

    /// 公屏持续滚动：先铺开进房时已经在聊的弹幕，之后随机加入新弹幕，
    /// 保证长时间停留在页面上也有“正在直播”的现场感。
    private func runDanmakuStream() async {
        for item in DanmakuItem.openingDanmaku {
            guard !Task.isCancelled else { return }
            appendDanmaku(item)
            try? await Task.sleep(nanoseconds: 520_000_000)
        }

        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 3.0...6.0) * 1_000_000_000))
            guard !Task.isCancelled else { return }
            appendDanmaku(DanmakuItem.randomAudienceDanmaku())
        }
    }

    private func appendDanmaku(_ item: DanmakuItem) {
        danmakuFeed.append(item)
        if danmakuFeed.count > danmakuCapacity {
            danmakuFeed.removeFirst(danmakuFeed.count - danmakuCapacity)
        }
    }

    // MARK: - 底部栏

    private var bottomBar: some View {
        HStack(spacing: 10) {
            // 输入框：亮底 + 描边 + 圆形发送键，保证在深色直播画面上足够醒目
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.accent)

                ZStack(alignment: .leading) {
                    if danmakuText.isEmpty {
                        Text("Say something…")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.65))
                    }
                    TextField("", text: $danmakuText)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .accentColor(Theme.accent)
                        .submitLabel(.send)
                        .onSubmit { requireLogin { sendDanmaku() } }
                }

                Button(action: { requireLogin { sendDanmaku() } }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.dark)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Theme.accent))
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 6)
            .frame(height: 44)
            .background(
                Capsule().fill(Color.white.opacity(0.16))
            )
            .overlay(
                Capsule().strokeBorder(Color.white.opacity(0.55), lineWidth: 1.2)
            )

            Button(action: { requireLogin { toggleLike() } }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(isLiked ? Theme.danger : .white)
                    .frame(width: 36, height: 36)
            }

            // 送礼**不要求登录**：礼物是纯内购，走 StoreKit 付款即可，
            // 与账号体系无关。未登录时以 "You"（见 `senderName`）上公屏。
            Button(action: { presentGifts() }) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
        }
    }

    // MARK: - 礼物飘屏

    private func flyingGiftView(_ gift: LiveGift) -> some View {
        VStack(spacing: 10) {
            Text(gift.emoji)
                .font(.system(size: 76))
            Text("\(senderName) sent \(gift.name)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.dark)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(Capsule().fill(Theme.accent))
        }
        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
        .transition(.scale(scale: 0.6).combined(with: .opacity))
        .allowsHitTesting(false)
    }

    // MARK: - 行为

    /// 公屏上显示的自己的昵称
    private var senderName: String {
        app.isLoggedIn ? app.currentUser.nickname : "You"
    }

    private func requireLogin(_ action: () -> Void) {
        if app.isLoggedIn { action() } else { showLogin = true }
    }

    /// 是否已关注该主播。关注关系存在 AppState 并落盘，
    /// 因此退出直播再进来、甚至在「我的关注」里取关都会保持一致。
    private var isFollowing: Bool { app.isFollowing(stream.coachId) }

    private func toggleFollow() {
        app.toggleFollow(stream.coachId)
        let followed = app.isFollowing(stream.coachId)
        appendDanmaku(DanmakuItem(
            author: "System",
            text: followed ? "You followed \(stream.coachName)" : "You unfollowed \(stream.coachName)",
            isMine: true
        ))
    }

    private func toggleLike() {
        isLiked.toggle()
    }

    private func sendDanmaku() {
        let text = danmakuText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        danmakuText = ""
        appendDanmaku(DanmakuItem(author: senderName, text: text, isMine: true))
    }

    /// 送出礼物：上公屏 + 屏幕中央飘屏反馈
    private func sendGift(_ gift: LiveGift) {
        appendDanmaku(DanmakuItem(
            author: senderName,
            text: "sent \(gift.emoji) \(gift.name)",
            isMine: true,
            isGift: true
        ))

        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            flyingGift = gift
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            guard flyingGift?.id == gift.id else { return }
            withAnimation(.easeOut(duration: 0.3)) { flyingGift = nil }
        }
    }

    /// 把已付款的礼物送上公屏。
    ///
    /// 礼物统一由 `GiftStore` 的待送队列驱动（购买成功、以及挂起交易稍后完成，都汇入这里），
    /// 直播页是它的唯一消费方。`onAppear` 也要调一次：交易可能在用户没看直播时就完成了，
    /// 那时队列只积累不触发变更回调。
    private func deliverUnfulfilledGifts() {
        for id in giftStore.consumeUnfulfilledGiftIds() {
            guard let gift = LiveGift.gift(withId: id) else { continue }
            sendGift(gift)
        }
    }

    private func presentGifts() {
        giftPanelReady = false
        withAnimation(.easeOut(duration: 0.28)) { showGifts = true }
        // 等滑入动画走完再开放点击
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            giftPanelReady = true
        }
    }

    private func dismissGifts() {
        giftPanelReady = false
        withAnimation(.easeIn(duration: 0.2)) { showGifts = false }
    }
}

// MARK: - 公屏消息

/// 直播公屏上的一条消息：观众弹幕 / 礼物消息 / 系统提示。
struct DanmakuItem: Identifiable, Equatable {
    let id = UUID()
    let author: String
    let text: String
    /// 自己发送的消息：昵称高亮为品牌色
    var isMine: Bool = false
    /// 礼物消息：整条用品牌色描边突出
    var isGift: Bool = false
    /// 观众昵称配色
    var authorColor: Color = Color(hex: 0x8FC7FF)
}

extension DanmakuItem {
    /// 观众昵称配色板
    static let palette: [Color] = [
        Color(hex: 0x8FC7FF), Color(hex: 0xFFB4A2), Color(hex: 0xB8E986),
        Color(hex: 0xFFD166), Color(hex: 0xD5A6FF), Color(hex: 0x7FE3D4)
    ]

    /// 进房时公屏上已经在滚动的弹幕
    static let openingDanmaku: [DanmakuItem] = [
        DanmakuItem(author: "Alex Morgan", text: "that grip adjustment is a game changer", authorColor: palette[0]),
        DanmakuItem(author: "Jordan Lee", text: "watching this before my match 🔥", authorColor: palette[1]),
        DanmakuItem(author: "Taylor Reed", text: "can you show the slow motion again?", authorColor: palette[2]),
        DanmakuItem(author: "Casey Wong", text: "the footwork detail here is gold", authorColor: palette[3])
    ]

    private static let audienceNames = [
        "Riley Park", "Sam Rivera", "Jamie Fox", "Morgan Chen",
        "Drew Ellis", "Ava Novak", "Chris Bauer", "Nina Alvarez"
    ]

    private static let audienceLines = [
        "this drill is exactly what I needed 🔥",
        "greetings from Berlin 👋",
        "my backhand finally clicked, thank you!",
        "coach makes it look so easy 😅",
        "been waiting for this session all week",
        "can you cover the toss next?",
        "the slow-mo replay really helps",
        "trying this at practice tomorrow 🎾"
    ]

    /// 随机生成一条观众弹幕
    static func randomAudienceDanmaku() -> DanmakuItem {
        let name = audienceNames.randomElement() ?? "Guest"
        return DanmakuItem(
            author: name,
            text: audienceLines.randomElement() ?? "",
            authorColor: palette[abs(name.hashValue % palette.count)]
        )
    }
}

// MARK: - 循环视频播放器

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String
    var startAt: Double = 0
    var onTimeChange: (Double) -> Void = { _ in }

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        if let url = VideoResolver.url(for: videoName) {
            view.configure(url: url, startAt: startAt, onTimeChange: onTimeChange)
        }
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}
}

final class PlayerContainerView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var endObserver: NSObjectProtocol?
    private var timeObserver: Any?

    /// 交给 SwiftUI 的尺寸：直接采用父视图给出的建议尺寸，
    /// 避免空视图回报异常尺寸把外层布局撑坏。
    override func sizeThatFits(_ size: CGSize) -> CGSize { size }

    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        if let endObserver = endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    func configure(url: URL, startAt: Double, onTimeChange: @escaping (Double) -> Void) {
        let player = AVPlayer(url: url)
        let layer = AVPlayerLayer(player: player)
        // 横屏视频在 16:9 容器内按原始比例完整显示，不裁切
        layer.videoGravity = .resizeAspect
        self.layer.addSublayer(layer)
        self.playerLayer = layer
        self.player = player

        if startAt > 0 {
            player.seek(to: CMTime(seconds: startAt, preferredTimescale: 600),
                        toleranceBefore: .zero, toleranceAfter: .zero)
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { time in
            onTimeChange(time.seconds)
        }

        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
