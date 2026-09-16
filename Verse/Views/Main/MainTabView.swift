//
//  MainTabView.swift
//  Verse
//

import SwiftUI

struct MainTabView: View {
    var libraryBooks: [Book] = BookCatalog.libraryStarterBooks
    var onSelectBook: (Book.ID) -> Void = { _ in }
    var onShowProfile: () -> Void = {}
    var onOpenReader: (Book.ID) -> Void = { _ in }
    var onRemoveFromLibrary: (Book.ID) -> Void = { _ in }
    var onSignOut: () -> Void = {}
    var currentUser: VerseUser = .preview
    var onProfileImageChanged: (Data?) -> Void = { _ in }
    var progressTextByBookID: [Book.ID: String] = [:]
    var libraryProgressTextByBookID: [Book.ID: String] = [:]
    var continueReadingBooks: [Book] = BookCatalog.continueReading
    var trendingBooks: [Book] = BookCatalog.trending
    var recommendedBooks: [Book] = BookCatalog.forYou
    var catalogueBooks: [Book] = BookCatalog.allBooks
    var onSeeAll: (HomeBookCollection) -> Void = { _ in }

    @State private var selectedTab: AppTab = .home
    @State private var homeResetID = UUID()
    @State private var libraryResetID = UUID()
    @State private var searchResetID = UUID()

    var body: some View {
        TabView(selection: tabSelection) {
            homeTab
                .id(homeResetID)
                .tabItem {
                    Image(systemName: "house")
                        .accessibilityLabel("Home")
                }
                .tag(AppTab.home)

            libraryTab
                .id(libraryResetID)
                .tabItem {
                    Image(systemName: "books.vertical")
                        .accessibilityLabel("Library")
                }
                .tag(AppTab.library)

            SearchView(books: catalogueBooks, onSelectBook: onSelectBook)
                .id(searchResetID)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .accessibilityLabel("Search")
                }
                .tag(AppTab.search)
        }
        .tint(VerseColors.primaryAction)
    }

    @ViewBuilder
    private var homeTab: some View {
        HomeView(
            onProfileTap: onShowProfile,
            onSelectBook: onSelectBook,
            onOpenReader: onOpenReader,
            progressText: { book in
                progressTextByBookID[book.id] ?? book.progress ?? "0% Complete"
            },
            profileImageData: currentUser.avatarData,
            continueReadingBooks: continueReadingBooks,
            trendingBooks: trendingBooks,
            recommendedBooks: recommendedBooks,
            onSeeAll: onSeeAll
        )
    }

    private var libraryTab: some View {
        LibraryView(
            books: libraryBooks,
            progressText: { book in
                libraryProgressTextByBookID[book.id] ?? "In progress · \(book.progress ?? "0%")"
            },
            onOpenReader: onOpenReader,
            onViewBookDetails: onSelectBook,
            onRemoveFromLibrary: onRemoveFromLibrary
        )
    }

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { tab in
                guard tab != selectedTab else { return }

                resetContent(for: tab)
                withAnimation(.spring(response: 0.34, dampingFraction: 0.88)) {
                    selectedTab = tab
                }
            }
        )
    }

    private func resetContent(for tab: AppTab) {
        switch tab {
        case .home:
            homeResetID = UUID()
        case .library:
            libraryResetID = UUID()
        case .search:
            searchResetID = UUID()
        }
    }

}

#Preview {
    MainTabView()
}

private enum AppTab: Hashable {
    case home
    case library
    case search
}
