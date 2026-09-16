//
//  VerseWordmark.swift
//  Verse
//

import SwiftUI

struct VerseWordmark: View {
    var body: some View {
        Text("Verse.")
            .font(VerseTypography.brandWordmark)
            .foregroundStyle(VerseColors.textMain)
    }
}

#Preview {
    ZStack {
        VerseColors.background.ignoresSafeArea()
        VerseWordmark()
    }
}
