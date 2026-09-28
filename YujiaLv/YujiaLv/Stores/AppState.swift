//
//  AppState.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine
import Foundation

/// 全局应用状态：登录态、用户关系、业务数据与本地持久化。
final class AppState: ObservableObject {

    static let shared = AppState()

    // MARK: - 登录态

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User = .guest

    // MARK: - 业务数据

    @Published var posts: [Post] = []
    @Published var coaches: [Coach] = []
    @Published var liveStreams: [LiveStream] = []
    @Published var courts: [Court] = []
    @Published var reservations: [Reservation] = []
    /// 视频通话记录（演示数据 + 真实通话产生的记录）
    @Published var callRecords: [CallRecord] = []

    // MARK: - 用户关系

    /// 我关注的人
    @Published var followIds: Set<String> = []
    /// 我点赞的帖子
    @Published var likedPostIds: Set<String> = []
    /// 已发起预约请求的教练
    @Published var bookedCoachIds: Set<String> = []
    /// 用户自设头像（userId -> avatarName），未设置过则没有记录
    @Published var userAvatars: [String: String] = [:]

    // MARK: - 直播播放位置

    @Published var playbackPositions: [String: Double] = [:]

    // MARK: - 注册账号表（内存 + 持久化）

    /// 内置测试账号：App 审核人员用这组账号登录即可体验完整功能。
    /// 每次启动都会覆盖回账号表，因此注册 / 注销都清不掉它，密码始终有效。
    /// 注意：这是保留用户名，普通用户注册同名账号会被拒绝。
    static let builtInAccounts: [String: String] = ["kenis": "123456"]

    /// 账号表。键统一为小写用户名，登录 / 注册都不区分大小写。
    private var accounts: [String: String] = AppState.builtInAccounts

    // MARK: - Apple 登录账号

    /// Apple 账号资料，键为 Apple 返回的用户标识。
    ///
    /// Apple **只在「首次授权」返回姓名与邮箱**，之后每次登录都是 nil，
    /// 所以第一次拿到就存下来，后续登录复用，否则昵称会莫名变回默认值。
    struct AppleProfile: Codable {
        var nickname: String = ""
        var email: String = ""
    }

    @Published var appleProfiles: [String: AppleProfile] = [:]

    // MARK: - 持久化版本

    /// 持久化数据结构版本。改动教练 / 预约 / 通话记录的初始状态时递增，
    /// 旧数据会被丢弃并按当前 `SeedData` 重建一次。
    private static let dataVersion = 3

    // MARK: - UserDefaults 键

    private enum Key {
        static let dataVersion = "kenis.dataVersion"
        static let loggedIn = "kenis.loggedIn"
        static let currentUser = "kenis.currentUser"
        static let accounts = "kenis.accounts"
        static let appleProfiles = "kenis.appleProfiles"
        static let posts = "kenis.posts"
        static let coaches = "kenis.coaches"
        static let reservations = "kenis.reservations"
        static let callRecords = "kenis.callRecords"
        static let followIds = "kenis.followIds"
        static let likedPostIds = "kenis.likedPostIds"
        static let bookedCoaches = "kenis.bookedCoaches"
        static let userAvatars = "kenis.userAvatars"
        static let playback = "kenis.playback"
    }

    private let defaults = UserDefaults.standard

    /// 本次启动是否刚做过版本迁移（迁移会把演示用的种子记录注入一次）
    private var didMigrateSeedData = false

    // MARK: - 初始化

    init() {
        loadPersistedState()
        if posts.isEmpty { posts = SeedData.posts }
        if coaches.isEmpty { coaches = SeedData.coaches }
        if liveStreams.isEmpty { liveStreams = SeedData.liveStreams }
        if courts.isEmpty { courts = SeedData.courts }

        // 预约与通话记录只在版本迁移那一次注入（而不是「为空就注入」）：
        // 否则用户注销账号清空记录后，下次启动演示数据又会自己长回来。
        if didMigrateSeedData {
            reservations = SeedData.reservations
            callRecords = SeedData.callRecords
            persistAll()   // 必须落盘，否则迁移标记已写、种子数据丢失
        }
    }

    // MARK: - 持久化

    /// 教练、预约、通话记录都是持久化的（`simctl uninstall` 也清不掉），
    /// 改了种子数据后老数据会盖住新值，这里按版本作废一次并按当前 `SeedData` 重建。
    private func migrateOutdatedSeedData() {
        guard defaults.integer(forKey: Key.dataVersion) < Self.dataVersion else { return }
        defaults.removeObject(forKey: Key.coaches)
        defaults.removeObject(forKey: Key.bookedCoaches)
        // 老 Reservation 没有 startAt，留着会永远显示成「已预约」+ 陈旧的日期
        defaults.removeObject(forKey: Key.reservations)
        defaults.removeObject(forKey: Key.callRecords)
        defaults.set(Self.dataVersion, forKey: Key.dataVersion)
        didMigrateSeedData = true
    }

    private func loadPersistedState() {
        migrateOutdatedSeedData()

        isLoggedIn = defaults.bool(forKey: Key.loggedIn)
        if let data = defaults.data(forKey: Key.currentUser),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
        if let data = defaults.data(forKey: Key.accounts),
           let dict = try? JSONDecoder().decode([String: String].self, from: data) {
            accounts = dict
        }
        normalizeAccounts()
        appleProfiles = decode([String: AppleProfile].self, key: Key.appleProfiles) ?? [:]
        posts = decode([Post].self, key: Key.posts) ?? []
        normalizeCommentAuthorIds()
        coaches = decode([Coach].self, key: Key.coaches) ?? []
        reservations = decode([Reservation].self, key: Key.reservations) ?? []
        callRecords = decode([CallRecord].self, key: Key.callRecords) ?? []
        followIds = decode(Set<String>.self, key: Key.followIds) ?? []
        likedPostIds = decode(Set<String>.self, key: Key.likedPostIds) ?? []
        bookedCoachIds = decode(Set<String>.self, key: Key.bookedCoaches) ?? []
        playbackPositions = decode([String: Double].self, key: Key.playback) ?? [:]

        userAvatars = decode([String: String].self, key: Key.userAvatars) ?? [:]
        // 头像改为仅支持用户自设：清掉历史遗留的内置头像，回到「未设置」状态
        userAvatars = userAvatars.filter { !$0.value.hasPrefix("user_avatar_") }
        if currentUser.avatarName.hasPrefix("user_avatar_") {
            currentUser.avatarName = ""
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// 账号表归一化（幂等）：老数据里的用户名大小写不一，统一转小写；
    /// 再把内置测试账号合并回来，保证它永远存在且密码固定。
    private func normalizeAccounts() {
        var normalized: [String: String] = [:]
        for (name, password) in accounts {
            normalized[name.lowercased()] = password
        }
        accounts = normalized.merging(Self.builtInAccounts) { _, builtIn in builtIn }
    }

    /// 早期种子数据把评论作者 id 写成了 `u_user_xxx`，与帖子作者的 `user_xxx` 对不上，
    /// 会让「点评论头像进个人主页」看到的是另一个空白账号（帖子数为 0）。这里统一纠正（幂等）。
    private func normalizeCommentAuthorIds() {
        for postIndex in posts.indices {
            for commentIndex in posts[postIndex].comments.indices {
                let id = posts[postIndex].comments[commentIndex].authorId
                guard id.hasPrefix("u_user_") else { continue }
                posts[postIndex].comments[commentIndex].authorId = String(id.dropFirst(2))
            }
        }
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func persistAll() {
        defaults.set(isLoggedIn, forKey: Key.loggedIn)
        persist(currentUser, key: Key.currentUser)
        persist(accounts, key: Key.accounts)
        persist(appleProfiles, key: Key.appleProfiles)
        persist(posts, key: Key.posts)
        persist(coaches, key: Key.coaches)
        persist(reservations, key: Key.reservations)
        persist(callRecords, key: Key.callRecords)
        persist(followIds, key: Key.followIds)
        persist(likedPostIds, key: Key.likedPostIds)
        persist(bookedCoachIds, key: Key.bookedCoaches)
        persist(playbackPositions, key: Key.playback)
        persist(userAvatars, key: Key.userAvatars)
    }

    // MARK: - 登录 / 注册 / 退出 / 注销

    @discardableResult
    func login(username: String, password: String) -> Bool {
        let name = username.trimmingCharacters(in: .whitespaces)
        guard accounts[name.lowercased()] == password else { return false }
        let userId = "user_" + name.lowercased()
        currentUser = User(
            id: userId,
            username: name,
            nickname: name,
            bio: "Tennis lover, live coaching enthusiast.",
            avatarName: userAvatars[userId] ?? "",
            isCoach: false
        )
        isLoggedIn = true
        persistAll()
        return true
    }

    @discardableResult
    func register(username: String, password: String) -> String? {
        let name = username.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, password.count >= 6 else {
            return "Password must be at least 6 characters."
        }
        let key = name.lowercased()
        guard accounts[key] == nil else {
            return "This username is already taken."
        }
        accounts[key] = password
        persistAll()
        return nil
    }

    /// Apple 登录成功后的落地。
    ///
    /// `userIdentifier` 是 Apple 发给这个 App 的稳定用户标识（同一个 Apple ID 每次都一样），
    /// 用它当账号主键，再次登录就会回到同一个账号，而不是每次新建一个。
    /// 账号资料纯本地存储，没有服务端；因此删号也只删本地（见 `deleteAccount`）。
    @discardableResult
    func signInWithApple(
        userIdentifier: String,
        fullName: PersonNameComponents?,
        email: String?
    ) -> Bool {
        let userId = "user_apple_" + userIdentifier

        var profile = appleProfiles[userIdentifier] ?? AppleProfile()
        if let name = fullName?.formatted(), !name.isEmpty { profile.nickname = name }
        if let email, !email.isEmpty { profile.email = email }
        appleProfiles[userIdentifier] = profile

        currentUser = User(
            id: userId,
            username: profile.email.isEmpty ? "apple_user" : profile.email,
            nickname: profile.nickname.isEmpty ? "Apple User" : profile.nickname,
            bio: "Tennis lover, live coaching enthusiast.",
            avatarName: userAvatars[userId] ?? "",
            isCoach: false
        )
        isLoggedIn = true
        persistAll()
        return true
    }

    func logout() {
        isLoggedIn = false
        currentUser = .guest
        persistAll()
    }

    func deleteAccount() {
        // currentUser 下面会被重置成 guest，先把要清理的账号信息取出来
        let userId = currentUser.id
        let appleIdentifier = appleProfiles.keys.first { "user_apple_" + $0 == userId }

        AvatarStore.remove(for: userId)
        userAvatars.removeValue(forKey: userId)
        // Apple 账号资料属于该账号，一并删除，避免下次登录又把旧昵称带回来
        if let appleIdentifier { appleProfiles.removeValue(forKey: appleIdentifier) }

        isLoggedIn = false
        currentUser = .guest
        followIds.removeAll()
        likedPostIds.removeAll()
        // 只删自己的帖子（原来写死了 "user_kenis"，换任何账号都会留下孤立帖子）
        posts.removeAll { $0.authorId == userId }
        reservations.removeAll()
        callRecords.removeAll()
        persistAll()
    }

    // MARK: - 个人资料

    func updateProfile(nickname: String, bio: String, avatarName: String) {
        currentUser.nickname = nickname.trimmingCharacters(in: .whitespaces).isEmpty ? currentUser.nickname : nickname
        currentUser.bio = bio

        // 头像：留空表示未设置，同时清掉沙盒里的旧图
        if avatarName.isEmpty && currentUser.avatarName.hasPrefix(AvatarStore.localPrefix) {
            AvatarStore.remove(for: currentUser.id)
        }
        currentUser.avatarName = avatarName

        if avatarName.isEmpty {
            userAvatars.removeValue(forKey: currentUser.id)
        } else {
            userAvatars[currentUser.id] = avatarName
        }

        // 同步历史帖子与评论中的头像，保证个人主页与内容列表一致
        for index in posts.indices where posts[index].authorId == currentUser.id {
            posts[index].authorAvatar = avatarName
        }
        for index in posts.indices {
            for commentIndex in posts[index].comments.indices
            where posts[index].comments[commentIndex].authorId == currentUser.id {
                posts[index].comments[commentIndex].authorAvatar = avatarName
            }
        }
        persistAll()
    }

    // MARK: - 关注

    func isFollowing(_ userId: String) -> Bool { followIds.contains(userId) }

    func toggleFollow(_ userId: String) {
        if followIds.contains(userId) { followIds.remove(userId) }
        else { followIds.insert(userId) }
        persistAll()
    }

    // MARK: - 点赞

    func isLiked(_ postId: String) -> Bool { likedPostIds.contains(postId) }

    func toggleLike(_ postId: String) {
        if let idx = posts.firstIndex(where: { $0.id == postId }) {
            let wasLiked = posts[idx].isLiked
            posts[idx].isLiked.toggle()
            posts[idx].likeCount += wasLiked ? -1 : 1
        }
        if likedPostIds.contains(postId) { likedPostIds.remove(postId) }
        else { likedPostIds.insert(postId) }
        persistAll()
    }

    // MARK: - 帖子 / 评论

    func addPost(content: String, mediaNames: [String], mediaIsVideo: [Bool]) {
        let post = Post(
            id: UUID().uuidString,
            authorId: currentUser.id,
            authorName: currentUser.nickname,
            authorAvatar: currentUser.avatarName,
            content: content,
            mediaNames: mediaNames,
            mediaIsVideo: mediaIsVideo,
            likeCount: 0,
            isLiked: false,
            timestamp: Date(),
            comments: []
        )
        posts.insert(post, at: 0)
        persistAll()
    }

    func deletePost(_ postId: String) {
        posts.removeAll { $0.id == postId }
        likedPostIds.remove(postId)
        persistAll()
    }

    func addComment(to postId: String, content: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postId }) else { return }
        let comment = Comment(
            id: UUID().uuidString,
            authorId: currentUser.id,
            authorName: currentUser.nickname,
            authorAvatar: currentUser.avatarName,
            content: content,
            timestamp: Date()
        )
        posts[idx].comments.append(comment)
        persistAll()
    }

    func deleteComment(from postId: String, commentId: String) {
        guard let idx = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[idx].comments.removeAll { $0.id == commentId }
        persistAll()
    }

    // MARK: - 预约

    func addReservation(court: Court, dateText: String, timeSlot: String, startAt: Date?) -> Reservation {
        let reservation = Reservation(
            id: UUID().uuidString,
            courtId: court.id,
            courtName: court.name,
            dateText: dateText,
            timeSlot: timeSlot,
            qrCodeText: "KENIS-\(UUID().uuidString.prefix(8).uppercased())",
            startAt: startAt
        )
        reservations.append(reservation)
        persistAll()
        return reservation
    }

    // MARK: - 视频通话记录

    /// 记录一次通话。由 `VideoCallView` 在通话结束时调用一次。
    func addCallRecord(coach: Coach, startedAt: Date, duration: TimeInterval, outcome: CallRecord.Outcome) {
        let record = CallRecord(
            id: UUID().uuidString,
            coachId: coach.id,
            coachName: coach.name,
            coachAvatar: coach.avatarName,
            startedAt: startedAt,
            duration: outcome == .completed ? duration : 0,
            outcome: outcome
        )
        callRecords.insert(record, at: 0)
        // 只保留最近 50 条，避免反复拨打无限增长
        if callRecords.count > 50 {
            callRecords.removeLast(callRecords.count - 50)
        }
        persistAll()
    }

    // MARK: - 教练预约

    /// 发起预约请求（教练通过后可视频通话）
    func requestBooking(_ coachId: String) {
        bookedCoachIds.insert(coachId)
        persistAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.approveCoach(coachId)
        }
    }

    func approveCoach(_ coachId: String) {
        if let idx = coaches.firstIndex(where: { $0.id == coachId }) {
            coaches[idx].isApproved = true
            persistAll()
        }
    }

    /// 通话被对方拒绝：撤销授权并清掉预约记录，按钮退回「Book」重新预约。
    func revokeApproval(_ coachId: String) {
        bookedCoachIds.remove(coachId)
        if let idx = coaches.firstIndex(where: { $0.id == coachId }) {
            coaches[idx].isApproved = false
        }
        persistAll()
    }

    // MARK: - 直播播放位置

    func savePlayback(_ position: Double, for streamId: String) {
        playbackPositions[streamId] = position
        persistAll()
    }

    func playback(for streamId: String) -> Double {
        playbackPositions[streamId] ?? 0
    }

    // MARK: - 举报后移除用户内容

    func reportAndRemoveUser(_ userId: String) {
        followIds.remove(userId)
        posts.removeAll { $0.authorId == userId }
        persistAll()
    }
}
