//
//  RootView.swift
//  Verse
//

import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $viewModel.path) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .bookDetail(let bookID):
                        BookDetailView(
                            book: BookCatalog.book(withID: bookID) ?? BookCatalog.fireWeather,
                            onReadNow: { viewModel.showReader(id: bookID) }
                        )
                    case .reader(let bookID):
                        ReaderView(book: BookCatalog.book(withID: bookID) ?? BookCatalog.fireWeather)
                    }
                }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        Group {
            switch viewModel.phase {
            case .splash:
                SplashView(onComplete: viewModel.finishSplash)
                    .transition(.opacity)
            case .authentication:
                AuthenticationView(onAuthenticated: viewModel.finishAuthentication)
                    .transition(.opacity)
            case .userType:
                UserTypeView(
                    onBack: viewModel.returnToAuthentication,
                    onSkip: viewModel.finishUserType,
                    onContinue: viewModel.finishUserType
                )
                    .transition(.opacity)
            case .main:
                MainTabView(onSelectBook: viewModel.showBook)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: RootViewModel.phaseTransitionDuration), value: viewModel.phase)
    }
}

#Preview {
    RootView()
}
