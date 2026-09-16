//
//  RootView.swift
//  Verse
//

import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()
    @AppStorage("verse.dark-mode") private var usesDarkMode = false

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.path) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .bookDetail(let bookID):
                        BookDetailView(
                            book: viewModel.book(withID: bookID) ?? BookCatalog.fireWeather,
                            isInLibrary: viewModel.isInLibrary(id: bookID),
                            onReadNow: { viewModel.showReader(id: bookID) },
                            onToggleLibrary: { viewModel.toggleLibraryBook(id: bookID) }
                        )
                    case .reader(let bookID):
                        ReaderView(
                            book: viewModel.book(withID: bookID) ?? BookCatalog.fireWeather,
                            initialChapterID: viewModel.lastReadChapter(for: bookID),
                            onChapterChanged: { chapter in
                                viewModel.updateLastReadChapter(chapter, for: bookID)
                            }
                        )
                    case .profile:
                        ProfileView(
                            user: viewModel.currentUser,
                            onSignOut: viewModel.signOut,
                            onProfileImageChanged: viewModel.updateProfileImage
                        )
                    case .bookCollection(let collection):
                        BookCollectionView(
                            collection: collection,
                            books: viewModel.books(for: collection),
                            progressText: viewModel.progressText(for:),
                            isInLibrary: viewModel.isInLibrary(id:),
                            onOpenReader: viewModel.showReader,
                            onViewBookDetails: viewModel.showBook,
                            onToggleLibrary: viewModel.toggleLibraryBook
                        )
                    }
                }
        }
        .preferredColorScheme(usesDarkMode ? .dark : .light)
    }

    @ViewBuilder
    private var rootContent: some View {
        Group {
            switch viewModel.phase {
            case .splash:
                SplashView(onComplete: viewModel.finishSplash)
                    .transition(.opacity)
            case .authentication:
                AuthenticationView(
                    onAppleAuthorization: viewModel.signInWithApple,
                    onGoogleAuthorization: viewModel.signInWithGoogle
                )
                    .transition(.opacity)
            case .userType:
                UserTypeView(
                    onBack: viewModel.returnToAuthentication,
                    onSkip: viewModel.finishUserType,
                    onContinue: viewModel.finishUserType
                )
                    .transition(.opacity)
            case .main:
                MainTabView(
                    libraryBooks: viewModel.libraryBooks,
                    onSelectBook: viewModel.showBook,
                    onShowProfile: viewModel.showProfile,
                    onOpenReader: viewModel.showReader,
                    onRemoveFromLibrary: viewModel.removeFromLibrary,
                    onSignOut: viewModel.signOut,
                    currentUser: viewModel.currentUser,
                    onProfileImageChanged: viewModel.updateProfileImage,
                    progressTextByBookID: viewModel.progressTextByBookID,
                    libraryProgressTextByBookID: viewModel.libraryProgressTextByBookID,
                    continueReadingBooks: viewModel.continueReadingBooks,
                    trendingBooks: viewModel.liveTrendingBooks,
                    recommendedBooks: viewModel.recommendedBooks,
                    catalogueBooks: viewModel.catalogueBooks,
                    onSeeAll: viewModel.showCollection
                )
                .task {
                    await viewModel.loadLiveTrending()
                }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: RootViewModel.phaseTransitionDuration), value: viewModel.phase)
    }
}

#Preview {
    RootView()
}
