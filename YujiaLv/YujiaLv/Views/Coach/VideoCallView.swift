//
//  VideoCallView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI

/// 视频通话页：进入后显示「连接中」，等待超时即视为对方拒绝，稍后自动返回。
struct VideoCallView: View {
    let coach: Coach
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    /// 通话状态：连接中 → 对方拒绝
    private enum CallState {
        case connecting
        case declined
    }

    /// 连接中等待时长，超过即视为对方拒绝
    private let connectTimeout: TimeInterval = 5
    /// 拒绝提示的停留时长，之后自动退回教练列表
    private let declinedDismissDelay: TimeInterval = 2

    @State private var state: CallState = .connecting
    /// 是否已离开本页，用于作废在途的延时任务（提前挂断时不再误判为被拒）
    @State private var isDismissed = false
    @State private var isMuted = false
    @State private var isCameraOff = false
    /// 本次通话的起始时刻与通话记录写入标记（一次通话只写一条）
    @State private var callStartedAt = Date()
    @State private var hasRecorded = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                AvatarView(name: coach.avatarName, size: 150)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )

                Text(coach.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                statusArea

                Spacer()

                HStack(spacing: 28) {
                    toggleButton(icon: isMuted ? "mic.slash.fill" : "mic.fill", active: isMuted) {
                        isMuted.toggle()
                    }
                    toggleButton(icon: isCameraOff ? "video.slash.fill" : "video.fill", active: isCameraOff) {
                        isCameraOff.toggle()
                    }
                    Button(action: hangUp) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 62)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .statusBar(hidden: true)
        .onAppear(perform: startCall)
        .onDisappear {
            isDismissed = true
            // 兜底：正常路径（拒绝 / 挂断）已经写过记录，这里会被 hasRecorded 挡掉
            finish(.cancelled)
        }
    }

    /// 状态区用最小高度兜住两种状态，避免切换时头像与文字上下跳动。
    private var statusArea: some View {
        VStack(spacing: 8) {
            switch state {
            case .connecting:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Connecting...")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            case .declined:
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.danger)
                Text("Call Declined")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(coach.name) declined the video call.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .multilineTextAlignment(.center)
        .frame(minHeight: 92)
        .padding(.horizontal, 32)
    }

    /// 等待 connectTimeout 后判定对方拒绝：撤销该教练的授权，退回「Book」，再自动返回。
    private func startCall() {
        callStartedAt = Date()

        DispatchQueue.main.asyncAfter(deadline: .now() + connectTimeout) {
            guard !isDismissed, state == .connecting else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                state = .declined
            }
            app.revokeApproval(coach.id)
            finish(.declined)

            DispatchQueue.main.asyncAfter(deadline: .now() + declinedDismissDelay) {
                guard !isDismissed else { return }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func hangUp() {
        isDismissed = true
        finish(.cancelled)
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - 通话记录

    /// 单点写入通话记录：正常路径（对方拒绝 / 自己挂断）与 `onDisappear` 兜底都走这里，
    /// `hasRecorded` 保证一次通话只落一条记录。
    private func finish(_ outcome: CallRecord.Outcome) {
        guard !hasRecorded else { return }
        hasRecorded = true

        let duration = Date().timeIntervalSince(callStartedAt)
        // onDisappear 有时落在视图更新周期内，异步写入避免
        // "Publishing changes from within view updates" 警告
        DispatchQueue.main.async {
            app.addCallRecord(coach: coach, startedAt: callStartedAt, duration: duration, outcome: outcome)
        }
    }

    private func toggleButton(icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(active ? Color.white.opacity(0.35) : Color.white.opacity(0.18))
                .clipShape(Circle())
        }
    }
}
