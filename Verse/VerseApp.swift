//
//  VerseApp.swift
//  Verse
//
//  Created by Adams on 15/07/2026.
//

import GoogleSignIn
import SwiftUI

@main
struct VerseApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
