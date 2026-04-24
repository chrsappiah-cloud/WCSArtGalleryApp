//
//  WCSArtGalleryAppTests.swift
//  WCSArtGalleryAppTests
//
//  Created by Christopher Appiah-Thompson  on 24/4/2026.
//

import Foundation
import Testing
@testable import WCSArtGalleryApp

struct WCSArtGalleryAppTests {
    @Test func mockArtworkStableCount() {
        let sample = Artwork(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "T",
            artist: "A",
            style: "S",
            year: "2026",
            medium: "M",
            description: "D",
            isFeatured: true,
            isSaved: false
        )
        #expect(sample.title == "T")
        #expect(sample.isFeatured)
    }
}

