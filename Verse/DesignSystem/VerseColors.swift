//
//  VerseColors.swift
//  Verse
//

import SwiftUI

enum VerseColors {
    static let background = Color("Background")
    static let textMain = Color("TextMain")
    static let secondaryText = Color("SecondaryText")
    static let storyText = Color("StoryText")
    static let buttonBorder = Color("ButtonBorder")
    static let legalLink = Color(red: 0.78, green: 0.69, blue: 0.51)
    static let primaryAction = Color(red: 0.83, green: 0.76, blue: 0.58)
    /// Primary buttons retain a dark label in both colour schemes for contrast against the warm action fill.
    static let primaryActionText = Color.black.opacity(0.86)
    static let selectionRing = Color(red: 0.92, green: 0.88, blue: 0.78)
}
