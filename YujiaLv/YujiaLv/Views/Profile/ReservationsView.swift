//
//  ReservationsView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI

/// 场馆预定记录页（About → Court Reservations）。
///
/// 分「Upcoming（已预约）」与「Completed（已结束）」两组，
/// 状态由 `Reservation.status` 按当前时间自动判定。
struct ReservationsView: View {
    @EnvironmentObject var app: AppState

    /// 用于再次展示二维码（复用预约成功时的票根）
    @State private var ticket: Reservation?

    private var upcoming: [Reservation] {
        let list = app.reservations.filter { $0.status == .upcoming }
        return list.sorted { first, second in
            let lhs: Date = first.startAt ?? .distantFuture
            let rhs: Date = second.startAt ?? .distantFuture
            return lhs < rhs
        }
    }

    private var past: [Reservation] {
        let list = app.reservations.filter { $0.status == .ended }
        return list.sorted { first, second in
            let lhs: Date = first.startAt ?? .distantPast
            let rhs: Date = second.startAt ?? .distantPast
            return lhs > rhs
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if upcoming.isEmpty && past.isEmpty {
                    EmptyStateView(icon: "calendar", message: "No court reservations yet")
                        .padding(.top, 60)
                } else {
                    if !upcoming.isEmpty {
                        section(title: "Upcoming") {
                            ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, reservation in
                                VStack(spacing: 0) {
                                    if index > 0 { Divider().padding(.leading, 82) }
                                    // 已预约的可以点开重看二维码；已结束的没有入场意义，保持静态
                                    Button(action: { ticket = reservation }) {
                                        reservationRow(reservation, showsChevron: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    if !past.isEmpty {
                        section(title: "Completed") {
                            ForEach(Array(past.enumerated()), id: \.element.id) { index, reservation in
                                VStack(spacing: 0) {
                                    if index > 0 { Divider().padding(.leading, 82) }
                                    reservationRow(reservation, showsChevron: false)
                                }
                            }
                        }
                    }
                }
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Court Reservations")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .sheet(item: $ticket) { reservation in
            ReservationTicketView(reservation: reservation)
        }
    }

    // MARK: - 分组与行

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(Theme.dark)
            VStack(spacing: 0) {
                content()
            }
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
        }
    }

    private func reservationRow(_ reservation: Reservation, showsChevron: Bool) -> some View {
        HStack(spacing: 12) {
            // 缩略图给显式尺寸：`scaledToFill` 会把填满后的尺寸回报给布局，撑坏整行
            AssetImage(name: courtImageName(for: reservation), fallbackSystemImage: "sportscourt")
                .frame(width: 56, height: 56)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(reservation.courtName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.dark)
                    .lineLimit(1)
                Text("\(reservation.displayDateText) · \(reservation.timeSlot)")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusChip(
                    text: reservation.status == .upcoming ? "Upcoming" : "Completed",
                    color: reservation.status == .upcoming ? Theme.primary : Theme.secondaryText
                )
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    /// 记录里只存了 courtId，场馆图从 `app.courts` 现查。
    private func courtImageName(for reservation: Reservation) -> String {
        app.courts.first { $0.id == reservation.courtId }?.imageName ?? ""
    }
}
