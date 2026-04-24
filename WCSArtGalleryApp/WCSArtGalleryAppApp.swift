//
//  WCSArtGalleryAppApp.swift
//  WCSArtGalleryApp
//
//  Created by Christopher Appiah-Thompson  on 24/4/2026.
//

import SwiftUI

@main
struct WCSArtGalleryAppApp: App {
    init() {
        WCSStudioAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
