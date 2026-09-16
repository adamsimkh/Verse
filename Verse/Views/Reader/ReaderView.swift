import Foundation
import SwiftUI

struct ReaderView: View {
    let book: Book
    var onChapterChanged: (Int) -> Void

    private enum ChapterSelectorStyle {
        // Full and scrolled-down pill sizes.
        static let regularWidth: CGFloat = 136
        static let regularHeight: CGFloat = 52
        static let regularFontSize: CGFloat = 20
        static let compactWidth: CGFloat = 120
        static let compactHeight: CGFloat = 36
        static let compactFontSize: CGFloat = 17
        static let shrinkScrollDistance: CGFloat = 84
        static let maximumExpandedHeight: CGFloat = 340
        static let estimatedChapterRowHeight: CGFloat = 84
        static let openingResponse: CGFloat = 0.46
        static let closingResponse: CGFloat = 0.34
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedChapterID: Int
    @State private var isChapterPickerExpanded = false
    @State private var chapterPickerExpansion: CGFloat = 0
    @State private var chapterPickerCloseWorkItem: DispatchWorkItem?
    @State private var scrollOffset = 0.0
    @Namespace private var chapterSelectorNamespace
    @Namespace private var chapterSelectorGlassNamespace

    init(
        book: Book,
        initialChapterID: Int = 1,
        onChapterChanged: @escaping (Int) -> Void = { _ in }
    ) {
        self.book = book
        self.onChapterChanged = onChapterChanged
        _selectedChapterID = State(initialValue: initialChapterID)
    }

    private var chapters: [BookChapter] {
        BookReaderCatalog.chapters(for: book)
    }

    private var selectedChapter: BookChapter {
        chapters.first(where: { $0.id == selectedChapterID }) ?? chapters[0]
    }

    private var selectorCompactProgress: CGFloat {
        min(max(CGFloat(scrollOffset) / ChapterSelectorStyle.shrinkScrollDistance, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .top) {
            VerseColors.background
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                readerContent
                    .padding(.horizontal, 22)
                    .padding(.top, 80)
                    .padding(.bottom, 110)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y + geometry.contentInsets.top)
            } action: { _, offset in
                scrollOffset = offset
            }
            .id(selectedChapterID)

            ScrollEdgeBlur(opacity: min(scrollOffset / 28, 1))

            readerHeader
                .zIndex(1)

            if isChapterPickerExpanded {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { closeChapterPicker() }
                    .zIndex(1.5)
            }

            chapterSelector
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, 22)
                .zIndex(2)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var readerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Chapter \(selectedChapter.number)")
                .font(Font.custom("Lora", size: 30, relativeTo: .title).weight(.medium))
                .foregroundStyle(VerseColors.textMain)

            Text(selectedChapter.subtitle)
                .font(Font.custom("Lora", size: 21, relativeTo: .title2).weight(.regular))
                .foregroundStyle(VerseColors.textMain)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 30) {
                ForEach(selectedChapter.paragraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(VerseColors.storyText)
                        .lineSpacing(7)
                }
            }
            .padding(.top, 32)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var readerHeader: some View {
        ZStack {
            Text(book.title)
                .font(Font.custom("Lora", size: 24, relativeTo: .title2).weight(.medium))
                .foregroundStyle(VerseColors.textMain)

            HStack {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(VerseColors.textMain)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 6)
    }

    private var chapterSelector: some View {
        GlassEffectContainer(spacing: 24) {
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    if isChapterPickerExpanded {
                        ScrollView(.vertical, showsIndicators: chapters.count > 4) {
                            ChapterPicker(
                                chapters: chapters,
                                selectedChapterID: selectedChapterID,
                                namespace: chapterSelectorNamespace,
                                onSelect: { chapter in
                                    selectedChapterID = chapter.id
                                    onChapterChanged(chapter.id)
                                    scrollOffset = 0
                                    closeChapterPicker()
                                }
                            )
                            .padding(.horizontal, 24)
                        }
                        .scrollDisabled(chapters.count <= 4)
                        .scrollBounceBehavior(.basedOnSize)
                    } else {
                        Button(action: openChapterPicker) {
                            Text("Chapter \(selectedChapter.number)")
                                .font(.system(size: selectorFontSize, weight: .regular))
                                .foregroundStyle(VerseColors.textMain)
                                .matchedGeometryEffect(
                                    id: "selected-chapter-label",
                                    in: chapterSelectorNamespace
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(ReaderSelectorButtonStyle())
                        .accessibilityLabel("Choose chapter")
                        .accessibilityValue("Chapter \(selectedChapter.number)")
                    }
                }
                .frame(
                    width: interpolated(from: selectorWidth, to: proxy.size.width),
                    height: interpolated(from: selectorHeight, to: expandedPickerHeight),
                    alignment: .topLeading
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: interpolated(from: selectorHeight / 2, to: 32),
                        style: .continuous
                    )
                )
                .glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(
                        cornerRadius: interpolated(from: selectorHeight / 2, to: 32),
                        style: .continuous
                    )
                )
                .glassEffectID("chapter-selector", in: chapterSelectorGlassNamespace)
                .glassEffectTransition(.matchedGeometry)
                .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
    }

    private func openChapterPicker() {
        chapterPickerCloseWorkItem?.cancel()
        chapterPickerCloseWorkItem = nil
        isChapterPickerExpanded = true

        withAnimation(.spring(response: ChapterSelectorStyle.openingResponse, dampingFraction: 0.84)) {
            chapterPickerExpansion = 1
        }
    }

    private func closeChapterPicker() {
        withAnimation(.spring(response: ChapterSelectorStyle.closingResponse, dampingFraction: 0.90)) {
            chapterPickerExpansion = 0
        }

        chapterPickerCloseWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            isChapterPickerExpanded = false
        }
        chapterPickerCloseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26, execute: workItem)
    }

    private func interpolated(from start: CGFloat, to end: CGFloat) -> CGFloat {
        start + ((end - start) * chapterPickerExpansion)
    }

    private var expandedPickerHeight: CGFloat {
        let dividerHeight = CGFloat(max(chapters.count - 1, 0))
        let contentHeight = (CGFloat(chapters.count) * ChapterSelectorStyle.estimatedChapterRowHeight) + dividerHeight + 1
        return min(
            max(contentHeight, selectorHeight),
            ChapterSelectorStyle.maximumExpandedHeight
        )
    }

    private var selectorWidth: CGFloat {
        ChapterSelectorStyle.regularWidth
            + ((ChapterSelectorStyle.compactWidth - ChapterSelectorStyle.regularWidth) * selectorCompactProgress)
    }

    private var selectorHeight: CGFloat {
        ChapterSelectorStyle.regularHeight
            + ((ChapterSelectorStyle.compactHeight - ChapterSelectorStyle.regularHeight) * selectorCompactProgress)
    }

    private var selectorFontSize: CGFloat {
        ChapterSelectorStyle.regularFontSize
            + ((ChapterSelectorStyle.compactFontSize - ChapterSelectorStyle.regularFontSize) * selectorCompactProgress)
    }
}

#Preview {
    ReaderView(book: BookCatalog.fireWeather)
}

private struct ChapterPicker: View {
    let chapters: [BookChapter]
    let selectedChapterID: Int
    let namespace: Namespace.ID
    let onSelect: (BookChapter) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(chapters) { chapter in
                let isSelected = chapter.id == selectedChapterID

                Button {
                    onSelect(chapter)
                } label: {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Chapter \(chapter.number)")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(
                                isSelected
                                    ? VerseColors.secondaryText.opacity(0.48)
                                    : VerseColors.textMain
                            )
                            .matchedGeometryEffect(
                                id: isSelected ? "selected-chapter-label" : "chapter-\(chapter.id)",
                                in: namespace
                            )

                        Text(chapter.subtitle)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(
                                VerseColors.secondaryText.opacity(isSelected ? 0.48 : 1)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 17)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ReaderChapterRowStyle())
                .disabled(isSelected)
                .accessibilityAddTraits(isSelected ? .isSelected : [])

                if chapter.id != chapters.last?.id {
                    Divider()
                        .overlay(VerseColors.buttonBorder.opacity(0.8))
                }
            }
        }
    }
}

private struct ReaderSelectorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct ReaderChapterRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.68 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1, anchor: .leading)
            .animation(.spring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
