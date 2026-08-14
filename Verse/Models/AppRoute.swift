//
//  AppRoute.swift
//  Verse
//

import Foundation

enum AppRoute: Hashable {
    case bookDetail(Book.ID)
    case reader(Book.ID)
}
