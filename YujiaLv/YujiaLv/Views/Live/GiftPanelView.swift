//
//  GiftPanelView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI

/// 直播礼物面板：底部弹出的礼物网格 + 选中详情卡 + 购买主按钮。
///
/// 布局为 4 列网格（emoji + 名称 + 价格），选中项高亮为品牌色。
///
/// 礼物是**消耗型内购**：每送一次都要付一次费，所以没有「已购买 / 永久拥有」状态，
/// 价格一律取 StoreKit 的本地化价格。
///
/// **送礼不由本视图触发**：购买成功后礼物会进入 `GiftStore.unfulfilledGiftIds`，
/// 由 `LivePlayerView` 取走并上公屏。原因是 `Transaction.updates` 对我们自己发起的
/// 购买同样会回调，若这里再直接送一次，一次付款就会送出两份礼物。
///
/// 说明：这里没有用 `sheet`，因为 iOS 15 的 `sheet` 只有全屏样式，
/// 做不出设计稿里的底部卡片效果；面板由 `LivePlayerView` 以自定义弹层方式呈现。
struct GiftPanelView: View {
    /// 关闭面板
    let onClose: () -> Void

    @EnvironmentObject var app: AppState
    @EnvironmentObject var giftStore: GiftStore

    @State private var selected: LiveGift = LiveGift.all[0]
    /// 正在走内购确认的礼物（非空时展示内购弹窗）
    @State private var purchaseTarget: LiveGift?
    @State private var isPurchasing = false
    /// 购买失败的原因，直接展示在弹窗里。
    ///
    /// 不用 `ToastView`：本面板挂在直播页上，而直播页是 `fullScreenCover` 弹出的，
    /// 会盖住 `ContentView` 上那层全局 Toast，在那里弹提示是看不见的。
    @State private var purchaseError: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ZStack {
            // 面板本体：底部对齐的圆角卡片
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                panel
            }

            // 内购确认弹窗：盖在面板之上
            if let gift = purchaseTarget {
                purchaseConfirm(gift)
            }
        }
        // 进面板就拉一次商品：上次失败的话这次能恢复
        .task { await giftStore.loadProducts() }
    }

    // MARK: - 面板

    private var panel: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            header
            grid
            selectedSummary
            actionButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 26)
        .background(
            // 背景自己带圆角后再延伸到底部安全区：顶部保持圆角，底部铺满屏幕
            Color(hex: 0x1A1A1D)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private var header: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(hex: 0xFFB35C), Color(hex: 0xFF7A45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "gift.fill")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Send a Gift")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Text("Show your appreciation")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(LiveGift.all) { gift in
                GiftCell(
                    gift: gift,
                    priceText: giftStore.displayPrice(for: gift),
                    isSelected: gift.id == selected.id
                )
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.18)) { selected = gift }
                }
            }
        }
    }

    private var selectedSummary: some View {
        HStack(spacing: 14) {
            Text(selected.emoji)
                .font(.system(size: 28))
                .frame(width: 54, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(selected.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(giftStore.displayPrice(for: selected))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var actionButton: some View {
        Button(action: handlePrimaryAction) {
            HStack(spacing: 9) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Send · \(giftStore.displayPrice(for: selected))")
                    .font(.headline)
            }
            .foregroundColor(Theme.dark)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 27, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Theme.accent, Color(hex: 0xA8D62A)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
            .shadow(color: Theme.accent.opacity(0.35), radius: 14, y: 6)
        }
    }

    private func handlePrimaryAction() {
        purchaseError = nil
        withAnimation(.easeOut(duration: 0.2)) { purchaseTarget = selected }
    }

    // MARK: - 内购确认

    /// 购买确认弹窗（App Store 风格）。点确认后走真实内购，
    /// 系统会再弹一次 StoreKit 的购买确认框。
    private func purchaseConfirm(_ gift: LiveGift) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { if !isPurchasing { dismissPurchase() } }

            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "applelogo")
                        Text("App Store")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))

                    Text("Confirm Purchase")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                }

                HStack(spacing: 12) {
                    Text(gift.emoji)
                        .font(.system(size: 30))
                        .frame(width: 52, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(gift.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        Text(giftStore.displayPrice(for: gift))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.65))
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )

                Text("Account: \(accountLabel)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))

                if let purchaseError {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13))
                        Text(purchaseError)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundColor(Theme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.danger.opacity(0.12))
                    )
                }

                if isPurchasing {
                    HStack(spacing: 10) {
                        ProgressView().tint(Theme.accent)
                        Text("Processing…")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                } else {
                    VStack(spacing: 10) {
                        Button(action: { performPurchase(gift) }) {
                            Text("Purchase")
                                .font(.headline)
                                .foregroundColor(Theme.dark)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(Theme.accent)
                                )
                        }

                        Button(action: dismissPurchase) {
                            Text("Cancel")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: 0x1F1F22))
            )
            .shadow(color: .black.opacity(0.45), radius: 26, y: 10)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }

    private var accountLabel: String {
        app.isLoggedIn ? app.currentUser.username : "guest"
    }

    /// 走真实内购。付款成功才关面板；礼物由 `LivePlayerView` 从待送队列里取走并上公屏。
    private func performPurchase(_ gift: LiveGift) {
        isPurchasing = true
        purchaseError = nil

        Task { @MainActor in
            let outcome = await giftStore.purchase(gift)
            isPurchasing = false

            switch outcome {
            case .success:
                dismissPurchase()
                onClose()
            case .cancelled:
                // 留在弹窗里，用户可以直接重试
                break
            case .pending:
                // 需批准 / 银行验证，交易稍后完成，届时由待送队列补发
                dismissPurchase()
                onClose()
            case .unavailable(let message):
                purchaseError = message
            }
        }
    }

    private func dismissPurchase() {
        withAnimation(.easeIn(duration: 0.18)) { purchaseTarget = nil }
    }
}

// MARK: - 礼物格子

/// 单个礼物：emoji + 名称 + 价格；选中时整格高亮为品牌色。
private struct GiftCell: View {
    let gift: LiveGift
    let priceText: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(gift.emoji)
                .font(.system(size: 32))
            Text(gift.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(priceText)
                .font(.caption2)
                .foregroundColor(isSelected ? Theme.dark.opacity(0.65) : .white.opacity(0.6))
        }
        .foregroundColor(isSelected ? Theme.dark : .white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isSelected
                            ? [Theme.accent, Color(hex: 0xA8D62A)]
                            : [Color.white.opacity(0.06), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: isSelected ? Theme.accent.opacity(0.35) : .clear, radius: 10, y: 4)
    }
}
