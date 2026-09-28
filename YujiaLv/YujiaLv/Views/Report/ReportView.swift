//
//  ReportView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 通用举报页：支持举报帖子、评论、用户。
struct ReportView: View {
    enum Target {
        case post(String)
        case comment(postId: String, commentId: String)
        case user(String)
    }

    let target: Target
    var onUserReported: (() -> Void)? = nil
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedReason: String?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why are you reporting this?")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                        .padding(.bottom, 4)

                    ForEach(ReportReason.all) { reason in
                        Button(action: { selectedReason = reason.title }) {
                            HStack {
                                Image(systemName: reasonIcon(for: reason.title))
                                    .foregroundColor(Theme.primary)
                                    .frame(width: 24)
                                Text(reason.title)
                                    .font(.body)
                                    .foregroundColor(Theme.dark)
                                Spacer()
                                Image(systemName: selectedReason == reason.title ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedReason == reason.title ? Theme.primary : Theme.secondaryText.opacity(0.5))
                            }
                            .padding(14)
                            .background(Theme.card)
                            .cornerRadius(Theme.cornerRadius)
                        }
                    }

                    Button(action: submit) {
                        Text("Submit Report")
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedReason == nil ? Theme.divider : Theme.danger)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .disabled(selectedReason == nil)
                    .padding(.top, 8)
                }
                .padding(Theme.pagePadding)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func reasonIcon(for title: String) -> String {
        switch title {
        case "Illegal Content": return "exclamationmark.shield"
        case "Inappropriate Content": return "hand.raised"
        case "Block User": return "person.crop.circle.badge.xmark"
        default: return "ellipsis.circle"
        }
    }

    private func submit() {
        guard let reason = selectedReason else { return }
        switch target {
        case .post(let id):
            app.deletePost(id)
            toast("Post removed")
        case .comment(let postId, let commentId):
            app.deleteComment(from: postId, commentId: commentId)
            toast("Comment removed")
        case .user(let id):
            app.reportAndRemoveUser(id)
            toast("User blocked and removed")
            onUserReported?()
        }
        _ = reason
        presentationMode.wrappedValue.dismiss()
    }
}
