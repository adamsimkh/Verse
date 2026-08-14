import SwiftUI

struct ReaderView: View {
    let book: Book

    private enum ChapterSelectorStyle {
        // Full and scrolled-down pill sizes.
        static let regularWidth: CGFloat = 152
        static let regularHeight: CGFloat = 52
        static let regularFontSize: CGFloat = 20
        static let compactWidth: CGFloat = 124
        static let compactHeight: CGFloat = 40
        static let compactFontSize: CGFloat = 17
        static let shrinkScrollDistance: CGFloat = 84

        // Lower durations make the open/close spring faster.
        static let openingDuration: CGFloat = 0.38
        static let openingBounce: CGFloat = 0.10
        static let closingDuration: CGFloat = 0.32
        static let closingBounce: CGFloat = 0.04
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedChapterID = ReaderChapter.defaultChapterID
    @State private var isChapterPickerExpanded = false
    @State private var chapterPickerExpansion: CGFloat = 0
    @State private var scrollOffset = 0.0
    @Namespace private var chapterSelectorNamespace

    private var selectedChapter: ReaderChapter {
        ReaderChapter.chapter(withID: selectedChapterID) ?? ReaderChapter.defaultChapter
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
                    .onTapGesture {
                        closeChapterPicker()
                    }
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

    @ViewBuilder
    private var chapterSelector: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if isChapterPickerExpanded {
                    ChapterPicker(
                        chapters: ReaderChapter.all,
                        selectedChapterID: selectedChapterID,
                        namespace: chapterSelectorNamespace,
                        onSelect: { chapter in
                            selectedChapterID = chapter.id
                            scrollOffset = 0
                            closeChapterPicker()
                        }
                    )
                    .padding(.horizontal, 24)
                } else {
                    Button {
                        openChapterPicker()
                    } label: {
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
                height: interpolated(from: selectorHeight, to: 340),
                alignment: .topLeading
            )
            .background {
                RoundedRectangle(
                    cornerRadius: interpolated(from: selectorHeight / 2, to: 32),
                    style: .continuous
                )
                .fill(.clear)
                .glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(
                        cornerRadius: interpolated(from: selectorHeight / 2, to: 32),
                        style: .continuous
                    )
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: interpolated(from: selectorHeight / 2, to: 32),
                    style: .continuous
                )
            )
            .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func openChapterPicker() {
        withAnimation(
            .interactiveSpring(
                duration: ChapterSelectorStyle.openingDuration,
                extraBounce: ChapterSelectorStyle.openingBounce
            )
        ) {
            isChapterPickerExpanded = true
            chapterPickerExpansion = 1
        }
    }

    private func closeChapterPicker() {
        withAnimation(
            .interactiveSpring(
                duration: ChapterSelectorStyle.closingDuration,
                extraBounce: ChapterSelectorStyle.closingBounce
            )
        ) {
            isChapterPickerExpanded = false
            chapterPickerExpansion = 0
        }
    }

    private func interpolated(from start: CGFloat, to end: CGFloat) -> CGFloat {
        start + ((end - start) * chapterPickerExpansion)
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
    let chapters: [ReaderChapter]
    let selectedChapterID: Int
    let namespace: Namespace.ID
    let onSelect: (ReaderChapter) -> Void

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
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.84 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct ReaderChapterRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.56 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1, anchor: .leading)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct ReaderChapter: Identifiable {
    let number: Int
    let subtitle: String
    let paragraphs: [String]

    var id: Int { number }

    static let defaultChapterID = 3

    static let defaultChapter = ReaderChapter(
        number: 3,
        subtitle: "Into the Emberlands",
        paragraphs: ["Placeholder"]
    )

    static let all: [ReaderChapter] = [
        ReaderChapter(
            number: 1,
            subtitle: "The Long Summer",
            paragraphs: [
                "By noon, the heat had settled over the valley like a second roof. Every window stood open, but the air inside the houses did not move. On the ridge, a line of dry grass leaned in the same direction, waiting for a wind that had not yet arrived.",
                "Mara kept the weather radio beside the kitchen sink. It spoke in clipped, patient sentences about pressure, humidity, and the small arithmetic of danger. Outside, the river ran low between pale stones, carrying leaves farther than it carried water.",
                "No one called the season unusual at first. They called it bright, then long, then difficult. It took weeks before anyone used the word that made the rest of the conversation go quiet."
            ]
        ),
        ReaderChapter(
            number: 2,
            subtitle: "Signals in the Smoke",
            paragraphs: [
                "The first plume appeared just after breakfast, thin enough to mistake for cloud. It rose behind the western hills and flattened in the high air, a grey mark that seemed to hover over the trees without belonging to them.",
                "At the station, the phones began to ring in uneven bursts. A hiker had seen ash on a windshield. A farmer had smelled cedar where there were no cedar trees. Each report was small on its own, but together they formed a message no one wanted to translate.",
                "By dusk, the horizon had turned the colour of old brass. The town switched on its porch lights early, not because night had come, but because the day had become hard to see through."
            ]
        ),
        ReaderChapter(
            number: 3,
            subtitle: "Into the Emberlands",
            paragraphs: [
                "A dry wind pushed through the valley, carrying with it the faint smell of smoke. John paused, listening to the distant crackle rising like a warning. The sound was subtle, almost polite, but it threaded itself through the silence with intent.",
                "The forest around him was still — too still. Even the birds had gone quiet, as if they sensed what the coming hours would bring. Leaves hung motionless on their branches, brittle from weeks without rain, and the ground beneath his boots felt powdery, ready to ignite at the slightest provocation.",
                "He tightened his grip on the map, tracing the ridge line that separated safety from danger. On paper, it was just a contour — a thin, looping promise of elevation. In reality, it marked the point where containment ended and uncertainty began.",
                "John had walked this land before, years earlier, when the trees were greener and the rivers still ran cold. Back then, fire was an exception — a seasonal threat, not a constant presence. Now it lingered everywhere, woven into the landscape like a second weather system.",
                "A gust swept through the valley, stronger this time, lifting ash from somewhere unseen. It settled on his jacket, gray against the fabric, warm to the touch. He brushed it away instinctively, then stopped. There would be no point in keeping clean today.",
                "Ahead, the sky darkened slightly, not with clouds, but with something heavier — smoke layered upon smoke, stacked in slow-moving columns. Somewhere beyond the ridge, the fire was advancing, reshaping the land with methodical patience.",
                "John took a breath and started forward. Each step felt deliberate, measured against the weight of what he knew and what he didn’t. Fire, he had learned, was never just destruction. It was history, climate, policy, human error — all converging into a single, unstoppable force.",
                "And as he crossed the ridge and entered the emberlands, one thought remained steady in his mind: This was no longer about stopping the fire. It was about understanding what it had already changed."
            ]
        ),
        ReaderChapter(
            number: 4,
            subtitle: "When the Wind Turns",
            paragraphs: [
                "At first, the change was almost impossible to notice. A cool thread moved through the smoke, then another, and the trees began to whisper in a direction they had ignored all day. John watched the ash lift from the road and travel east.",
                "The map no longer felt like a promise. Its lines described the land as it had been measured, not as it was changing. Creeks had become boundaries, boundaries had become routes, and every route seemed to lead toward a decision made too late.",
                "When the wind finally turned in earnest, the sound of the fire changed with it. The valley drew one long breath. Then the hills answered."
            ]
        )
    ]

    static func chapter(withID id: Int) -> ReaderChapter? {
        all.first { $0.id == id }
    }
}
