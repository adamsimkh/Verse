//
//  VerseUser.swift
//  Verse
//

import Foundation

struct VerseUser: Codable, Equatable {
    let id: String
    var displayName: String
    var email: String
    var avatarData: Data?
    var libraryBookIDs: Set<Book.ID>
    var readingProgressByBookID: [Book.ID: Int]
    var recentlyReadBookIDs: [Book.ID]

    init(
        id: String,
        displayName: String,
        email: String,
        avatarData: Data?,
        libraryBookIDs: Set<Book.ID>,
        readingProgressByBookID: [Book.ID: Int],
        recentlyReadBookIDs: [Book.ID]
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarData = avatarData
        self.libraryBookIDs = libraryBookIDs
        self.readingProgressByBookID = readingProgressByBookID
        self.recentlyReadBookIDs = recentlyReadBookIDs
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case email
        case avatarData
        case libraryBookIDs
        case readingProgressByBookID
        case recentlyReadBookIDs
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        displayName = try values.decode(String.self, forKey: .displayName)
        email = try values.decode(String.self, forKey: .email)
        avatarData = try values.decodeIfPresent(Data.self, forKey: .avatarData)
        libraryBookIDs = try values.decodeIfPresent(Set<Book.ID>.self, forKey: .libraryBookIDs) ?? []
        readingProgressByBookID = try values.decodeIfPresent([Book.ID: Int].self, forKey: .readingProgressByBookID) ?? [:]
        recentlyReadBookIDs = try values.decodeIfPresent([Book.ID].self, forKey: .recentlyReadBookIDs)
            ?? Array(readingProgressByBookID.keys)
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(displayName, forKey: .displayName)
        try values.encode(email, forKey: .email)
        try values.encodeIfPresent(avatarData, forKey: .avatarData)
        try values.encode(libraryBookIDs, forKey: .libraryBookIDs)
        try values.encode(readingProgressByBookID, forKey: .readingProgressByBookID)
        try values.encode(recentlyReadBookIDs, forKey: .recentlyReadBookIDs)
    }

    static let preview = VerseUser(
        id: "preview-reader",
        displayName: "Adams Imuekemhe",
        email: "adamsimuekemhe@gmail.com",
        avatarData: nil,
        libraryBookIDs: Set(BookCatalog.libraryStarterBooks.map(\.id)),
        readingProgressByBookID: [
            "fire-weather": 2,
            "dream-count": 2,
            "atmosphere": 3,
            "martyr": 4,
            "north-woods": 2,
            "birnam-wood": 4,
            "fourth-wing": 1
        ],
        recentlyReadBookIDs: ["dream-count", "atmosphere", "martyr"]
    )
}
