import Foundation

/// Host + `/api` for JSON routes; `apiOrigin` is used to resolve `/media/...` image paths.
///
/// Set `WCSWorkerAPIBaseURL` in Info.plist to your Cloudflare Worker origin (e.g. `https://wcs-art-gallery-prototype.<subdomain>.workers.dev`)
/// or `http://127.0.0.1:8787` for `wrangler dev`. Omit or leave empty to use local FastAPI on port 8000.
enum WCSBackendAPIConfig {
    private static var plistOriginString: String? {
        let raw = Bundle.main.object(forInfoDictionaryKey: "WCSWorkerAPIBaseURL") as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    static var apiOrigin: URL {
        if let s = plistOriginString, let u = URL(string: s) {
            return u
        }
        return URL(string: "http://127.0.0.1:8000")!
    }

    static var apiBaseURL: URL { apiOrigin.appending(path: "api") }
}
