//
//  PerformanceBudgets.swift
//  Documented local SLOs for critical paths (tune per CI hardware if needed).
//

import Foundation

enum PerformanceBudgets {
    private static var isGitHubCI: Bool {
        let env = ProcessInfo.processInfo.environment
        // xcodebuild test sometimes omits `CI`; GitHub always sets `GITHUB_ACTIONS`.
        return env["CI"] == "true" || env["GITHUB_ACTIONS"] == "true"
    }

    /// Mean time per full JSON decode of 500 `WCSBackendArtwork` rows (30 samples).
    /// Tuned for Debug locally; GitHub Actions `macos-*` runners are much slower under load.
    static var maxMeanDecode500RowsSeconds: TimeInterval {
        isGitHubCI ? 2.5 : 0.08
    }

    /// Wall time for 100 sequential mock fetches (should be in-memory only).
    static var maxMockFetchLoop100Seconds: TimeInterval {
        isGitHubCI ? 10.0 : 0.15
    }
}
