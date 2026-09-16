//
//  ProfileView.swift
//  Verse
//

import PhotosUI
import SwiftUI

struct ProfileView: View {
    let user: VerseUser
    var onSignOut: () -> Void = {}
    var onProfileImageChanged: (Data?) -> Void = { _ in }

    @AppStorage("verse.dark-mode") private var usesDarkMode = false
    @AppStorage("verse.download-over-wifi") private var downloadsOverWiFi = false
    @AppStorage("verse.sync-reading-progress") private var syncReadingProgress = true
    @AppStorage("verse.reading-reminders") private var readingReminders = true
    @AppStorage("verse.review-replies") private var reviewReplies = true
    @AppStorage("verse.announcements") private var announcements = true
    @State private var topBlurOpacity = 0.0
    @State private var selectedAvatarItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    init(
        user: VerseUser = .preview,
        onSignOut: @escaping () -> Void = {},
        onProfileImageChanged: @escaping (Data?) -> Void = { _ in }
    ) {
        self.user = user
        self.onSignOut = onSignOut
        self.onProfileImageChanged = onProfileImageChanged
    }

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    profileIdentity
                        .padding(.top, 44)

                    ProfilePreferenceSection(title: "Settings") {
                        ProfileToggleRow(title: "Dark mode", isOn: $usesDarkMode)
                        ProfileToggleRow(title: "Download over Wi-Fi", isOn: $downloadsOverWiFi)
                        ProfileToggleRow(title: "Sync reading progress", isOn: $syncReadingProgress)
                    }
                    .padding(.top, 50)

                    ProfilePreferenceSection(title: "Notifications") {
                        ProfileToggleRow(title: "Reading reminders", isOn: $readingReminders)
                        ProfileToggleRow(title: "Review replies", isOn: $reviewReplies)
                        ProfileToggleRow(title: "Announcements & updates", isOn: $announcements)
                    }
                    .padding(.top, 50)

                    Button(action: onSignOut) {
                        Text("Sign out")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                    }
                    .buttonStyle(ProfileSignOutButtonStyle())
                    .padding(.top, 76)
                }
                .padding(.horizontal, 22)
                .padding(.top, 64)
                .padding(.bottom, 42)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                withAnimation(.easeOut(duration: 0.18)) {
                    topBlurOpacity = min(offset / 28, 1)
                }
            }

            ScrollEdgeBlur(opacity: topBlurOpacity)

            profileHeader
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("profile-view")
    }

    private var profileHeader: some View {
        HStack(alignment: .center) {
            Text("Profile")
                .font(VerseTypography.brandWordmark)
                .foregroundStyle(VerseColors.textMain)

            Spacer()

            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(VerseColors.textMain)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Close profile")
        }
        .padding(.horizontal, 22)
        .padding(.top, 6)
    }

    private var profileIdentity: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                    ProfileAvatarView(imageData: user.avatarData, size: 102)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.74), lineWidth: 1)
                    }
                }
                .buttonStyle(ProfileAvatarButtonStyle())
                .accessibilityLabel("Change profile photo")

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(VerseColors.background, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(VerseColors.buttonBorder.opacity(0.8), lineWidth: 1)
                    }
                    .offset(x: 3, y: 1)
                    .accessibilityHidden(true)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(user.displayName)
                    .font(Font.custom("Lora", size: 26, relativeTo: .title2).weight(.medium))
                    .foregroundStyle(VerseColors.textMain)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text("(Reader)")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                    .lineLimit(1)
            }
            .padding(.top, 19)

            Text(user.email)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(VerseColors.textMain.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(user.displayName), Reader, \(user.email)")
        .onChange(of: selectedAvatarItem) { _, newItem in
            guard let newItem else { return }

            Task {
                guard let imageData = try? await newItem.loadTransferable(type: Data.self) else {
                    return
                }

                await MainActor.run {
                    onProfileImageChanged(imageData)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

private struct ProfilePreferenceSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            Text(title)
                .font(VerseTypography.sectionTitle)
                .foregroundStyle(VerseColors.textMain)

            VStack(spacing: 22) {
                content
            }
        }
    }
}

private struct ProfileToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
        }
        .tint(VerseColors.primaryAction)
        .accessibilityLabel(title)
    }
}

private struct ProfileSignOutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color(red: 0.93, green: 0.40, blue: 0.42), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct ProfileAvatarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.78), value: configuration.isPressed)
    }
}
