//
//  LegalText.swift
//  YujiaLv
//
//  Created by Hades on 2026/9/27.
//

import Foundation

/// 应用内法律文本：服务条款 / 隐私政策 / 最终用户许可协议（EULA）。
enum LegalText {

    /// 最终用户许可协议（发布页可查看详情）。
    static let eula = """
    End User License Agreement (EULA)

    Last updated: September 27, 2026

    Please read this End User License Agreement ("Agreement") carefully before using the Kenis application ("App"). By downloading, installing or using the App, you agree to be bound by this Agreement. If you do not agree, please do not use the App.

    1. License Grant
    Kenis grants you a limited, non-exclusive, non-transferable, revocable license to download, install and use the App on Apple-branded devices that you own or control, solely for your personal, non-commercial use, subject to the App Store Terms of Service.

    2. Scope of License
    You may not:
    - copy, modify, distribute, sell, lease, sublicense or otherwise transfer the App or any part of it;
    - reverse engineer, decompile, disassemble or attempt to derive the source code of the App, except to the extent permitted by applicable law;
    - remove, obscure or alter any copyright, trademark or other proprietary notices;
    - use the App to upload content that is unlawful, infringing, harassing, hateful, sexually explicit or otherwise objectionable, or content you do not have the right to share.

    3. User Content
    You retain ownership of the photos, videos, comments and other content you submit. By posting content you grant Kenis a worldwide, non-exclusive, royalty-free license to host, store, reproduce and display that content within the App solely to operate and improve the service. You are solely responsible for the content you submit and for holding all rights necessary to share it.

    4. Coaching, Bookings and Payments
    Live streams, video-call coaching sessions and court reservations are provided by independent coaches and venues. Availability, pricing and session quality are the responsibility of the respective provider. Prices are displayed before you confirm a booking.

    5. Privacy
    Your use of the App is also governed by our Privacy Policy, which describes how we collect, use and protect your information.

    6. Third-Party Services and Apple Terms
    You acknowledge that this Agreement is between you and Kenis only, and not with Apple. Apple is not responsible for the App or its content. Apple and its subsidiaries are third-party beneficiaries of this Agreement and may enforce it against you. Your use of the App must comply with the App Store Terms of Service.

    7. No Warranty
    The App is provided "AS IS" and "AS AVAILABLE", without warranty of any kind, express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose and non-infringement. We do not warrant that the App will be uninterrupted, error-free or free of harmful components.

    8. Limitation of Liability
    To the maximum extent permitted by law, Kenis shall not be liable for any indirect, incidental, special, consequential or punitive damages, or any loss of data, revenue or profits, arising out of or related to your use of the App.

    9. Termination
    This license is effective until terminated. It terminates automatically if you breach any term of this Agreement. You may terminate it at any time by deleting your account and uninstalling the App. On termination you must stop all use of the App.

    10. Changes
    We may update this Agreement from time to time. Continued use of the App after changes take effect constitutes acceptance of the revised Agreement.

    11. Contact
    Questions about this Agreement: support@kenis.app
    """

    /// 服务条款。
    static let termsOfService = """
    Welcome to Kenis. By creating an account or using the app, you agree to these Terms of Service.

    1. Accounts
    You are responsible for maintaining the confidentiality of your account credentials and for all activity under your account.

    2. Acceptable Use
    You agree not to post content that is unlawful, harassing, defamatory, or otherwise harmful. We reserve the right to remove content and suspend accounts that violate these terms.

    3. Coaching & Bookings
    Video-call coaching sessions and court reservations are subject to availability. Prices are displayed before confirmation.

    4. Intellectual Property
    All content, trademarks, and features of the app are owned by Kenis and its licensors.

    5. Termination
    You may delete your account at any time from your profile. We may suspend or terminate access for violations of these terms.

    If you have questions, contact support@kenis.app.
    """

    /// 隐私政策。
    static let privacyPolicy = """
    This Privacy Policy explains how Kenis collects and uses your information.

    1. Information We Collect
    We collect the account information you provide (username, profile details) and your activity within the app, such as posts, likes, and bookings.

    2. How We Use Information
    We use your information to provide and improve the service, personalize your experience, and keep the community safe.

    3. Sharing
    We do not sell your personal information. We may share limited information with service providers who help operate the app.

    4. Data Retention
    We retain your information while your account is active. Deleting your account removes your profile and posts.

    5. Your Choices
    You can update or delete your account at any time from your profile.

    For privacy questions, contact support@kenis.app.
    """
}
