//
//  ContentView.swift
//  WCSArtGalleryApp
//
//  Created by Christopher Appiah-Thompson  on 24/4/2026.
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GalleryViewModel()

    var body: some View {
        ZStack {
            WCSScreenBackground()
            TabView(selection: $viewModel.mainTabSelection) {
                GalleryHomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    .accessibilityIdentifier("tab_home")

                ExploreView(viewModel: viewModel)
                    .tabItem {
                        Label("Explore", systemImage: "square.grid.2x2.fill")
                    }
                    .tag(1)
                    .accessibilityIdentifier("tab_explore")

                SavedView(viewModel: viewModel)
                    .tabItem {
                        Label("Saved", systemImage: "bookmark.fill")
                    }
                    .tag(2)
                    .accessibilityIdentifier("tab_saved")

                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
                    .tag(3)
                    .accessibilityIdentifier("tab_profile")

                WCSBackendFusionTabRoot()
                    .tabItem {
                        Label("Studio", systemImage: "wand.and.stars")
                    }
                    .tag(4)
                    .accessibilityIdentifier("tab_studio")
            }
            .tint(WCSStudioTheme.accent)
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
        .environmentObject(GalleryViewModel())
}
