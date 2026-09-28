//
//  Models.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import Foundation

// MARK: - 用户

struct User: Identifiable, Codable, Hashable {
    let id: String
    var username: String
    var nickname: String
    var bio: String
    var avatarName: String
    var isCoach: Bool

    static let guest = User(
        id: "guest",
        username: "guest",
        nickname: "Guest",
        bio: "",
        avatarName: "",
        isCoach: false
    )
}

// MARK: - 教练

struct Coach: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var title: String
    var specialty: [String]
    var avatarName: String
    var bio: String
    var isOnline: Bool
    var rating: Double
    var hourlyRate: String
    /// 预约请求是否已被教练通过（通过后「预约」变「视频通话」）
    var isApproved: Bool
}

// MARK: - 直播

struct LiveStream: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    /// 主播对应的教练 ID：关注关系按此记录，「我的关注」据此匹配教练
    var coachId: String
    var coachName: String
    var coachAvatar: String
    var coverName: String
    var videoName: String
    var viewerCount: Int
    var tags: [String]
    var isLive: Bool
    var duration: String
}

// MARK: - 帖子

struct Post: Identifiable, Codable, Hashable {
    let id: String
    var authorId: String
    var authorName: String
    var authorAvatar: String
    var content: String
    var mediaNames: [String]
    var mediaIsVideo: [Bool]
    var likeCount: Int
    var isLiked: Bool
    var timestamp: Date
    var comments: [Comment]
}

extension Post {
    /// 帖子作者对应的用户，用于跳转其个人主页。
    var author: User {
        User(
            id: authorId,
            username: authorName,
            nickname: authorName,
            bio: "Tennis enthusiast",
            avatarName: authorAvatar,
            isCoach: false
        )
    }
}

// MARK: - 评论

struct Comment: Identifiable, Codable, Hashable {
    let id: String
    var authorId: String
    var authorName: String
    var authorAvatar: String
    var content: String
    var timestamp: Date
}

extension Comment {
    /// 评论作者对应的用户，用于跳转其个人主页。
    var author: User {
        User(
            id: authorId,
            username: authorName,
            nickname: authorName,
            bio: "Tennis enthusiast",
            avatarName: authorAvatar,
            isCoach: false
        )
    }
}

// MARK: - 网球场馆

struct Court: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var location: String
    var openHours: String
    var imageName: String
    var price: String
    var rating: Double
    var surface: String
}

// MARK: - 预约

struct Reservation: Identifiable, Codable, Hashable {
    let id: String
    var courtId: String
    var courtName: String
    var dateText: String
    var timeSlot: String
    var qrCodeText: String
    /// 真实开始时间。必须是可选类型：老数据里没有这个字段，
    /// 非可选字段会让整段 JSON 解码失败、静默丢掉全部预约记录。
    var startAt: Date? = nil
}

extension Reservation {

    /// 预约状态：时段未结束为「已预约」，已过为「已结束」。
    enum Status {
        case upcoming
        case ended
    }

    /// 时段长度（分钟）。从 "09:00 - 10:00" 推导，解析不出来按 60 分钟兜底。
    var durationMinutes: Int {
        let parts = timeSlot.components(separatedBy: " - ")
        guard parts.count == 2,
              let start = Self.minutesOfDay(parts[0]),
              let end = Self.minutesOfDay(parts[1]),
              end > start else { return 60 }
        return end - start
    }

    var status: Status {
        // 没有 startAt 的老数据无法判定，一律视为未结束
        guard let startAt else { return .upcoming }
        return Date() < startAt.addingTimeInterval(TimeInterval(durationMinutes * 60)) ? .upcoming : .ended
    }

    /// 记录页与票根统一显示的日期；老数据回落到 `dateText`。
    var displayDateText: String {
        guard let startAt else { return dateText }
        return DateText.day(startAt)
    }

    /// "09:00" -> 540
    private static func minutesOfDay(_ hhmm: String) -> Int? {
        let comps = hhmm.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
        guard comps.count == 2, let hour = Int(comps[0]), let minute = Int(comps[1]) else { return nil }
        return hour * 60 + minute
    }
}

// MARK: - 日期文案

/// 记录类页面的日期 / 时长文案。
///
/// 注意不要用 `Date.relativeTime()`（PostCard.swift）：它按「过去多久」写，
/// 对未来的时间会返回 "Just now"，不能用来显示预约开始时间。
enum DateText {

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let dayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()

    /// Today / Tomorrow / Yesterday / "Sep 20"
    static func day(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return dayFormatter.string(from: date)
    }

    /// "Sep 20, 6:00 PM"
    static func dayAndTime(_ date: Date) -> String {
        dayTimeFormatter.string(from: date)
    }

    /// 通话时长："45 min" / "1 h 5 min"
    static func duration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds.rounded()) / 60
        guard totalMinutes >= 1 else { return "Less than 1 min" }
        guard totalMinutes >= 60 else { return "\(totalMinutes) min" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes == 0 ? "\(hours) h" : "\(hours) h \(minutes) min"
    }
}

// MARK: - 举报原因

struct ReportReason: Identifiable, Hashable {
    let id: String
    let title: String

    static let all: [ReportReason] = [
        ReportReason(id: "illegal", title: "Illegal Content"),
        ReportReason(id: "inappropriate", title: "Inappropriate Content"),
        ReportReason(id: "block", title: "Block User"),
        ReportReason(id: "other", title: "Other")
    ]
}
