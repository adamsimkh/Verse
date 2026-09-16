import SwiftUI

struct SearchView: View {
    var books: [Book] = BookCatalog.allBooks
    var onSelectBook: (Book.ID) -> Void = { _ in }

    @State private var query = ""
    @State private var topBlurOpacity = 0.0

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    private var displayedBooks: [Book] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return books }

        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(trimmedQuery)
                || book.author.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Search")
                        .font(VerseTypography.brandWordmark)
                        .foregroundStyle(VerseColors.textMain)

                    searchField
                        .padding(.top, 32)

                    Text(query.isEmpty ? "Explore books" : "Results")
                        .font(VerseTypography.sectionTitle)
                        .foregroundStyle(VerseColors.textMain)
                        .padding(.top, 36)

                    if displayedBooks.isEmpty {
                        emptyResults
                            .padding(.top, 76)
                    } else {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 38) {
                            ForEach(displayedBooks) { book in
                                SearchBookCard(book: book) {
                                    onSelectBook(book.id)
                                }
                            }
                        }
                        .padding(.top, 28)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 6)
                .padding(.bottom, 118)
            }
            .scrollDismissesKeyboard(.interactively)
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
        .accessibilityIdentifier("search-view")
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(VerseColors.secondaryText)

            TextField("Search by title or author", text: $query)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(VerseColors.textMain)
                .tint(VerseColors.primaryAction)
                .submitLabel(.search)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(VerseColors.secondaryText.opacity(0.72))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 17)
        .frame(height: 50)
        .background(VerseColors.background.opacity(0.78), in: Capsule())
        .overlay {
            Capsule()
                .stroke(VerseColors.buttonBorder, lineWidth: 1)
        }
    }

    private var emptyResults: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)

            Text("No books found")
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(VerseColors.textMain)

            Text("Try a different title or author.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SearchBookCard: View {
    let book: Book
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { geometry in
                    BookCoverArtwork(book: book)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .aspectRatio(1, contentMode: .fit)

                Text(book.title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(VerseColors.textMain)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.top, 13)

                Text(book.author)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                    .lineLimit(1)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SearchBookButtonStyle())
        .accessibilityLabel("\(book.title) by \(book.author)")
        .accessibilityHint("Opens book details")
    }
}

private struct SearchBookButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    SearchView()
}
