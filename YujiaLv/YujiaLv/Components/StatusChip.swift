//
//  StatusChip.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI

/// 状态标签：记录页里的「已预约 / 已结束」「Completed / Missed」等。
///
/// 底色统一用 `color.opacity(0.12)`，颜色一律取自 `Theme`，不引入新色。
struct StatusChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }
}
