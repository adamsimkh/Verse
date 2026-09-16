//
//  SplashView.swift
//  Verse
//

import SwiftUI

struct SplashView: View {
    @State private var viewModel: SplashViewModel

    init(onComplete: @escaping () -> Void) {
        _viewModel = State(initialValue: SplashViewModel(onComplete: onComplete))
    }

    var body: some View {
        ZStack {
            VerseColors.background
                .ignoresSafeArea()

            VerseWordmark()
                .opacity(viewModel.logoOpacity)
                .scaleEffect(viewModel.logoScale)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
