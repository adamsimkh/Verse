import Foundation

/// A local domain model used by the prototype. A network-backed catalog can replace
/// `BookCatalog` later without changing the views or navigation contracts.
struct Book: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let author: String
    let progress: String?
    let coverAssetName: String?
    let coverTitle: String
    let rating: Double
    let ratingCountText: String
    let summary: String
    let authorBio: String
    let reviews: [BookReview]
}

struct BookReview: Identifiable, Hashable, Codable {
    let id: String
    let reviewer: String
    let rating: Int
    let text: String
}

enum BookCatalog {
    static let continueReading = [dreamCount, atmosphere, martyr]
    static let trending = [days107, beautifulUgly, shadows]
    static let forYou = [fireWeather, northWoods]

    static let fireWeather = Book(
        id: "fire-weather",
        title: "Fire Weather",
        author: "John Vaillant",
        progress: nil,
        coverAssetName: "FireWeatherCover",
        coverTitle: "FIRE\nWEATHER",
        rating: 4.7,
        ratingCountText: "1.2k reviews",
        summary: "A gripping, deeply reported journey into the front lines of a burning world — revealing how wildfires are shaping our future",
        authorBio: "John Vaillant is an award-winning journalist and bestselling author known for his work on nature, environment, and human resilience",
        reviews: [
            BookReview(
                id: "olivia-fire-weather",
                reviewer: "Olivia M.",
                rating: 5,
                text: "An essential read. Beautifully written."
            ),
            BookReview(
                id: "marcus-fire-weather",
                reviewer: "Marcus T.",
                rating: 4,
                text: "Strong reporting, slightly dense at times."
            )
        ]
    )

    static func book(withID id: Book.ID) -> Book? {
        all.first { $0.id == id }
    }

    private static let all = continueReading + trending + forYou

    private static let dreamCount = Book(
        id: "dream-count",
        title: "Dream Count",
        author: "",
        progress: "47% Complete",
        coverAssetName: "DreamCountCover",
        coverTitle: "DREAM COUNT",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let atmosphere = Book(
        id: "atmosphere",
        title: "Atmosphere",
        author: "",
        progress: "56% Complete",
        coverAssetName: "AtmosphereCover",
        coverTitle: "ATMOSPHERE",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let martyr = Book(
        id: "martyr",
        title: "Martyr!",
        author: "",
        progress: "82% Complete",
        coverAssetName: nil,
        coverTitle: "MARTYR!",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let days107 = Book(
        id: "107-days",
        title: "107 Days",
        author: "Kamala Harris",
        progress: nil,
        coverAssetName: "Days107Cover",
        coverTitle: "107 DAYS",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let beautifulUgly = Book(
        id: "beautiful-ugly",
        title: "Beautiful Ugly",
        author: "Alice Feeney",
        progress: nil,
        coverAssetName: "BeautifulUglyCover",
        coverTitle: "BEAUTIFUL UGLY",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let shadows = Book(
        id: "shadows",
        title: "Shadows",
        author: "Thomas",
        progress: nil,
        coverAssetName: nil,
        coverTitle: "SHADOWS",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )

    private static let northWoods = Book(
        id: "north-woods",
        title: "North Woods",
        author: "Daniel Mason",
        progress: nil,
        coverAssetName: nil,
        coverTitle: "NORTH\nWOODS",
        rating: 0,
        ratingCountText: "",
        summary: "",
        authorBio: "",
        reviews: []
    )
}
