//
//  RootViewModel.swift
//  Verse
//

import SwiftUI

@Observable
@MainActor
final class RootViewModel {
    static let phaseTransitionDuration: TimeInterval = 0.35

    var phase: AppPhase = .splash
    var path = NavigationPath()

    func finishSplash() {
        withAnimation(.easeInOut(duration: Self.phaseTransitionDuration)) {
            phase = .authentication
        }
    }
}
