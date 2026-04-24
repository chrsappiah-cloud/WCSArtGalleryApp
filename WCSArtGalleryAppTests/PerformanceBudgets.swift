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

    /// Application-hosted XCTests run inside the app process, which often does not inherit
    /// `CI` / `GITHUB_ACTIONS`. Simulator + Debug matches `xcodebuild test` on GitHub macOS.
    private static var isHostedSimulatorDebug: Bool {
        #if DEBUG && targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private static var useRelaxedPerformanceBudgets: Bool {
        isGitHubCI || isHostedSimulatorDebug
    }

    /// Mean time per full JSON decode of 500 `WCSBackendArtwork` rows (30 samples).
    /// Tuned for Debug locally; GitHub Actions `macos-*` runners are much slower under load.
    static var maxMeanDecode500RowsSeconds: TimeInterval {
        useRelaxedPerformanceBudgets ? 2.5 : 0.08
    }

    /// Wall time for 100 sequential mock fetches (should be in-memory only).
    static var maxMockFetchLoop100Seconds: TimeInterval {
        useRelaxedPerformanceBudgets ? 10.0 : 0.15
    }
}
