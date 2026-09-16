import Foundation

/// Fetches a small, cached selection of books currently popular on Open Library.
/// The app always has an editorial fallback, so discovery continues to work offline.
struct LiveTrendingBookService {
    static let shared = LiveTrendingBookService()

    private let endpoint = URL(string: "https://openlibrary.org/trending/weekly.json?limit=48")!

    func fetchWeeklyTrending() async -> [Book] {
        var request = URLRequest(url: endpoint)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 12
        request.setValue("Verse iOS/1.0", forHTTPHeaderField: "User-Agent")

        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let response = try? JSONDecoder().decode(TrendingResponse.self, from: data)
        else {
            return []
        }

        return response.works.compactMap(TrendingWork.book)
    }
}

private struct TrendingResponse: Decodable {
    let works: [TrendingWork]
}

private struct TrendingWork: Decodable {
    let key: String
    let title: String
    let authorNames: [String]?
    let coverID: Int?
    let isbn: [String]?
    let subjects: [String]?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorNames = "author_name"
        case coverID = "cover_i"
        case isbn
        case subjects = "subject"
        case rating = "ratings_average"
    }

    static func book(from work: TrendingWork) -> Book? {
        guard !work.key.isEmpty, !work.title.isEmpty else { return nil }

        let id = "openlibrary-" + work.key
            .replacingOccurrences(of: "/works/", with: "")
            .replacingOccurrences(of: "/", with: "-")
        let author = work.authorNames?.first ?? "Unknown author"
        let subjects = Array((work.subjects ?? []).prefix(4))

        return Book(
            id: id,
            title: work.title,
            author: author,
            progress: nil,
            coverAssetName: nil,
            coverISBN: work.isbn?.first,
            coverOpenLibraryID: work.coverID,
            genres: subjects,
            coverTitle: work.title.uppercased(),
            rating: work.rating ?? 4.2,
            ratingCountText: "Popular this week",
            summary: "A title currently popular with readers this week. Open the book to explore its details and begin reading in Verse.",
            authorBio: "More information about \(author) will be available as the Verse catalogue grows.",
            reviews: []
        )
    }
}
