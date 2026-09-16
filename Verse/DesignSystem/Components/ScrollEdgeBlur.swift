import SwiftUI

/// A frosted top edge that fades in as scrollable content moves underneath it.
struct ScrollEdgeBlur: View {
    let opacity: Double
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .frame(height: 180)
            .overlay {
                (colorScheme == .dark ? Color.black : Color.white)
                    .opacity(colorScheme == .dark ? 0.68 : 0.10)
            }
            .mask {
                LinearGradient(
                    colors: [.black, .black.opacity(0.86), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .opacity(opacity)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
    }
}
