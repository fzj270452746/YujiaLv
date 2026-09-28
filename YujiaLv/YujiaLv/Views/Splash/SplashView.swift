//
//  SplashView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI

/// 启动加载页：冷启动时的品牌露出，展示 1 秒后淡出交给 `MainTabView`。
///
/// 它和系统启动屏（Info.plist 里的 `UILaunchScreen`）是**接力**关系而不是独立的两屏：
/// 系统启动屏把 `LaunchLogo` 按**整屏正中**渲染，所以这里的 logo 也用 `.ignoresSafeArea()`
/// 落在整屏正中、同为 96pt，并且**不做任何入场动画**——换屏那一瞬间它必须一动不动，
/// 入场动画全部交给它周围的元素，这样才看不出接缝。
///
/// 本工程启动时没有任何真实异步可等（`AppState.init()` 全同步），所以时长是「最短展示时长」，
/// 不伪装网络请求；1 秒里只保留 3 个运动事件（光晕淡入、文案上浮、进度条推进），
/// 再多就什么都看不清了。
struct SplashView: View {

    /// 展示时长（不含退场淡出）。
    static let hold: TimeInterval = 1.0
    /// 退场淡出时长。
    static let fade: TimeInterval = 0.35

    /// logo 边长（点）。必须与 `LaunchLogo` 的自然尺寸一致，否则和系统启动屏对不齐。
    private static let logoSize: CGFloat = 96
    /// 外圈弧线直径。必须明显大于 logo 的**对角**尺寸（96×√2 ≈ 135.8），
    /// 否则弧线会贴着甚至切进图标四个角，看着像没对齐。留 12pt 余量。
    private static let ringSize: CGFloat = 160
    /// logo 下沿到标题上沿的间距。
    private static let textGap: CGFloat = 26
    /// 文案块的固定高度。定死它才能精确算出整组的偏移量，把 logo 顶到屏幕正中。
    private static let textHeight: CGFloat = 66

    /// 淡出结束后回调；由 `ContentView` 无动画地把本视图移出层级。
    var onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var glow: Double = 0
    @State private var ring: Double = 0
    @State private var spin = false
    @State private var content: Double = 0
    @State private var lift: CGFloat = 10
    @State private var bar: Double = 0
    @State private var progress: CGFloat = 0
    @State private var visible = true

    var body: some View {
        ZStack {
            Theme.background

            // 光晕从 0 淡入：系统启动屏只能是纯色，它若在第一帧就在，切过来会闪一下。
            RadialGradient(
                colors: [Theme.primary.opacity(0.20), Theme.primary.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .opacity(glow)

            // 弧线与 logo 同心，所以它自己居中、不跟着下面整组偏移
            Circle()
                .trim(from: 0, to: 0.22)
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: Self.ringSize, height: Self.ringSize)
                .rotationEffect(.degrees(spin ? 360 : 0))
                .opacity(ring)

            // logo + 文案整组居中后再整体下移，下移量取文案那半边的半高，
            // 这样落回屏幕正中的正好是 logo —— 它必须和系统启动屏的居中 logo 重合。
            VStack(spacing: 0) {
                // 与系统启动屏用的是同一个资源，保证两边像素级一致
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.logoSize, height: Self.logoSize)

                VStack(spacing: 6) {
                    // tracking 会在末字后面也留出间距，整块会偏左半个字距，用等量左内边距补回来
                    Text("Kenis")
                        .font(.system(size: 30, weight: .heavy))
                        .tracking(6)
                        .padding(.leading, 6)
                        .foregroundColor(Theme.dark)
                    Text("Live tennis coaching & community")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
                .frame(height: Self.textHeight, alignment: .top)
                .padding(.top, Self.textGap)
                .opacity(content)
                .offset(y: lift)
            }
            .offset(y: (Self.textGap + Self.textHeight) / 2)

            VStack {
                Spacer()
                VStack(spacing: 14) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.divider).frame(width: 132, height: 4)
                        Capsule().fill(Theme.primary).frame(width: 132 * progress, height: 4)
                    }
                    Text("Warming up the court")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                .opacity(bar)
                .padding(.bottom, 96)
            }
        }
        .ignoresSafeArea()
        // 挡住底下已经挂载好的主界面，别让启动页这 1 秒里的点击漏下去
        .contentShape(Rectangle())
        .opacity(visible ? 1 : 0)
        .onAppear(perform: start)
    }

    // MARK: - 时间轴

    private func start() {
        if reduceMotion { lift = 0 }

        // iOS 15 上 onAppear 里第一个 withAnimation 有时不生效（视图还没进渲染树），先让出首帧
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.45)) { glow = 1 }
            withAnimation(.easeOut(duration: 0.30)) { ring = 1 }
            if !reduceMotion {
                withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) { spin = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation(.easeOut(duration: 0.35)) { content = 1; lift = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeOut(duration: 0.15)) { bar = 1 }
                withAnimation(.linear(duration: Self.hold - 0.25)) { progress = 1 }
            }

            // 自己先把不透明度动画到 0，再由父层无动画移除。
            // 用 `.transition(.opacity)` + 父层 withAnimation 移除，在 iOS 15 上会和
            // 状态移除抢时序、闪一帧。
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.hold) {
                withAnimation(.easeInOut(duration: Self.fade)) { visible = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.fade) { onFinish() }
            }
        }
    }
}
