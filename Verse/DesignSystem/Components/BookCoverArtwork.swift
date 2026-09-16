import SwiftUI
import UIKit

struct BookCoverArtwork: View {
    let book: Book
    @State private var remoteImage: UIImage?

    var body: some View {
        if let assetName = book.coverAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else if let remoteCoverURL = book.remoteCoverURL {
            Group {
                if let remoteImage {
                    Image(uiImage: remoteImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholderCover
                }
            }
            .task(id: remoteCoverURL) {
                await loadRemoteCover(from: remoteCoverURL)
            }
        } else {
            placeholderCover
        }
    }

    @ViewBuilder
    private var placeholderCover: some View {
        ZStack {
            LinearGradient(
                colors: palette,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            coverDecoration

            Text(book.coverTitle)
                .font(.system(size: 31, weight: .black, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(titleColor)
                .minimumScaleFactor(0.58)
                .padding(18)
        }
    }

    @ViewBuilder
    private var coverDecoration: some View {
        switch book.id {
        case "north-woods":
            Circle()
                .fill(.yellow.opacity(0.45))
                .frame(width: 118)
                .offset(y: 62)
        case "birnam-wood":
            ForEach(0 ..< 6, id: \.self) { index in
                Circle()
                    .fill(.green.opacity(0.32))
                    .frame(width: 78)
                    .offset(x: CGFloat((index % 3) * 64 - 64), y: CGFloat((index / 3) * 58 + 42))
            }
        case "fourth-wing":
            Circle()
                .stroke(.black.opacity(0.78), lineWidth: 3)
                .frame(width: 154)

            Image(systemName: "bird.fill")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(.black.opacity(0.78))
                .offset(y: -53)
        case "martyr":
            Rectangle()
                .fill(.white.opacity(0.12))
                .rotationEffect(.degrees(-22))
                .scaleEffect(1.45)
        case "shadows":
            Circle()
                .fill(.black.opacity(0.34))
                .frame(width: 138)
                .offset(x: 42, y: -50)
        default:
            EmptyView()
        }
    }

    private var palette: [Color] {
        switch book.id {
        case "north-woods": [.cyan.opacity(0.74), .blue.opacity(0.75), .green.opacity(0.42)]
        case "birnam-wood": [.orange.opacity(0.78), .green.opacity(0.75), .black.opacity(0.82)]
        case "fourth-wing": [.yellow.opacity(0.38), .brown.opacity(0.22), .orange.opacity(0.28)]
        case "martyr": [.black, .gray.opacity(0.7)]
        case "shadows": [.brown.opacity(0.82), .black]
        default: fallbackPalette
        }
    }

    private var titleColor: Color {
        switch book.id {
        case "north-woods", "fourth-wing": .black
        default: fallbackTitleColor
        }
    }

    private var fallbackPalette: [Color] {
        switch fallbackStyleIndex {
        case 0: [.indigo.opacity(0.86), .purple.opacity(0.66), .black.opacity(0.82)]
        case 1: [.teal.opacity(0.82), .mint.opacity(0.64), .blue.opacity(0.64)]
        case 2: [.orange.opacity(0.84), .pink.opacity(0.70), .red.opacity(0.76)]
        case 3: [.yellow.opacity(0.72), .orange.opacity(0.62), .brown.opacity(0.60)]
        case 4: [.cyan.opacity(0.80), .blue.opacity(0.72), .indigo.opacity(0.78)]
        default: [.brown.opacity(0.78), .red.opacity(0.62), .black.opacity(0.80)]
        }
    }

    private var fallbackTitleColor: Color {
        switch fallbackStyleIndex {
        case 1, 3: .black.opacity(0.82)
        default: .white
        }
    }

    private var fallbackStyleIndex: Int {
        book.id.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 6
    }

    @MainActor
    private func loadRemoteCover(from url: URL) async {
        guard remoteImage == nil else { return }

        if let cachedImage = BookCoverCache.images.object(forKey: url as NSURL) {
            remoteImage = cachedImage
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 12

        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let downloadedImage = UIImage(data: data)
        else {
            return
        }

        BookCoverCache.images.setObject(downloadedImage, forKey: url as NSURL)
        remoteImage = downloadedImage
    }
}

private enum BookCoverCache {
    static let images = NSCache<NSURL, UIImage>()
}
