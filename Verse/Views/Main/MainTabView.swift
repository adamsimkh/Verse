//
//  MainTabView.swift
//  Verse
//

import SwiftUI

struct MainTabView: View {
    var onSelectBook: (Book.ID) -> Void = { _ in }

    @State private var selectedTab: AppTab = .home
    @State private var isShowingProfile = false

    var body: some View {
        ZStack(alignment: .bottom) {
            currentContent

            VerseTabBar(
                selectedTab: Binding(
                    get: { selectedTab },
                    set: {
                        selectedTab = $0
                        isShowingProfile = false
                    }
                )
            )
            .padding(.horizontal, 72)
            .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private var currentContent: some View {
        if isShowingProfile {
            ProfileView()
        } else {
            switch selectedTab {
            case .home:
                HomeView(
                    onProfileTap: { isShowingProfile = true },
                    onSelectBook: onSelectBook
                )
            case .library:
                LibraryView()
            case .search:
                SearchView()
            }
        }
    }
}

#Preview {
    MainTabView()
}

private enum AppTab: CaseIterable, Hashable {
    case home
    case library
    case search

    var iconName: String {
        switch self {
        case .home: "house"
        case .library: "books.vertical"
        case .search: "magnifyingglass"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .home: "Home"
        case .library: "Library"
        case .search: "Search"
        }
    }
}

private struct VerseTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Image(systemName: tab.iconName)
                        .font(.system(size: 22, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .foregroundStyle(tab == selectedTab ? VerseColors.primaryAction : VerseColors.textMain)
                        .background {
                            if tab == selectedTab {
                                Capsule()
                                    .fill(VerseColors.primaryAction.opacity(0.18))
                            }
                        }
                }
                .buttonStyle(TabPressButtonStyle())
                .accessibilityLabel(tab.accessibilityLabel)
                .accessibilityAddTraits(tab == selectedTab ? .isSelected : [])
            }
        }
        .padding(8)
        .background(.white.opacity(0.72), in: Capsule())
        .glassEffect(.regular, in: Capsule())
        .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
    }
}

private struct TabPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
