import SwiftUI

/// A frosted top edge that fades in as scrollable content moves underneath it.
struct ScrollEdgeBlur: View {
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(.regularMaterial)
            .frame(height: 180)
            .overlay {
                Color.white.opacity(0.10)
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
