//
//  CoachDetailView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 教练详情页：介绍、擅长、预约 / 视频通话。
struct CoachDetailView: View {
    let coach: Coach
    @EnvironmentObject var app: AppState
    @State private var showCall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 12) {
                    AvatarView(name: coach.avatarName, size: 100)
                        .overlay(alignment: .bottomTrailing) {
                            if coach.isOnline {
                                Circle()
                                    .fill(Theme.online)
                                    .frame(width: 22, height: 22)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            }
                        }
                    VStack(spacing: 4) {
                        Text(coach.name)
                            .font(.title2.bold())
                            .foregroundColor(Theme.dark)
                        Text(coach.title)
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").font(.caption).foregroundColor(.orange)
                        Text(String(format: "%.1f", coach.rating))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.dark)
                        Text(coach.hourlyRate)
                            .font(.subheadline)
                            .foregroundColor(Theme.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                infoSection(title: "About", content: coach.bio)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Specialties")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    FlowTags(tags: coach.specialty)
                }

                bookingButton
                    .padding(.top, 4)
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(coach.name)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .fullScreenCover(isPresented: $showCall) {
            VideoCallView(coach: coach)
        }
    }

    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.dark)
            Text(content)
                .font(.body)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
    }

    private var bookingButton: some View {
        Button(action: handleBooking) {
            Text(bookingTitle)
                .font(.body.weight(.semibold))
                .foregroundColor(bookingTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(bookingBackground)
                .cornerRadius(Theme.cornerRadius)
        }
        .disabled(coach.isApproved == false && app.bookedCoachIds.contains(coach.id))
    }

    private var bookingTitle: String {
        if coach.isApproved { return "Video Call" }
        if app.bookedCoachIds.contains(coach.id) { return "Booked" }
        return "Book a Session"
    }

    private var bookingTextColor: Color {
        if coach.isApproved { return .white }
        if app.bookedCoachIds.contains(coach.id) { return Theme.secondaryText }
        return Theme.dark
    }

    private var bookingBackground: Color {
        if coach.isApproved { return Theme.primary }
        if app.bookedCoachIds.contains(coach.id) { return Theme.divider }
        return Theme.accent
    }

    private func handleBooking() {
        guard app.isLoggedIn else {
            toast("Sign in to book a session")
            return
        }
        if coach.isApproved {
            showCall = true
        } else if app.bookedCoachIds.contains(coach.id) {
            toast("Booking request already sent")
        } else {
            app.requestBooking(coach.id)
            toast("Booking request sent to \(coach.name)")
        }
    }
}

/// 标签流式排列（iOS 15 兼容）。
struct FlowTags: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        Text(tag)
                            .font(.caption.weight(.medium))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.primary.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []
        for tag in tags {
            if current.count >= 3 {
                result.append(current)
                current = [tag]
            } else {
                current.append(tag)
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}
