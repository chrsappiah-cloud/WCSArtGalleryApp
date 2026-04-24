//
//  PerformanceBudgets.swift
//  Documented local SLOs for critical paths (tune per CI hardware if needed).
//

import Foundation

enum PerformanceBudgets {
    /// Mean time per full JSON decode of 500 `WCSBackendArtwork` rows (30 samples).
    /// Tuned for Debug + cold CI runners; tighten after profiling Release on target hardware.
    static let maxMeanDecode500RowsSeconds: TimeInterval = 0.08

    /// Wall time for 100 sequential mock fetches (should be in-memory only).
    static let maxMockFetchLoop100Seconds: TimeInterval = 0.15
}
