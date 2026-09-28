//
//  CoachesView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 教练列表页：展示教练信息，支持预约与视频通话。
struct CoachesView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                ForEach(app.coaches) { coach in
                    CoachCard(coach: coach)
                }
            }
            .padding(.horizontal, Theme.pagePadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Coaches")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.dark)
                Text("Book a session with a pro")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
            }
            Spacer()
        }
        .padding(.top, 4)
    }
}

/// 教练卡片。
struct CoachCard: View {
    @EnvironmentObject var app: AppState
    let coach: Coach
    @State private var showCall = false

    var body: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: CoachDetailView(coach: coach)) {
                HStack(spacing: 12) {
                    AvatarView(name: coach.avatarName, size: 56)
                        .overlay(alignment: .bottomTrailing) {
                            if coach.isOnline {
                                Circle()
                                    .fill(Theme.online)
                                    .frame(width: 13, height: 13)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(coach.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Theme.dark)
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", coach.rating))
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                        Text(coach.title)
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                        HStack(spacing: 4) {
                            ForEach(coach.specialty.prefix(2), id: \.self) { s in
                                Text(s)
                                    .font(.caption2)
                                    .foregroundColor(Theme.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.primary.opacity(0.12))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            bookingButton
        }
        .padding(12)
        .background(Theme.card)
        .cornerRadius(Theme.cornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .fullScreenCover(isPresented: $showCall) {
            VideoCallView(coach: coach)
        }
    }

    private var bookingButton: some View {
        Button(action: handleBooking) {
            Text(bookingTitle)
                .font(.footnote.weight(.semibold))
                .foregroundColor(bookingTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(bookingBackground)
                .cornerRadius(18)
        }
        .disabled(coach.isApproved == false && app.bookedCoachIds.contains(coach.id))
    }

    private var bookingTitle: String {
        if coach.isApproved { return "Video Call" }
        if app.bookedCoachIds.contains(coach.id) { return "Booked" }
        return "Book"
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
