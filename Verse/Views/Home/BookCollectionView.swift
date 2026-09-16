import SwiftUI

struct BookCollectionView: View {
    let collection: HomeBookCollection
    let books: [Book]
    var progressText: (Book) -> String = { $0.progress ?? "0% Complete" }
    var isInLibrary: (Book.ID) -> Bool = { _ in false }
    var onOpenReader: (Book.ID) -> Void = { _ in }
    var onViewBookDetails: (Book.ID) -> Void = { _ in }
    var onToggleLibrary: (Book.ID) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss
    @State private var topBlurOpacity = 0.0

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                Group {
                    if books.isEmpty {
                        emptyCollection
                            .padding(.top, 142)
                    } else {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 42) {
                            ForEach(books) { book in
                                CollectionBookCard(
                                    book: book,
                                    showsProgress: collection.showsProgress,
                                    progressText: progressText(book),
                                    isInLibrary: isInLibrary(book.id),
                                    onOpen: {
                                        collection.showsProgress
                                            ? onOpenReader(book.id)
                                            : onViewBookDetails(book.id)
                                    },
                                    onViewBookDetails: { onViewBookDetails(book.id) },
                                    onToggleLibrary: { onToggleLibrary(book.id) }
                                )
                            }
                        }
                        .padding(.top, 108)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 42)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                withAnimation(.easeOut(duration: 0.18)) {
                    topBlurOpacity = min(offset / 28, 1)
                }
            }

            ScrollEdgeBlur(opacity: topBlurOpacity)
            header
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("book-collection-\(collection.title)")
    }

    private var header: some View {
        HStack(alignment: .center) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(VerseColors.textMain)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Back")

            Spacer()

            Text(collection.title)
                .font(Font.custom("Lora", size: 27, relativeTo: .title2).weight(.medium))
                .foregroundStyle(VerseColors.textMain)
                .lineLimit(1)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 22)
        .padding(.top, 6)
    }

    private var emptyCollection: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)

            Text("Nothing to continue yet")
                .font(VerseTypography.sectionTitle)
                .foregroundStyle(VerseColors.textMain)

            Text("Start reading a book and it will appear here.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CollectionBookCard: View {
    let book: Book
    let showsProgress: Bool
    let progressText: String
    let isInLibrary: Bool
    let onOpen: () -> Void
    let onViewBookDetails: () -> Void
    let onToggleLibrary: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { geometry in
                    BookCoverArtwork(book: book)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .contextMenu {
                            Button(action: onViewBookDetails) {
                                Label("View book details", systemImage: "info.circle")
                            }

                            Button(role: isInLibrary ? .destructive : nil, action: onToggleLibrary) {
                                Label(
                                    isInLibrary ? "Remove from library" : "Add to library",
                                    systemImage: isInLibrary ? "trash" : "plus"
                                )
                            }
                        }
                }
                .aspectRatio(1, contentMode: .fit)

                Text(book.title)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(VerseColors.textMain)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.top, 15)

                Text(showsProgress ? progressText : book.author)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                    .lineLimit(1)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(CollectionBookButtonStyle())
        .accessibilityLabel("\(book.title) by \(book.author)")
        .accessibilityHint("Press and hold for library options")
    }
}

private struct CollectionBookButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    BookCollectionView(collection: .trending, books: BookCatalog.trending)
}
