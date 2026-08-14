//
//  HomeView.swift
//  Verse
//

import SwiftUI

struct HomeView: View {
    var onProfileTap: () -> Void = {}
    var onSelectBook: (Book.ID) -> Void = { _ in }

    @State private var topBlurOpacity = 0.0

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.horizontal, HomeMetrics.horizontalPadding)
                        .padding(.top, 6)

                    BookShelf(
                        title: "Continue Reading",
                        books: BookCatalog.continueReading,
                        showsProgress: true,
                        onSelectBook: onSelectBook
                    )
                    .padding(.top, 44)

                    BookShelf(
                        title: "Trending Now",
                        books: BookCatalog.trending,
                        showsProgress: false,
                        onSelectBook: onSelectBook
                    )
                    .padding(.top, 44)

                    BookShelf(
                        title: "For You",
                        books: BookCatalog.forYou,
                        showsProgress: false,
                        onSelectBook: onSelectBook
                    )
                    .padding(.top, 44)
                }
                .padding(.bottom, 112)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                withAnimation(.easeOut(duration: 0.18)) {
                    topBlurOpacity = min(offset / 28, 1)
                }
            }

            ScrollEdgeBlur(opacity: topBlurOpacity)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Verse.")
                .font(VerseTypography.brandWordmark)
                .foregroundStyle(VerseColors.textMain)

            Spacer()

            Button(action: onProfileTap) {
                Image("ProfileAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.72), lineWidth: 1)
                    }
            }
            .buttonStyle(HomePressButtonStyle())
            .accessibilityLabel("Profile")
        }
    }
}

#Preview {
    HomeView()
}

private enum HomeMetrics {
    static let horizontalPadding: CGFloat = 22
    static let coverSize: CGFloat = 155
}

private struct BookShelf: View {
    let title: String
    let books: [Book]
    let showsProgress: Bool
    let onSelectBook: (Book.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            Button(action: {}) {
                HStack(spacing: 10) {
                    Text(title)
                        .font(VerseTypography.sectionTitle)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(VerseColors.secondaryText)
                }
                .foregroundStyle(VerseColors.textMain)
            }
            .buttonStyle(HomePressButtonStyle())
            .padding(.horizontal, HomeMetrics.horizontalPadding)
            .accessibilityLabel("See all \(title)")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(books) { book in
                        BookCard(book: book, showsProgress: showsProgress, onSelect: onSelectBook)
                    }
                }
                .padding(.horizontal, HomeMetrics.horizontalPadding)
            }
        }
    }
}

private struct BookCard: View {
    let book: Book
    let showsProgress: Bool
    let onSelect: (Book.ID) -> Void

    var body: some View {
        Button(action: { onSelect(book.id) }) {
            VStack(alignment: .leading, spacing: 0) {
                cover
                    .frame(width: HomeMetrics.coverSize, height: HomeMetrics.coverSize)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Text(book.title)
                    .font(.system(size: 19, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.top, 15)

                Text(showsProgress ? (book.progress ?? "") : book.author)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                    .lineLimit(1)
                    .padding(.top, 6)
            }
            .frame(width: HomeMetrics.coverSize, alignment: .leading)
            .foregroundStyle(VerseColors.textMain)
            .contentShape(Rectangle())
        }
        .buttonStyle(HomePressButtonStyle())
        .accessibilityLabel(book.title)
    }

    @ViewBuilder
    private var cover: some View {
        if let imageName = book.coverAssetName {
            Image(imageName)
                .resizable()
                .scaledToFill()
        } else {
            PlaceholderCover(book: book)
        }
    }
}

private struct PlaceholderCover: View {
    let book: Book

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: coverColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Text(book.coverTitle)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .lineLimit(2)
                .padding(16)
        }
    }

    private var coverColors: [Color] {
        switch book.id {
        case "martyr": [.black, .gray]
        case "shadows": [.brown, .black]
        case "north-woods": [.cyan, .blue]
        default: [.red.opacity(0.85), .black]
        }
    }
}

private struct HomePressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
