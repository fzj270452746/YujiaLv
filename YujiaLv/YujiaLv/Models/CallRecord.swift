//
//  CallRecord.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import Foundation

/// 一次视频通话记录。
///
/// 教练姓名与头像在这里冗余存一份（而不是只存 coachId 现查）：
/// 记录是「当时是谁」的历史快照，教练之后改了头像也不该影响历史。
struct CallRecord: Identifiable, Codable, Hashable {

    /// 通话结果。
    enum Outcome: String, Codable {
        /// 接通并正常结束
        case completed
        /// 对方未接
        case declined
        /// 接通前自己挂断
        case cancelled
    }

    let id: String
    var coachId: String
    var coachName: String
    var coachAvatar: String
    var startedAt: Date
    /// 通话秒数；未接通为 0。
    var duration: TimeInterval
    var outcome: Outcome
}
