//
//  CreateView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine

/// 发布帖子页。
struct CreateView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var content = ""
    @State private var selectedMediaName: String?
    @State private var selectedMediaIsVideo = false
    @State private var showMediaPicker = false
    @State private var showLogin = false
    @State private var showEULA = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 14) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .padding(6)
                        if content.isEmpty {
                            Text("Share your tennis moment...")
                                .foregroundColor(Theme.secondaryText)
                                .padding(.top, 14)
                                .padding(.leading, 10)
                                .allowsHitTesting(false)
                        }
                    }
                    .background(Theme.card)
                    .cornerRadius(Theme.cornerRadius)

                    if let media = selectedMediaName {
                        ZStack(alignment: .topTrailing) {
                            if selectedMediaIsVideo {
                                AssetVideo(name: media)
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(Theme.cornerRadiusSmall)
                            } else {
                                AssetImage(name: media, fallbackSystemImage: "photo")
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(Theme.cornerRadiusSmall)
                            }
                            Button(action: { selectedMediaName = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(6)
                            }
                        }
                    }

                    Button(action: { showMediaPicker = true }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedMediaName == nil ? "Add Photo or Video" : "Change Media")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary.opacity(0.08))
                        .cornerRadius(Theme.cornerRadius)
                    }

                    eulaFooter

                    Spacer()
                }
                .padding(Theme.pagePadding)

                if isLoading {
                    LoadingOverlay(message: "Posting...")
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") { publish() }
                        .font(.body.weight(.semibold))
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showMediaPicker) {
            MediaPickerSheet { name, isVideo in
                selectedMediaName = name
                selectedMediaIsVideo = isVideo
            }
        }
        .sheet(isPresented: $showEULA) {
            NavigationView {
                TextPage(title: "EULA", text: LegalText.eula)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showEULA = false }
                                .font(.body.weight(.semibold))
                                .foregroundColor(Theme.primary)
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
    }

    // MARK: - EULA 入口

    private var eulaFooter: some View {
        Button(action: { showEULA = true }) {
            (
                Text("By posting, you agree to the ").foregroundColor(Theme.secondaryText)
                + Text("EULA").fontWeight(.semibold).foregroundColor(Theme.primary).underline()
                + Text(".").foregroundColor(Theme.secondaryText)
            )
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 2)
        }
        .buttonStyle(.plain)
    }

    private func publish() {
        guard app.isLoggedIn else {
            showLogin = true
            return
        }
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty || selectedMediaName != nil else {
            toast("Write something first")
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            app.addPost(
                content: content,
                mediaNames: selectedMediaName.map { [$0] } ?? [],
                mediaIsVideo: selectedMediaName.map { _ in [selectedMediaIsVideo] } ?? []
            )
            toast("Posted successfully")
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 媒体选择

struct MediaPickerSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let onSelect: (String, Bool) -> Void

    private let images = (1...8).map { "post_image_0\($0)" }
    private let videos = ["post_video_01", "post_video_02"]
    private let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Photos")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(images, id: \.self) { name in
                            Button(action: { onSelect(name, false); presentationMode.wrappedValue.dismiss() }) {
                                AssetImage(name: name, fallbackSystemImage: "photo")
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }

                    Text("Videos")
                        .font(.headline)
                        .foregroundColor(Theme.dark)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(videos, id: \.self) { name in
                            Button(action: { onSelect(name, true); presentationMode.wrappedValue.dismiss() }) {
                                AssetVideo(name: name)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(Theme.pagePadding)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
