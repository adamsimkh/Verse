//
//  SplashViewModel.swift
//  Verse
//

import SwiftUI

@Observable
@MainActor
final class SplashViewModel {
    var logoOpacity: Double = 0
    var logoScale: CGFloat = 0.98

    private let onComplete: () -> Void

    private static let fadeInDuration: TimeInterval = 0.5
    private static let displayDuration: Duration = .milliseconds(1500)

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    func start() async {
        withAnimation(.easeOut(duration: Self.fadeInDuration)) {
            logoOpacity = 1
            logoScale = 1
        }

        try? await Task.sleep(for: Self.displayDuration)
        onComplete()
    }
}
