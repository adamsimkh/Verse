import SwiftUI

struct LibraryView: View {
    let books: [Book]
    var progressText: (Book) -> String = { "In progress · \($0.progress ?? "0%")" }
    var onOpenReader: (Book.ID) -> Void = { _ in }
    var onViewBookDetails: (Book.ID) -> Void = { _ in }
    var onRemoveFromLibrary: (Book.ID) -> Void = { _ in }

    @State private var topBlurOpacity = 0.0
    @State private var selectedSort = LibrarySort.recentlyAdded

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    if books.isEmpty {
                        emptyLibrary
                            .padding(.top, 112)
                    } else {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 42) {
                            ForEach(Array(sortedBooks.enumerated()), id: \.element.id) { index, book in
                                LibraryBookCard(
                                    book: book,
                                    progressText: progressText(book),
                                    onOpenReader: { onOpenReader(book.id) },
                                    onViewBookDetails: { onViewBookDetails(book.id) },
                                    onRemoveFromLibrary: { onRemoveFromLibrary(book.id) }
                                )
                            }
                        }
                        .padding(.top, 44)
                    }
                }
                .padding(.horizontal, LibraryMetrics.horizontalPadding)
                .padding(.top, 6)
                .padding(.bottom, 118)
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
            Text("Library")
                .font(Font.custom("Lora", size: 34, relativeTo: .largeTitle).weight(.medium))
                .foregroundStyle(VerseColors.textMain)

            Spacer()

            sortMenu
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(LibrarySort.allCases) { sort in
                let isSelected = sort == selectedSort

                Button {
                    selectedSort = sort
                } label: {
                    HStack {
                        Text(sort.title)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .disabled(isSelected)
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(VerseColors.textMain)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Sort library")
        .accessibilityValue(selectedSort.title)
    }

    private var sortedBooks: [Book] {
        switch selectedSort {
        case .recentlyAdded:
            books
        case .title:
            books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .progress:
            books.sorted { progressValue(for: $0) > progressValue(for: $1) }
        }
    }

    private func progressValue(for book: Book) -> Int {
        Int(progressText(book).filter(\.isNumber)) ?? 0
    }

    private var emptyLibrary: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)

            Text("Your library is waiting")
                .font(VerseTypography.sectionTitle)
                .foregroundStyle(VerseColors.textMain)

            Text("Add a book from its details page to keep it here.")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private enum LibraryMetrics {
    static let horizontalPadding: CGFloat = 22
}

private enum LibrarySort: CaseIterable, Identifiable {
    case recentlyAdded
    case title
    case progress

    var id: Self { self }

    var title: String {
        switch self {
        case .recentlyAdded:
            "Recently added"
        case .title:
            "Title A–Z"
        case .progress:
            "Reading progress"
        }
    }
}

private struct LibraryBookCard: View {
    let book: Book
    let progressText: String
    let onOpenReader: () -> Void
    let onViewBookDetails: () -> Void
    let onRemoveFromLibrary: () -> Void

    var body: some View {
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

                        Button(role: .destructive, action: onRemoveFromLibrary) {
                            Label("Remove from library", systemImage: "trash")
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

            Text(progressText)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
                .lineLimit(1)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            onOpenReader()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(book.title), \(progressText)")
        .accessibilityHint("Double tap to resume reading. Press and hold the cover for book options.")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    LibraryView(books: BookCatalog.libraryStarterBooks)
}
