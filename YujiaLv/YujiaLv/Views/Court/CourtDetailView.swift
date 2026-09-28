//
//  CourtDetailView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine
import CoreImage.CIFilterBuiltins

/// 场馆详情 + 预约（预约成功生成二维码）。
struct CourtDetailView: View {
    let court: Court
    @EnvironmentObject var app: AppState

    /// 日期选项：显示文案 + 相对今天的天数偏移。
    /// 用类型而不是裸字符串，避免「Today」这种展示文案被当成数据往上传。
    private struct DateOption: Hashable {
        let label: String
        let dayOffset: Int
    }

    private let dates = [
        DateOption(label: "Today", dayOffset: 0),
        DateOption(label: "Tomorrow", dayOffset: 1),
        DateOption(label: "In 2 Days", dayOffset: 2)
    ]
    private let slots = ["09:00 - 10:00", "11:00 - 12:00", "15:00 - 16:00", "18:00 - 19:00", "20:00 - 21:00"]

    @State private var selectedDate = DateOption(label: "Today", dayOffset: 0)
    @State private var selectedSlot = "09:00 - 10:00"
    @State private var reservation: Reservation?
    @State private var showLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                AssetImage(name: court.imageName, fallbackSystemImage: "sportscourt")
                    .frame(height: 210)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(Theme.cornerRadius)

                VStack(alignment: .leading, spacing: 6) {
                    Text(court.name)
                        .font(.title2.bold())
                        .foregroundColor(Theme.dark)
                    HStack {
                        Label(court.location, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                        Spacer()
                        Label(String(format: "%.1f", court.rating), systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    HStack {
                        Label(court.openHours, systemImage: "clock")
                        Spacer()
                        Text(court.surface)
                    }
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                    Text(court.price + " per hour")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.primary)
                }

                // 日期选择
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Date")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    HStack(spacing: 8) {
                        ForEach(dates, id: \.self) { date in
                            Button(action: { selectedDate = date }) {
                                Text(date.label)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundColor(selectedDate == date ? Theme.dark : Theme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedDate == date ? Theme.accent : Theme.card)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                // 时间段选择
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Time")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(slots, id: \.self) { slot in
                            Button(action: { selectedSlot = slot }) {
                                Text(slot)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(selectedSlot == slot ? Theme.dark : Theme.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedSlot == slot ? Theme.accent : Theme.card)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Button(action: confirmBooking) {
                    Text("Confirm Booking")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Theme.dark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .cornerRadius(Theme.cornerRadius)
                }
                .padding(.top, 4)
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(court.name)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .sheet(item: $reservation) { res in
            ReservationTicketView(reservation: res)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
    }

    private func confirmBooking() {
        guard app.isLoggedIn else {
            showLogin = true
            return
        }
        let res = app.addReservation(
            court: court,
            dateText: selectedDate.label,
            timeSlot: selectedSlot,
            startAt: Self.startDate(dayOffset: selectedDate.dayOffset, timeSlot: selectedSlot)
        )
        reservation = res
    }

    /// 把「今天 + N 天」与 "09:00 - 10:00" 合成绝对开始时间，供预约记录判定「已预约 / 已结束」。
    private static func startDate(dayOffset: Int, timeSlot: String) -> Date? {
        guard let first = timeSlot.components(separatedBy: " - ").first else { return nil }
        let comps = first.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
        guard comps.count == 2, let hour = Int(comps[0]), let minute = Int(comps[1]) else { return nil }

        let calendar = Calendar.current
        guard let timeToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) else { return nil }
        return calendar.date(byAdding: .day, value: dayOffset, to: timeToday)
    }
}

// MARK: - 预约成功 + 二维码

struct ReservationTicketView: View {
    let reservation: Reservation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Theme.divider)
                .frame(width: 40, height: 5)
                .padding(.top, 12)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundColor(Theme.primary)

            Text("Booking Confirmed")
                .font(.title2.bold())
                .foregroundColor(Theme.dark)

            VStack(spacing: 8) {
                Text(reservation.courtName)
                    .font(.headline)
                    .foregroundColor(Theme.dark)
                Text("\(reservation.displayDateText) · \(reservation.timeSlot)")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
            }

            if let qr = QRCodeGenerator.generate(reservation.qrCodeText) {
                Image(uiImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
            }

            Text("Show this code at the venue")
                .font(.caption)
                .foregroundColor(Theme.secondaryText)

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Theme.dark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Theme.accent)
                    .cornerRadius(Theme.cornerRadius)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

/// 二维码生成器。
enum QRCodeGenerator {
    static func generate(_ string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

