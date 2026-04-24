//
//  GalleryViewModelTests.swift
//  WCSArtGalleryAppTests
//

import Foundation
import Testing
@testable import WCSArtGalleryApp

struct GalleryViewModelTests {
    @Test @MainActor
    func loadsMockArtworksAndDerivesFeatured() async {
        let vm = GalleryViewModel(service: MockGalleryService())
        await vm.loadArtworks()
        #expect(vm.artworks.count == 4)
        #expect(vm.featuredArtworks.count == 3)
        #expect(vm.savedArtworks.count == 1)
        #expect(vm.errorMessage == nil)
    }

    @Test @MainActor
    func serviceFailureSetsUserFacingError() async {
        struct FailingService: GalleryService {
            func fetchArtworks() async throws -> [Artwork] {
                throw URLError(.notConnectedToInternet)
            }
        }
        let vm = GalleryViewModel(service: FailingService())
        await vm.loadArtworks()
        #expect(vm.artworks.isEmpty)
        #expect(vm.errorMessage?.isEmpty == false)
    }
}
