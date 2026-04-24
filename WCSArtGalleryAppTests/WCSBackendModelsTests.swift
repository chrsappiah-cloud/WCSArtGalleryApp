//
//  WCSBackendModelsTests.swift
//  WCSArtGalleryAppTests
//

import Foundation
import Testing
@testable import WCSArtGalleryApp

struct WCSBackendModelsTests {
    @Test func decodesBackendArtworkFromSnakeCaseJSON() throws {
        let json = """
        {"id":1,"title":"Study","artist_name":"Artist","description":null,"medium":null,"year":"2026",\
        "image_url":"https://example.com/a.png","thumbnail_url":null,"source_type":"upload",\
        "external_source":null,"prompt_used":null,"created_at":"2026-01-01T00:00:00Z"}
        """
        let data = Data(json.utf8)
        let artwork = try JSONDecoder().decode(WCSBackendArtwork.self, from: data)
        #expect(artwork.id == 1)
        #expect(artwork.title == "Study")
        #expect(artwork.artistName == "Artist")
        #expect(artwork.imageURL == "https://example.com/a.png")
    }

    @Test func encodesPromptRequestWithAspectRatioKey() throws {
        let req = WCSPromptRequest(
            concept: "c",
            style: "s",
            mood: "m",
            palette: "p",
            aspectRatio: "1024x1024"
        )
        let data = try JSONEncoder().encode(req)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(obj?["aspect_ratio"] as? String == "1024x1024")
        #expect(obj?["concept"] as? String == "c")
    }

    @Test func apiBaseURLHasApiPath() {
        #expect(WCSBackendAPIConfig.apiBaseURL.path == "/api")
    }
}
