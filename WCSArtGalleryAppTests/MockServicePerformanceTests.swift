//
//  MockServicePerformanceTests.swift
//

import XCTest
@testable import WCSArtGalleryApp

final class MockServicePerformanceTests: XCTestCase {
    @MainActor
    func testMockGalleryServiceFetchLoopUnderSLO() async throws {
        let service = MockGalleryService()
        let iterations = 100
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0 ..< iterations {
            _ = try await service.fetchArtworks()
        }
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        XCTAssertLessThan(
            elapsed,
            PerformanceBudgets.maxMockFetchLoop100Seconds,
            "In-memory mock fetch loop slower than budget (unexpected allocation or isolation issue)."
        )
    }
}
