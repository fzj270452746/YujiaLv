//
//  SeedData.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import Foundation

/// 应用首次启动时加载的初始内容。
enum SeedData {

    // MARK: - 直播

    static let liveStreams: [LiveStream] = [
        LiveStream(id: "live1", title: "Forehand Masterclass: Grip & Swing Path", coachId: "coach1", coachName: "Coach Marcus", coachAvatar: "coach_avatar_01", coverName: "live_cover_01", videoName: "live_video_01", viewerCount: 1284, tags: ["Forehand", "Beginner"], isLive: true, duration: "24:10"),
        LiveStream(id: "live2", title: "Two-Handed Backhand Fundamentals", coachId: "coach2", coachName: "Coach Elena", coachAvatar: "coach_avatar_02", coverName: "live_cover_02", videoName: "live_video_02", viewerCount: 862, tags: ["Backhand", "Technique"], isLive: true, duration: "18:42"),
        LiveStream(id: "live3", title: "Serve Mechanics: Toss, Trophy & Pronation", coachId: "coach3", coachName: "Coach Robert", coachAvatar: "coach_avatar_03", coverName: "live_cover_03", videoName: "live_video_03", viewerCount: 2107, tags: ["Serve", "Advanced"], isLive: true, duration: "31:05"),
        LiveStream(id: "live4", title: "Volley & Net Play Drills", coachId: "coach4", coachName: "Coach Daniel", coachAvatar: "coach_avatar_04", coverName: "live_cover_04", videoName: "live_video_04", viewerCount: 540, tags: ["Volley", "Drills"], isLive: true, duration: "15:30"),
        LiveStream(id: "live5", title: "Footwork & Agility for Court Coverage", coachId: "coach5", coachName: "Coach Sofia", coachAvatar: "coach_avatar_05", coverName: "live_cover_05", videoName: "live_video_05", viewerCount: 733, tags: ["Footwork", "Fitness"], isLive: true, duration: "21:18"),
        LiveStream(id: "live6", title: "Baseline Rally: Consistency & Depth", coachId: "coach6", coachName: "Coach James", coachAvatar: "coach_avatar_06", coverName: "live_cover_06", videoName: "live_video_06", viewerCount: 998, tags: ["Baseline", "Rally"], isLive: true, duration: "27:54")
    ]

    // MARK: - 教练

    static let coaches: [Coach] = [
        Coach(id: "coach1", name: "Marcus Reed", title: "Head Coach · 12 yrs", specialty: ["Forehand", "Serve", "Match Strategy"], avatarName: "coach_avatar_01", bio: "Former ATP-ranked player with over a decade of coaching experience. Specializes in building explosive groundstrokes and a reliable, high-percentage serve.", isOnline: true, rating: 4.9, hourlyRate: "$85/hr", isApproved: true),
        Coach(id: "coach2", name: "Elena Vasquez", title: "Senior Coach · 9 yrs", specialty: ["Backhand", "Baseline", "Footwork"], avatarName: "coach_avatar_02", bio: "Certified USPTA professional focused on modern baseline technique and movement efficiency. Passionate about helping juniors and adult beginners.", isOnline: true, rating: 4.8, hourlyRate: "$75/hr", isApproved: false),
        Coach(id: "coach3", name: "Robert Shaw", title: "Elite Coach · 20 yrs", specialty: ["Doubles", "Strategy", "Mental Game"], avatarName: "coach_avatar_03", bio: "Twenty years coaching collegiate and club players. Known for doubles tactics, court awareness and building mental resilience under pressure.", isOnline: false, rating: 5.0, hourlyRate: "$110/hr", isApproved: false),
        Coach(id: "coach4", name: "Daniel Kim", title: "Coach · 5 yrs", specialty: ["Volley", "Net Play", "Drills"], avatarName: "coach_avatar_04", bio: "Energetic coach who keeps every session high-intensity and fun. Great with intermediates looking to sharpen net skills and reaction time.", isOnline: true, rating: 4.6, hourlyRate: "$60/hr", isApproved: false),
        Coach(id: "coach5", name: "Sofia Martinez", title: "Coach · 7 yrs", specialty: ["Fitness", "Footwork", "Recovery"], avatarName: "coach_avatar_05", bio: "Tennis-specific strength and conditioning coach. Designs training that improves speed, agility and injury prevention on the court.", isOnline: true, rating: 4.7, hourlyRate: "$65/hr", isApproved: false),
        Coach(id: "coach6", name: "James Porter", title: "Coach · 15 yrs", specialty: ["All-Around", "Beginners", "Kids"], avatarName: "coach_avatar_06", bio: "Patient and encouraging coach who loves introducing new players to the game. Runs popular group clinics and private beginner programs.", isOnline: false, rating: 4.8, hourlyRate: "$70/hr", isApproved: false)
    ]

    // MARK: - 场馆

    static let courts: [Court] = [
        Court(id: "court1", name: "Riverside Tennis Club", location: "218 Riverside Dr, Austin, TX", openHours: "6:00 AM – 11:00 PM", imageName: "court_01", price: "$25/hr", rating: 4.8, surface: "Hard Court"),
        Court(id: "court2", name: "Claytop Courts", location: "77 Orchard Ave, Miami, FL", openHours: "7:00 AM – 10:00 PM", imageName: "court_02", price: "$30/hr", rating: 4.6, surface: "Clay Court"),
        Court(id: "court3", name: "Greenfield Lawn Club", location: "12 Meadow Ln, Charlotte, NC", openHours: "8:00 AM – 9:00 PM", imageName: "court_03", price: "$40/hr", rating: 4.9, surface: "Grass Court"),
        Court(id: "court4", name: "Night Court Center", location: "450 Sunset Blvd, Los Angeles, CA", openHours: "6:00 AM – 12:00 AM", imageName: "court_04", price: "$28/hr", rating: 4.7, surface: "Hard Court"),
        Court(id: "court5", name: "Grand Slam Complex", location: "900 Champion Way, Phoenix, AZ", openHours: "5:30 AM – 11:00 PM", imageName: "court_05", price: "$35/hr", rating: 4.9, surface: "Hard Court"),
        Court(id: "court6", name: "Summit Racquet Club", location: "33 Highland Rd, Denver, CO", openHours: "7:00 AM – 10:30 PM", imageName: "court_06", price: "$32/hr", rating: 4.8, surface: "Indoor Hard")
    ]

    // MARK: - 帖子

    static let posts: [Post] = [
        Post(
            id: "post1",
            authorId: "user_emma",
            authorName: "Emma Collins",
            authorAvatar: "user_avatar_03",
            content: "Golden hour practice at the club. Nothing beats a quiet court at sunrise 🌅",
            mediaNames: ["post_image_01"],
            mediaIsVideo: [false],
            likeCount: 132,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-7200),
            comments: seedComments()
        ),
        Post(
            id: "post2",
            authorId: "user_liam",
            authorName: "Liam Bennett",
            authorAvatar: "user_avatar_04",
            content: "Finally upgraded my racket! The new frame feels incredible on contact. Full review is up now.",
            mediaNames: ["post_image_02", "post_image_05"],
            mediaIsVideo: [false, false],
            likeCount: 87,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-18000),
            comments: seedComments()
        ),
        Post(
            id: "post3",
            authorId: "user_olivia",
            authorName: "Olivia Hart",
            authorAvatar: "user_avatar_05",
            content: "Sunday doubles with the crew. Who else lives for weekend match days? 🎾",
            mediaNames: ["post_image_03"],
            mediaIsVideo: [false],
            likeCount: 214,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-43200),
            comments: seedComments()
        ),
        Post(
            id: "post4",
            authorId: "user_noah",
            authorName: "Noah Patel",
            authorAvatar: "user_avatar_06",
            content: "After 3 years of league play, we finally brought home the trophy. Hard work pays off!",
            mediaNames: ["post_image_04"],
            mediaIsVideo: [false],
            likeCount: 305,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-90000),
            comments: seedComments()
        ),
        Post(
            id: "post5",
            authorId: "user_ava",
            authorName: "Ava Thompson",
            authorAvatar: "user_avatar_07",
            content: "Still working on my backhand consistency. Small steps every session!",
            mediaNames: [],
            mediaIsVideo: [],
            likeCount: 156,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-130000),
            comments: seedComments()
        ),
        Post(
            id: "post6",
            authorId: "user_lucas",
            authorName: "Lucas Meyer",
            authorAvatar: "user_avatar_01",
            content: "The split step matters more than you think. This footwork drill transformed my movement.",
            mediaNames: [],
            mediaIsVideo: [],
            likeCount: 98,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-172800),
            comments: seedComments()
        ),
        Post(
            id: "post7",
            authorId: "user_isabella",
            authorName: "Isabella Rossi",
            authorAvatar: "user_avatar_02",
            content: "Caught an epic match from the stands last night. The atmosphere was electric 🔥",
            mediaNames: [],
            mediaIsVideo: [],
            likeCount: 268,
            isLiked: false,
            timestamp: Date().addingTimeInterval(-220000),
            comments: seedComments()
        )
    ]

    // MARK: - 视频通话记录（演示数据）

    /// 预置几条通话记录，让「历史视频记录」页首次进入就有内容。
    /// 真实通话产生的记录由 `AppState.addCallRecord` 追加。
    static let callRecords: [CallRecord] = {
        let now = Date()
        return [
            CallRecord(id: "call_demo_1", coachId: "coach1", coachName: "Marcus Reed", coachAvatar: "coach_avatar_01",
                       startedAt: now.addingTimeInterval(-2 * 86400), duration: 2700, outcome: .completed),
            CallRecord(id: "call_demo_2", coachId: "coach5", coachName: "Sofia Martinez", coachAvatar: "coach_avatar_05",
                       startedAt: now.addingTimeInterval(-5 * 86400), duration: 1800, outcome: .completed),
            CallRecord(id: "call_demo_3", coachId: "coach4", coachName: "Daniel Kim", coachAvatar: "coach_avatar_04",
                       startedAt: now.addingTimeInterval(-86400), duration: 0, outcome: .declined)
        ]
    }()

    // MARK: - 场馆预约记录（演示数据）

    /// 两条演示预约：一条已结束、一条已预约。
    /// 时间相对「首次安装时刻」计算，状态由 `Reservation.status` 按当前时间自动判定。
    static let reservations: [Reservation] = {
        let calendar = Calendar.current
        let now = Date()

        // 已结束：3 天前的 18:00 - 19:00
        let pastStart = calendar.date(
            byAdding: .day, value: -3,
            to: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        ) ?? now

        // 已预约：后天 15:00 - 16:00（留出余量，隔几天再演示也不会已经过期）
        let upcomingStart = calendar.date(
            byAdding: .day, value: 2,
            to: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now
        ) ?? now

        return [
            Reservation(id: "res_demo_1", courtId: "court1", courtName: "Riverside Tennis Club",
                        dateText: DateText.day(pastStart), timeSlot: "18:00 - 19:00",
                        qrCodeText: "KENIS-DEMO0001", startAt: pastStart),
            Reservation(id: "res_demo_2", courtId: "court2", courtName: "Claytop Courts",
                        dateText: DateText.day(upcomingStart), timeSlot: "15:00 - 16:00",
                        qrCodeText: "KENIS-DEMO0002", startAt: upcomingStart)
        ]
    }()

    // MARK: - 评论生成

    private static func seedComments() -> [Comment] {
        let pool: [(String, String, String)] = [
            ("user_liam", "Liam Bennett", "user_avatar_04"),
            ("user_olivia", "Olivia Hart", "user_avatar_05"),
            ("user_noah", "Noah Patel", "user_avatar_06"),
            ("user_ava", "Ava Thompson", "user_avatar_07"),
            ("user_lucas", "Lucas Meyer", "user_avatar_01"),
            ("user_isabella", "Isabella Rossi", "user_avatar_02")
        ]
        let texts = [
            "Love this! Keep up the great work 🔥",
            "That form looks clean, well done!",
            "This is exactly what I needed to see today.",
            "So inspiring, thanks for sharing!",
            "Great content as always 👏",
            "Can't wait to try this drill myself."
        ]
        let count = Int.random(in: 3...6)
        var result: [Comment] = []
        for i in 0..<count {
            let author = pool[i % pool.count]
            let text = texts[i % texts.count]
            result.append(Comment(
                id: UUID().uuidString,
                authorId: author.0,
                authorName: author.1,
                authorAvatar: author.2,
                content: text,
                timestamp: Date().addingTimeInterval(Double(-i * 600))
            ))
        }
        return result
    }
}
