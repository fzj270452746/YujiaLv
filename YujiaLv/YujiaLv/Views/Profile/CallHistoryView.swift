//
//  CallHistoryView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import SwiftUI

/// 历史视频通话记录页（About → Video Call Lessons）。
///
/// 数据 = `SeedData.callRecords` 的演示记录 + 真实通话结束时写入的记录。
struct CallHistoryView: View {
    @EnvironmentObject var app: AppState

    /// 最近的通话排在最前
    private var records: [CallRecord] {
        app.callRecords.sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if records.isEmpty {
                    EmptyStateView(icon: "video", message: "No video call history yet")
                        .padding(.top, 60)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            VStack(spacing: 0) {
                                if index > 0 {
                                    Divider().padding(.leading, 70)
                                }
                                callRow(record)
                            }
                        }
                    }
                    .background(Theme.card)
                    .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Video Call History")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }

    // MARK: - 行

    private func callRow(_ record: CallRecord) -> some View {
        HStack(spacing: 12) {
            AvatarView(name: record.coachAvatar, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.coachName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.dark)
                Text(detailText(for: record))
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusChip(text: statusText(for: record.outcome), color: statusColor(for: record.outcome))
                Text(DateText.dayAndTime(record.startedAt))
                    .font(.caption2)
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func detailText(for record: CallRecord) -> String {
        switch record.outcome {
        case .completed: return "Video Call · \(DateText.duration(record.duration))"
        case .declined: return "Video Call · No answer"
        case .cancelled: return "Video Call · Cancelled"
        }
    }

    private func statusText(for outcome: CallRecord.Outcome) -> String {
        switch outcome {
        case .completed: return "Completed"
        case .declined: return "Missed"
        case .cancelled: return "Cancelled"
        }
    }

    private func statusColor(for outcome: CallRecord.Outcome) -> Color {
        switch outcome {
        case .completed: return Theme.primary
        case .declined: return Theme.danger
        case .cancelled: return Theme.secondaryText
        }
    }
}
