import SwiftUI

struct SearchView: View {
    var body: some View {
        ZStack {
            VerseColors.background
                .ignoresSafeArea()

            Text("Search")
                .font(VerseTypography.sectionTitle)
                .foregroundStyle(VerseColors.textMain)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    SearchView()
}
