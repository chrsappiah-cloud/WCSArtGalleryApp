import PhotosUI
import SwiftUI

/// Ingestion surface: open-access Met sample + future uploads.
struct WCSFusionUploadHubView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var isImporting = false
    @State private var statusMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        Task { await runMetImport() }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "building.columns.fill")
                                .font(.title3)
                                .foregroundStyle(WCSStudioTheme.heroGradient)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Import Met open access sample")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(WCSStudioTheme.textPrimary)
                                Text("Pulls public-domain highlights into your FastAPI gallery.")
                                    .font(.caption)
                                    .foregroundStyle(WCSStudioTheme.textMuted)
                            }
                            Spacer()
                            if isImporting {
                                ProgressView()
                                    .tint(WCSStudioTheme.accent)
                            }
                        }
                    }
                    .disabled(isImporting)
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(WCSStudioTheme.textMuted)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    sectionLabel("Collections")
                }

                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Choose from Photos", systemImage: "photo.on.rectangle.angled")
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                    }
                    Text("Next: multipart POST to /api/upload-artwork with title + image for /media/uploads.")
                        .font(.footnote)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                } header: {
                    sectionLabel("Device")
                }

                Section {
                    Text("Generic JSON ingest via POST /api/import-external (endpoint, field map, limit).")
                        .font(.footnote)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                } header: {
                    sectionLabel("Partner feeds")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Ingest")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(WCSStudioTheme.textMuted)
            .textCase(.uppercase)
    }

    @MainActor
    private func runMetImport() async {
        isImporting = true
        statusMessage = ""
        defer { isImporting = false }
        do {
            let n = try await WCSBackendAPIClient.shared.importMetOpenAccessSample(limit: 6)
            statusMessage =
                "Imported \(n) pieces. Open the Home tab and pull to refresh, or use Profile → Refresh collection."
        } catch {
            statusMessage =
                "Import failed: \(error.localizedDescription). Ensure the API is running at \(WCSBackendAPIConfig.apiOrigin.absoluteString)."
        }
    }
}
