//
//  AuthenticationView.swift
//  Verse
//

import SwiftUI

struct AuthenticationView: View {
    var onAuthenticated: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VerseColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: min(max(proxy.size.height * 0.525, 420), 460))

                    VerseWordmark()

                    Text("Discover stories, read beautifully, and share\nyour own")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundStyle(VerseColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.top, 15)

                    VStack(spacing: 20) {
                        AuthenticationButton(title: "Continue with Apple", icon: .apple) {
                            onAuthenticated()
                        }

                        AuthenticationButton(title: "Continue with Google", icon: .google) {
                            onAuthenticated()
                        }
                    }
                    .padding(.top, 43)
                    .padding(.horizontal, 24)

                    TermsNotice()
                        .padding(.top, 46)

                    Spacer(minLength: 0)
                }

                StoryCollage()
                    .frame(height: min(proxy.size.height * 0.55, 475))
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    AuthenticationView(onAuthenticated: {})
}

private struct StoryCollage: View {
    @State private var dragOffsets: [String: CGSize] = [:]
    @State private var activeTileID: String?
    @State private var dragStartOffset = CGSize.zero

    private static let tileWidth: CGFloat = 450

    private static let tiles: [StoryTileDefinition] = [
        .init("StoryTile7", heightRatio: 476.0 / 1408.0, verticalOffset: 0, entryDirection: 1, settledOffset: 34, rotationDegrees: 6, delayRange: 0.05 ... 0.25, durationRange: 1.6 ... 4.0, layer: 0),
        .init("StoryTile1", heightRatio: 364.0 / 1408.0, verticalOffset: 20, entryDirection: -1, settledOffset: 104, rotationDegrees: -5, delayRange: 0.1 ... 0.4, durationRange: 1.0 ... 4.6, layer: 1),
        .init("StoryTile2", heightRatio: 364.0 / 1408.0, verticalOffset: 120, entryDirection: 1, settledOffset: -14, rotationDegrees: 7, delayRange: 0.08 ... 0.3, durationRange: 1.6 ... 4.0, layer: 2),
        .init("StoryTile3", heightRatio: 240.0 / 1408.0, verticalOffset: 182, entryDirection: -1, settledOffset: 40, rotationDegrees: -4, delayRange: 0.1 ... 0.5, durationRange: 1.4 ... 4.2, layer: 3),
        .init("StoryTile6", heightRatio: 476.0 / 1408.0, verticalOffset: 240, entryDirection: 1, settledOffset: 28, rotationDegrees: -11, delayRange: 0.05 ... 0.45, durationRange: 1.0 ... 4.6, layer: 4),
        .init("StoryTile4", heightRatio: 476.0 / 1408.0, verticalOffset: 296, entryDirection: -1, settledOffset: -151, rotationDegrees: 11, delayRange: 0.1 ... 0.25, durationRange: 1.1 ... 4.8, layer: 5),
        .init("StoryTile5", heightRatio: 476.0 / 1408.0, verticalOffset: 368, entryDirection: 1, settledOffset: 48, rotationDegrees: -18, delayRange: 0.2 ... 0.5, durationRange: 1.7 ... 6.2, layer: 6)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ForEach(Self.tiles) { tile in
                    AnimatedStoryTile(
                        tile: tile,
                        tileWidth: Self.tileWidth,
                        entryOffset: proxy.size.width * tile.entryDirection * 1.25,
                        dragOffset: dragOffsets[tile.id] ?? .zero
                    )
                    .opacity(tile.id == "StoryTile5" ? 0.62 : 1)
                    .zIndex(activeTileID == tile.id ? 100 : tile.layer)
                }
            }
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.66),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .contentShape(Rectangle())
                    .coordinateSpace(name: "storyCollage")
                    .highPriorityGesture(dragGesture(in: proxy.size))
            }
        }
        .accessibilityHidden(true)
    }

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("storyCollage"))
            .onChanged { value in
                if activeTileID == nil {
                    guard let tile = tile(at: value.startLocation, in: size) else { return }
                    activeTileID = tile.id
                    dragStartOffset = dragOffsets[tile.id] ?? .zero
                }

                guard let activeTileID else { return }
                var transaction = Transaction()
                transaction.animation = nil

                withTransaction(transaction) {
                    dragOffsets[activeTileID] = CGSize(
                        width: dragStartOffset.width + value.translation.width,
                        height: dragStartOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                var transaction = Transaction()
                transaction.animation = nil

                withTransaction(transaction) {
                    activeTileID = nil
                }
            }
    }

    private func tile(at location: CGPoint, in size: CGSize) -> StoryTileDefinition? {
        Self.tiles.min {
            selectionScore(for: location, tile: $0, size: size) <
            selectionScore(for: location, tile: $1, size: size)
        }
    }

    private func selectionScore(for location: CGPoint, tile: StoryTileDefinition, size: CGSize) -> CGFloat {
        let height = Self.tileWidth * tile.heightRatio
        let dragOffset = dragOffsets[tile.id] ?? .zero
        let centerY = tile.verticalOffset + height / 2 + dragOffset.height
        let centerX = size.width / 2 + tile.settledOffset + dragOffset.width

        // Vertical placement identifies the card; horizontal position only breaks ties.
        return abs(location.y - centerY) * 10 + abs(location.x - centerX)
    }
}

private struct StoryTileDefinition: Identifiable {
    let id: String
    let heightRatio: CGFloat
    let verticalOffset: CGFloat
    let entryDirection: CGFloat
    let settledOffset: CGFloat
    let rotationDegrees: Double
    let delayRange: ClosedRange<Double>
    let durationRange: ClosedRange<Double>
    let layer: Double

    init(
        _ id: String,
        heightRatio: CGFloat,
        verticalOffset: CGFloat,
        entryDirection: CGFloat,
        settledOffset: CGFloat,
        rotationDegrees: Double,
        delayRange: ClosedRange<Double>,
        durationRange: ClosedRange<Double>,
        layer: Double
    ) {
        self.id = id
        self.heightRatio = heightRatio
        self.verticalOffset = verticalOffset
        self.entryDirection = entryDirection
        self.settledOffset = settledOffset
        self.rotationDegrees = rotationDegrees
        self.delayRange = delayRange
        self.durationRange = durationRange
        self.layer = layer
    }
}

private struct AnimatedStoryTile: View {
    let tile: StoryTileDefinition
    let tileWidth: CGFloat
    let entryOffset: CGFloat
    let dragOffset: CGSize

    @State private var horizontalOffset: CGFloat

    init(
        tile: StoryTileDefinition,
        tileWidth: CGFloat,
        entryOffset: CGFloat,
        dragOffset: CGSize
    ) {
        self.tile = tile
        self.tileWidth = tileWidth
        self.entryOffset = entryOffset
        self.dragOffset = dragOffset
        _horizontalOffset = State(initialValue: entryOffset)
    }

    var body: some View {
        Image(tile.id)
            .resizable()
            .scaledToFit()
            .frame(width: tileWidth)
            .rotationEffect(.degrees(tile.rotationDegrees))
            .offset(
                x: horizontalOffset + dragOffset.width,
                y: tile.verticalOffset + dragOffset.height
            )
            .task {
                await animateAcrossScreen()
            }
            .allowsHitTesting(false)
    }

    private func animateAcrossScreen() async {
        let initialDelay = Double.random(in: tile.delayRange)
        let animationDuration = Double.random(in: tile.durationRange)

        try? await Task.sleep(nanoseconds: UInt64(initialDelay * 1_000_000_000))

        guard !Task.isCancelled else { return }

        await MainActor.run {
            withAnimation(.easeInOut(duration: animationDuration)) {
                horizontalOffset = tile.settledOffset
            }
        }
    }
}

private struct AuthenticationButton: View {
    enum Icon {
        case apple
        case google
    }

    let title: String
    let icon: Icon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Group {
                    switch icon {
                    case .apple:
                        Image(systemName: "apple.logo")
                            .font(.system(size: 25, weight: .medium))
                    case .google:
                        Image("GoogleG")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                }
                .frame(width: 31, height: 31)

                Text(title)
                    .font(.system(size: 18, weight: .medium))
            }
            .foregroundStyle(VerseColors.textMain)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .contentShape(Capsule())
        }
        .buttonStyle(AuthenticationButtonStyle())
        .accessibilityLabel(title)
    }
}

private struct AuthenticationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(VerseColors.background, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(VerseColors.buttonBorder, lineWidth: 1.5)
            }
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct TermsNotice: View {
    var body: some View {
        VStack(spacing: 7) {
            Text("By continuing, you agree to our")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(VerseColors.secondaryText)

            HStack(spacing: 5) {
                Button("Terms & Conditions") {}
                Text("and").foregroundStyle(VerseColors.secondaryText)
                Button("Privacy Policy") {}
            }
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(VerseColors.legalLink)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}
