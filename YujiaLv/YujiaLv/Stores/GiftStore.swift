//
//  GiftStore.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import Foundation
import Combine
import StoreKit

/// 直播礼物的内购管理器（StoreKit 2）。
///
/// 礼物是**消耗型商品**：每赠送一次扣一次费，因此这里**不维护任何「已购买」状态**，
/// 也不提供恢复购买（消耗型商品在 StoreKit 里本就不可恢复）。
///
/// 购买成功后礼物**不由 `purchase(_:)` 直接送出**，而是统一投递到
/// `unfulfilledGiftIds` 队列，由直播页消费后上公屏。这样做的原因见 `deliver(_:)`。
final class GiftStore: ObservableObject {

    static let shared = GiftStore()

    /// 一次购买尝试的结果
    enum PurchaseOutcome {
        /// 已付款并完成交易
        case success
        /// 用户主动取消
        case cancelled
        /// 交易挂起（如「家人共享」的购买需批准、银行验证），稍后才会完成
        case pending
        /// 无法购买，附带可直接展示给用户的错误文案
        case unavailable(String)
    }

    /// 已加载的商品（productID -> Product）。未加载到商品时为空。
    @Published private(set) var products: [String: Product] = [:]

    /// 商品拉取失败 / 拉不到任何商品。为 true 时不允许走购买流程。
    @Published private(set) var loadFailed = false

    /// 已付款但还没送出公屏的礼物（productID）。
    ///
    /// 正常购买和「挂起后由系统补完成」的交易都汇入这里，
    /// 由 `LivePlayerView` 取走并上公屏。
    @Published private(set) var unfulfilledGiftIds: [String] = []

    private var updatesTask: Task<Void, Never>?
    private var isLoading = false

    /// 已投递过的交易 ID。
    ///
    /// `Transaction.updates` **对我们自己发起的购买同样会回调**，若两条路径都投递，
    /// 一次付款就会送出两份礼物。这里按交易 ID 去重：谁先到谁投递，后到的那条是空操作。
    private var deliveredTransactionIds: Set<UInt64> = []

    private init() {
        // 常驻监听：交易可能在购买调用返回之后才完成（挂起转批准、中断后恢复等），
        // 不接住的话用户付了钱却收不到礼物。
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.deliver(result)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - 商品加载

    /// 拉取礼物对应的商品信息。失败不影响 App 其余功能，只让购买入口报错。
    @MainActor
    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await Product.products(for: LiveGift.all.map(\.id))
            guard !fetched.isEmpty else {
                // 商品 ID 在 App Store Connect 里还不存在时，StoreKit 返回空数组而不是抛错
                loadFailed = true
                return
            }
            products = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
            loadFailed = false
        } catch {
            // 保留上一次成功加载的商品，避免网络抖动把已经能用的购买入口打掉
            loadFailed = products.isEmpty
        }
    }

    /// 展示用价格：优先取 StoreKit 的本地化价格，拿不到才退回 `LiveGift` 里的占位价。
    @MainActor
    func displayPrice(for gift: LiveGift) -> String {
        products[gift.id]?.displayPrice ?? gift.priceText
    }

    // MARK: - 购买

    @MainActor
    func purchase(_ gift: LiveGift) async -> PurchaseOutcome {
        guard AppStore.canMakePayments else {
            return .unavailable("Purchases are disabled on this device. Check Screen Time restrictions.")
        }
        guard let product = products[gift.id] else {
            return .unavailable(products.isEmpty
                ? "The gift store is unavailable right now. Please try again later."
                : "This gift isn't available right now.")
        }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // 先投递（内部按交易 ID 去重），再 finish；万一投递后崩溃，
                    // 未 finish 的交易会在下次启动时由 updates 重放，不会漏送礼。
                    await deliver(verification)
                    await transaction.finish()
                    return .success
                case .unverified(_, let error):
                    return .unavailable("Purchase couldn't be verified, and you weren't charged. (\(error.localizedDescription))")
                }
            case .userCancelled:
                return .cancelled
            case .pending:
                return .pending
            default:
                return .unavailable("The purchase couldn't be completed. Please try again.")
            }
        } catch {
            return .unavailable("The purchase couldn't be completed. (\(error.localizedDescription))")
        }
    }

    // MARK: - 投递

    /// 把一笔已验证的交易投递成「待送出的礼物」。按交易 ID 幂等。
    @MainActor
    private func deliver(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        guard transaction.productType == .consumable,
              LiveGift.gift(withId: transaction.productID) != nil,
              deliveredTransactionIds.insert(transaction.id).inserted
        else { return }

        unfulfilledGiftIds.append(transaction.productID)
    }

    /// 取走并清空待送出的礼物（由直播页消费）。
    ///
    /// 队列为空时必须**提前返回、不写属性**：`@Published` 对「赋相同值」同样会发通知，
    /// 而无条件清空会让 `LivePlayerView` 的 `onReceive` → 消费 → 再发通知 → `onReceive`
    /// 无限循环，主线程被钉死（表现为「点进直播就卡住」）。
    @MainActor
    func consumeUnfulfilledGiftIds() -> [String] {
        guard !unfulfilledGiftIds.isEmpty else { return [] }
        let ids = unfulfilledGiftIds
        unfulfilledGiftIds = []
        return ids
    }
}
