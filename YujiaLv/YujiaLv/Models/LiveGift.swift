//
//  LiveGift.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import Foundation

/// 直播礼物（内购商品）。
///
/// `id` 与 App Store Connect 里的内购商品 ID **逐字对齐**，全部为**消耗型**商品：
/// 每赠送一次就扣一次费，因此不存在「已购买 / 永久拥有」的状态。
/// 商品由 `GiftStore`（StoreKit 2）按 `LiveGift.all.map(\.id)` 拉取。
struct LiveGift: Identifiable, Hashable {
    let id: String
    let emoji: String
    let name: String

    /// 占位价（美元）。
    ///
    /// **不是实际售价**——真实售价一律取 StoreKit 的 `Product.displayPrice`
    /// （已按用户所在地区本地化）。这里只在商品拉取失败、拿不到 `Product` 时
    /// 用于把价格文案填上，别拿它做任何金额计算。
    let price: Double

    /// 占位价文案，同上，仅用于商品未加载时兜底。见 `GiftStore.displayPrice(for:)`。
    var priceText: String { String(format: "$%.2f", price) }

    /// 礼物面板中的全部礼物（按价格从低到高）
    static let all: [LiveGift] = [
        LiveGift(id: "kenis.gift.rose", emoji: "🌹", name: "Rose", price: 0.99),
        LiveGift(id: "kenis.gift.star", emoji: "⭐️", name: "Star", price: 2.99),
        LiveGift(id: "kenis.gift.ace", emoji: "🎾", name: "Ace", price: 6.99),
        LiveGift(id: "kenis.gift.diamond", emoji: "💎", name: "Diamond", price: 12.99),
        LiveGift(id: "kenis.gift.rocket", emoji: "🚀", name: "Rocket", price: 14.99),
        LiveGift(id: "kenis.gift.fire", emoji: "🔥", name: "Fire", price: 19.99),
        LiveGift(id: "kenis.gift.trophy", emoji: "🏆", name: "Trophy", price: 29.99)
    ]

    /// 按商品 ID 找礼物（补发交易时用）
    static func gift(withId id: String) -> LiveGift? {
        all.first { $0.id == id }
    }
}
