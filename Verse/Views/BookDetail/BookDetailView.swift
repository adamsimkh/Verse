//
//  BookDetailView.swift
//  Verse
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    var isInLibrary = false
    var onReadNow: () -> Void = {}
    var onToggleLibrary: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var topBlurOpacity = 0.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    bookSummary

                    DetailSection(title: "Description") {
                        Text(displaySummary)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(VerseColors.secondaryText)
                            .lineSpacing(7)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 18) {
                        Button(action: onReadNow) {
                            Text("Read now")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(VerseColors.primaryActionText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                        }
                        .buttonStyle(DetailPrimaryButtonStyle())

                        Button {
                            onToggleLibrary()
                        } label: {
                            Text(isInLibrary ? "Added to library" : "Add to library")
                                .font(.system(size: 20, weight: .medium))
                                .contentTransition(.identity)
                                .animation(nil, value: isInLibrary)
                                .foregroundStyle(isInLibrary ? VerseColors.secondaryText.opacity(0.45) : VerseColors.textMain)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    isInLibrary ? VerseColors.buttonBorder.opacity(0.22) : VerseColors.background,
                                    in: Capsule()
                                )
                                .overlay {
                                    Capsule()
                                        .stroke(VerseColors.buttonBorder.opacity(isInLibrary ? 0 : 1), lineWidth: 1.5)
                                }
                        }
                        .buttonStyle(DetailSecondaryButtonStyle())
                    }
                    .padding(.top, 38)

                    DetailSection(title: "Reviews", showsChevron: true) {
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(displayReviews) { review in
                                ReviewRow(review: review)
                            }
                        }
                    }
                    .padding(.top, 58)

                    DetailSection(title: "About the Author") {
                        Text(displayAuthorBio)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(VerseColors.secondaryText)
                            .lineSpacing(7)
                    }
                    .padding(.top, 58)
                }
                .padding(.horizontal, 22)
                .padding(.top, 92)
                .padding(.bottom, 36)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                withAnimation(.easeOut(duration: 0.18)) {
                    topBlurOpacity = min(offset / 28, 1)
                }
            }

            ScrollEdgeBlur(opacity: topBlurOpacity)

            backButton
                .padding(.leading, 20)
                .padding(.top, 6)
                .zIndex(1)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backButton: some View {
        Button(action: dismiss.callAsFunction) {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(VerseColors.textMain)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Back")
    }

    private var bookSummary: some View {
        HStack(alignment: .center, spacing: 16) {
            BookCoverArtwork(book: book)
                .frame(width: 132, height: 126)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                Text(book.title)
                    .font(Font.custom("Lora", size: 26, relativeTo: .title2).weight(.medium))
                    .foregroundStyle(VerseColors.textMain)
                    .lineLimit(2)

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(VerseColors.secondaryText)
                }

                if book.rating > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(VerseColors.primaryAction)

                        Text(String(format: "%.1f", book.rating))
                        Text("(\(book.ratingCountText))")
                    }
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(VerseColors.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var displaySummary: String {
        book.summary.isEmpty ? "A featured title in the Verse library. Full book details will be available soon." : book.summary
    }

    private var displayAuthorBio: String {
        guard !book.authorBio.isEmpty else {
            return "Author information will be available soon."
        }
        return book.authorBio
    }

    private var displayReviews: [BookReview] {
        book.reviews.isEmpty ? [
            BookReview(
                id: "preview-review-\(book.id)",
                reviewer: "Verse reader",
                rating: 5,
                text: "A memorable addition to the collection."
            )
        ] : book.reviews
    }
}

#Preview {
    BookDetailView(book: BookCatalog.fireWeather)
}

private struct DetailSection<Content: View>: View {
    let title: String
    var showsChevron = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 10) {
                Text(title)
                    .font(VerseTypography.sectionTitle)
                    .foregroundStyle(VerseColors.textMain)

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(VerseColors.secondaryText)
                }
            }

            content
        }
    }
}

private struct ReviewRow: View {
    let review: BookReview

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(review.reviewer)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(VerseColors.textMain)

                HStack(spacing: 2) {
                    ForEach(0 ..< 5, id: \.self) { index in
                        Image(systemName: index < review.rating ? "star.fill" : "star")
                            .font(.system(size: 16))
                    }
                }
                .foregroundStyle(VerseColors.primaryAction)
            }

            Text("“\(review.text)”")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)
                .lineSpacing(5)
        }
    }
}

private struct DetailPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(VerseColors.primaryAction, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

private struct DetailSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.84 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
