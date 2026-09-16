//
//  AppRoute.swift
//  Verse
//

import Foundation

enum AppRoute: Hashable {
    case bookDetail(Book.ID)
    case reader(Book.ID)
    case profile
    case bookCollection(HomeBookCollection)
}

enum HomeBookCollection: Hashable {
    case continueReading
    case trending
    case forYou

    var title: String {
        switch self {
        case .continueReading: "Continue Reading"
        case .trending: "Trending Now"
        case .forYou: "For You"
        }
    }

    var showsProgress: Bool {
        self == .continueReading
    }
}
