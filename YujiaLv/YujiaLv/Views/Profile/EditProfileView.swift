//
//  EditProfileView.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/24.
//

import SwiftUI
import Combine
import UIKit

/// 编辑个人资料页。头像不提供内置选项，仅支持用户自己从相册或相机设置。
struct EditProfileView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.presentationMode) var presentationMode

    @State private var nickname = ""
    @State private var bio = ""
    @State private var selectedAvatar = ""
    @State private var showAvatarOptions = false
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Button(action: { showAvatarOptions = true }) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(name: selectedAvatar, size: 96)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Theme.primary)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Theme.background, lineWidth: 3))
                        }
                    }
                    .buttonStyle(.plain)
                    Text(selectedAvatar.isEmpty ? "Tap to set your profile photo" : "Tap to change your profile photo")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nickname")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.secondaryText)
                    TextField("Nickname", text: $nickname)
                        .font(.body)
                        .padding(14)
                        .background(Theme.card)
                        .cornerRadius(Theme.cornerRadiusSmall)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.secondaryText)
                    TextEditor(text: $bio)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(Theme.card)
                        .cornerRadius(Theme.cornerRadiusSmall)
                }

                Button(action: save) {
                    Text("Save Changes")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Theme.dark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.accent)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding(Theme.pagePadding)
        }
        .background(Theme.background.ignoresSafeArea())
        .dismissKeyboardOnTap()
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .confirmationDialog("Profile Photo", isPresented: $showAvatarOptions, titleVisibility: .visible) {
            Button("Choose from Library") { openPicker(.photoLibrary) }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") { openPicker(.camera) }
            }
            if !selectedAvatar.isEmpty {
                Button("Remove Photo", role: .destructive) { selectedAvatar = "" }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: pickerSource) { image in
                if let name = AvatarStore.save(image, for: app.currentUser.id) {
                    selectedAvatar = name
                } else {
                    toast("Could not save this photo")
                }
            }
        }
        .onAppear {
            nickname = app.currentUser.nickname
            bio = app.currentUser.bio
            selectedAvatar = app.currentUser.avatarName
        }
    }

    private func openPicker(_ source: UIImagePickerController.SourceType) {
        pickerSource = source
        showImagePicker = true
    }

    private func save() {
        app.updateProfile(nickname: nickname, bio: bio, avatarName: selectedAvatar)
        toast("Profile updated")
        presentationMode.wrappedValue.dismiss()
    }
}
