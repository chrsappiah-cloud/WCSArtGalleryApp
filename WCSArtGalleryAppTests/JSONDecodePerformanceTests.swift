//
//  JSONDecodePerformanceTests.swift
//  Smoke benchmark for backend-shaped payloads (not a substitute for Instruments).
//

import Foundation
import XCTest
@testable import WCSArtGalleryApp

final class JSONDecodePerformanceTests: XCTestCase {
    private func payload500() throws -> Data {
        let template = """
        {"id":%d,"title":"T","artist_name":"A","description":null,"medium":null,"year":"2026",\
        "image_url":"https://example.com/%d.png","thumbnail_url":null,"source_type":"upload",\
        "external_source":null,"prompt_used":null,"created_at":"2026-01-01T00:00:00Z"}
        """
        let rows = (1 ... 500).map { String(format: template, $0, $0) }.joined(separator: ",")
        return "[\(rows)]".data(using: .utf8)!
    }

    /// Regression guard: mean decode latency must stay under `PerformanceBudgets`.
    func testDecode500BackendArtworksMeanLatencyUnderSLO() throws {
        let json = try payload500()
        let iterations = 30
        let start = CFAbsoluteTimeGetCurrent()
        for _ in 0 ..< iterations {
            _ = try JSONDecoder().decode([WCSBackendArtwork].self, from: json)
        }
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        let mean = elapsed / Double(iterations)
        XCTAssertLessThan(
            mean,
            PerformanceBudgets.maxMeanDecode500RowsSeconds,
            "Mean JSON decode (500 rows) exceeded SLO; investigate model or payload size."
        )
    }

    /// XCTest `measure` baseline for local Instruments comparison (no hard assert).
    func testDecodeManyBackendArtworksMeasure() throws {
        let json = try payload500()
        measure {
            _ = try! JSONDecoder().decode([WCSBackendArtwork].self, from: json)
        }
    }
}
