//
//  AvatarStore.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import UIKit

/// 用户自设头像的本地存储。
///
/// 用户在「编辑资料」中从相册或相机选择的照片会压缩后写入沙盒 `Documents/Avatars`，
/// 模型里以 `local:<文件名>` 的形式记录，用于与 Assets 中的内置资源名区分。
enum AvatarStore {

    /// 自设头像在 `avatarName` 中的前缀。
    static let localPrefix = "local:"

    private static let folderName = "Avatars"

    /// 头像最长边像素，避免原图过大占用存储。
    private static let maxDimension: CGFloat = 512

    private static let cache = NSCache<NSString, UIImage>()

    private static var directory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    // MARK: - 读取

    /// 解析 `avatarName` 对应的图片：`local:` 前缀读沙盒，其余读 Assets 资源。
    static func image(named name: String) -> UIImage? {
        guard !name.isEmpty else { return nil }

        guard name.hasPrefix(localPrefix) else { return UIImage(named: name) }

        if let cached = cache.object(forKey: name as NSString) { return cached }
        let file = String(name.dropFirst(localPrefix.count))
        guard let image = UIImage(contentsOfFile: directory.appendingPathComponent(file).path) else { return nil }
        cache.setObject(image, forKey: name as NSString)
        return image
    }

    // MARK: - 写入 / 删除

    /// 保存用户自设头像，返回可写入 `avatarName` 的标识；文件名与用户绑定，重新设置会直接覆盖。
    static func save(_ image: UIImage, for userId: String) -> String? {
        let name = localPrefix + fileName(for: userId)
        guard let data = resized(image).jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: directory.appendingPathComponent(fileName(for: userId)), options: .atomic)
            cache.removeObject(forKey: name as NSString)
            return name
        } catch {
            return nil
        }
    }

    /// 删除某个用户的自设头像。
    static func remove(for userId: String) {
        let name = localPrefix + fileName(for: userId)
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(fileName(for: userId)))
        cache.removeObject(forKey: name as NSString)
    }

    // MARK: - 私有

    private static func fileName(for userId: String) -> String {
        let safe = userId.map { $0.isLetter || $0.isNumber ? $0 : "_" }
        return "avatar_" + String(safe) + ".jpg"
    }

    /// 等比缩放，保证最长边不超过 `maxDimension`。
    private static func resized(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: target)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
