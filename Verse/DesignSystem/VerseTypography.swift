//
//  VerseTypography.swift
//  Verse
//

import SwiftUI

enum VerseTypography {
    /// Lora Bold at 34pt — matches Figma splash / brand wordmark spec.
    static let brandWordmark = Font.custom("Lora", size: 34, relativeTo: .largeTitle).weight(.bold)
    static let onboardingTitle = Font.custom("Lora", size: 31, relativeTo: .title).weight(.bold)
    static let sectionTitle = Font.custom("Lora", size: 24, relativeTo: .title2).weight(.medium)
}
