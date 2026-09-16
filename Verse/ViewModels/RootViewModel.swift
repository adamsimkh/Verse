//
//  RootViewModel.swift
//  Verse
//

import Foundation
import SwiftUI
import AuthenticationServices

@Observable
@MainActor
final class RootViewModel {
    static let phaseTransitionDuration: TimeInterval = 0.35
    private static let usersStorageKey = "verse.users.v1"
    private static let activeUserIDStorageKey = "verse.active-user-id.v1"

    var phase: AppPhase = .splash
    var path = NavigationPath()
    private(set) var liveTrendingBooks: [Book] = BookCatalog.trending
    private var liveBooksByID: [Book.ID: Book] = [:]
    private var hasRequestedTrending = false
    private(set) var usersByID: [String: VerseUser] {
        didSet { persistUsers() }
    }
    private(set) var activeUserID: String? {
        didSet { UserDefaults.standard.set(activeUserID, forKey: Self.activeUserIDStorageKey) }
    }

    init() {
        usersByID = Self.loadUsers()
        activeUserID = UserDefaults.standard.string(forKey: Self.activeUserIDStorageKey)
        if activeUserID.flatMap({ usersByID[$0] }) == nil {
            activeUserID = nil
        }

    }

    var currentUser: VerseUser {
        activeUserID.flatMap { usersByID[$0] } ?? .preview
    }

    var catalogueBooks: [Book] {
        uniqueBooks(BookCatalog.allBooks + liveTrendingBooks)
    }

    var libraryBooks: [Book] {
        catalogueBooks.filter { currentUser.libraryBookIDs.contains($0.id) }
    }

    var continueReadingBooks: [Book] {
        currentUser.recentlyReadBookIDs.compactMap(book(withID:))
    }

    var recommendedBooks: [Book] {
        let interactedBookIDs = currentUser.recentlyReadBookIDs + Array(currentUser.libraryBookIDs)
        let interactedBooks = interactedBookIDs.compactMap(book(withID:))
        guard !interactedBooks.isEmpty else {
            return uniqueBooks(BookCatalog.forYou + catalogueBooks).prefix(48).map { $0 }
        }

        let genreScores = interactedBooks
            .flatMap(BookCatalog.genres(for:))
            .reduce(into: [String: Int]()) { scores, genre in
                scores[genre.lowercased(), default: 0] += 1
            }

        return catalogueBooks
            .filter { !currentUser.recentlyReadBookIDs.contains($0.id) }
            .sorted { lhs, rhs in
                let lhsScore = BookCatalog.genres(for: lhs)
                    .reduce(0) { $0 + (genreScores[$1.lowercased()] ?? 0) }
                let rhsScore = BookCatalog.genres(for: rhs)
                    .reduce(0) { $0 + (genreScores[$1.lowercased()] ?? 0) }

                if lhsScore == rhsScore {
                    return lhs.rating > rhs.rating
                }
                return lhsScore > rhsScore
            }
            .prefix(48)
            .map { $0 }
    }

    var progressTextByBookID: [Book.ID: String] {
        Dictionary(uniqueKeysWithValues: catalogueBooks.map { book in
            (book.id, progressText(for: book))
        })
    }

    var libraryProgressTextByBookID: [Book.ID: String] {
        Dictionary(uniqueKeysWithValues: catalogueBooks.map { book in
            (book.id, libraryProgressText(for: book))
        })
    }

    func finishSplash() {
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = activeUserID == nil ? .authentication : .main
        }
    }

    func finishAuthentication() {
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = .userType
        }
    }

    func signInWithApple(_ credential: ASAuthorizationAppleIDCredential) {
        let wasKnownUser = usersByID[credential.user] != nil
        let existingUser = usersByID[credential.user]
        let fullName = PersonNameComponentsFormatter().string(from: credential.fullName ?? PersonNameComponents())
        let displayName = fullName.isEmpty ? (existingUser?.displayName ?? "Verse Reader") : fullName
        let email = credential.email ?? existingUser?.email ?? "reader@privaterelay.appleid.com"

        usersByID[credential.user] = VerseUser(
            id: credential.user,
            displayName: displayName,
            email: email,
            avatarData: existingUser?.avatarData,
            libraryBookIDs: existingUser?.libraryBookIDs ?? [],
            readingProgressByBookID: existingUser?.readingProgressByBookID ?? [:],
            recentlyReadBookIDs: existingUser?.recentlyReadBookIDs ?? []
        )
        activeUserID = credential.user

        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = wasKnownUser ? .main : .userType
        }
    }

    func signInWithGoogle(userID: String, displayName: String, email: String) {
        let accountID = "google-\(userID)"
        let wasKnownUser = usersByID[accountID] != nil
        let existingUser = usersByID[accountID]

        usersByID[accountID] = VerseUser(
            id: accountID,
            displayName: displayName.isEmpty ? (existingUser?.displayName ?? "Verse Reader") : displayName,
            email: email,
            avatarData: existingUser?.avatarData,
            libraryBookIDs: existingUser?.libraryBookIDs ?? [],
            readingProgressByBookID: existingUser?.readingProgressByBookID ?? [:],
            recentlyReadBookIDs: existingUser?.recentlyReadBookIDs ?? []
        )
        activeUserID = accountID

        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = wasKnownUser ? .main : .userType
        }
    }

    func returnToAuthentication() {
        activeUserID = nil
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = .authentication
        }
    }

    func finishUserType() {
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = .main
        }
    }

    func signOut() {
        path = NavigationPath()
        activeUserID = nil
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = .authentication
        }
    }

    func showBook(id: Book.ID) {
        path.append(AppRoute.bookDetail(id))
    }

    func showCollection(_ collection: HomeBookCollection) {
        path.append(AppRoute.bookCollection(collection))
    }

    func showProfile() {
        path.append(AppRoute.profile)
    }

    func showReader(id: Book.ID) {
        updateCurrentUser { user in
            if user.readingProgressByBookID[id] == nil {
                user.readingProgressByBookID[id] = 1
            }
            user.recentlyReadBookIDs.removeAll { $0 == id }
            user.recentlyReadBookIDs.insert(id, at: 0)
        }
        path.append(AppRoute.reader(id))
    }

    func loadLiveTrending() async {
        guard !hasRequestedTrending else { return }
        hasRequestedTrending = true

        let fetchedBooks = await LiveTrendingBookService.shared.fetchWeeklyTrending()
        guard !fetchedBooks.isEmpty else { return }

        liveTrendingBooks = fetchedBooks
        liveBooksByID = Dictionary(uniqueKeysWithValues: fetchedBooks.map { ($0.id, $0) })
    }

    func books(for collection: HomeBookCollection) -> [Book] {
        switch collection {
        case .continueReading:
            continueReadingBooks
        case .trending:
            liveTrendingBooks
        case .forYou:
            recommendedBooks
        }
    }

    func book(withID id: Book.ID) -> Book? {
        liveBooksByID[id] ?? BookCatalog.book(withID: id)
    }

    func toggleLibraryBook(id: Book.ID) {
        updateCurrentUser { user in
            if user.libraryBookIDs.contains(id) {
                user.libraryBookIDs.remove(id)
            } else {
                user.libraryBookIDs.insert(id)
            }
        }
    }

    func removeFromLibrary(id: Book.ID) {
        updateCurrentUser { user in
            user.libraryBookIDs.remove(id)
        }
    }

    func isInLibrary(id: Book.ID) -> Bool {
        currentUser.libraryBookIDs.contains(id)
    }

    func lastReadChapter(for id: Book.ID) -> Int {
        currentUser.readingProgressByBookID[id] ?? 1
    }

    func updateLastReadChapter(_ chapter: Int, for id: Book.ID) {
        let chapterCount = book(withID: id)
            .map { BookReaderCatalog.chapters(for: $0).count } ?? 1
        updateCurrentUser { user in
            user.readingProgressByBookID[id] = min(max(chapter, 1), chapterCount)
        }
    }

    func updateProfileImage(_ imageData: Data?) {
        updateCurrentUser { user in
            user.avatarData = imageData
        }
    }

    func progressText(for book: Book) -> String {
        if isCompleted(book) {
            return "Completed · 100%"
        }

        return "\(progressPercentage(for: book))% Complete"
    }

    func libraryProgressText(for book: Book) -> String {
        if isCompleted(book) {
            return "Completed · 100%"
        }

        return "In progress · \(progressPercentage(for: book))%"
    }

    private func isCompleted(_ book: Book) -> Bool {
        guard let finalChapterID = BookReaderCatalog.chapters(for: book).last?.id else {
            return false
        }
        return lastReadChapter(for: book.id) >= finalChapterID
    }

    private func progressPercentage(for book: Book) -> Int {
        let chapterCount = max(BookReaderCatalog.chapters(for: book).count, 1)
        return Int((Double(lastReadChapter(for: book.id)) / Double(chapterCount) * 100).rounded())
    }

    private func uniqueBooks(_ books: [Book]) -> [Book] {
        var seenBookIDs = Set<Book.ID>()
        return books.filter { seenBookIDs.insert($0.id).inserted }
    }

    private static func loadUsers() -> [String: VerseUser] {
        guard
            let data = UserDefaults.standard.data(forKey: usersStorageKey),
            let users = try? JSONDecoder().decode([String: VerseUser].self, from: data)
        else {
            return [:]
        }
        return users
    }

    private func persistUsers() {
        guard let data = try? JSONEncoder().encode(usersByID) else { return }
        UserDefaults.standard.set(data, forKey: Self.usersStorageKey)
    }

    private func updateCurrentUser(_ update: (inout VerseUser) -> Void) {
        guard let activeUserID, var user = usersByID[activeUserID] else { return }
        update(&user)
        usersByID[activeUserID] = user
    }

}
