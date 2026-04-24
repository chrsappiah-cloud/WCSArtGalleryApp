import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var galleryViewModel: GalleryViewModel
    @State private var cloudKitMessage: String?
    @State private var cloudKitBusy = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Studio", value: "World Class Scholars")
                        .foregroundStyle(WCSStudioTheme.textPrimary)
                    LabeledContent("Plan", value: "Curator")
                        .foregroundStyle(WCSStudioTheme.textPrimary)
                } header: {
                    sectionHeader("Workspace")
                }

                Section {
                    Button {
                        Task { await galleryViewModel.loadArtworks() }
                    } label: {
                        Label("Refresh collection from server", systemImage: "arrow.triangle.2.circlepath")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(WCSStudioTheme.heroGradient)
                    }
                    Text("Point `WCSWorkerAPIBaseURL` in Info.plist at your Cloudflare Worker (`wrangler dev` → :8787) or FastAPI (:8000). Home / Explore / Saved use the composite service; mocks apply when the API is unreachable.")
                        .font(.footnote)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                        .listRowBackground(Color.clear)
                } header: {
                    sectionHeader("Sync")
                }

                Section {
                    Button {
                        cloudKitMessage = nil
                        cloudKitBusy = true
                        Task {
                            defer { cloudKitBusy = false }
                            do {
                                try await CloudKitGallerySync.pushSnapshot(artworks: galleryViewModel.artworks)
                                cloudKitMessage = "Backed up \(galleryViewModel.artworks.count) artwork(s) to iCloud."
                            } catch {
                                cloudKitMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Label("Backup gallery to iCloud (CloudKit)", systemImage: "icloud.and.arrow.up")
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                    }
                    .disabled(cloudKitBusy || galleryViewModel.artworks.isEmpty)

                    Button {
                        cloudKitMessage = nil
                        cloudKitBusy = true
                        Task {
                            defer { cloudKitBusy = false }
                            do {
                                let pulled = try await CloudKitGallerySync.pullArtworks()
                                galleryViewModel.mergeArtworksFromCloudKit(pulled)
                                cloudKitMessage = "Merged \(pulled.count) record(s) from iCloud."
                            } catch {
                                cloudKitMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Label("Merge from iCloud", systemImage: "icloud.and.arrow.down")
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                    }
                    .disabled(cloudKitBusy)

                    if let cloudKitMessage {
                        Text(cloudKitMessage)
                            .font(.footnote)
                            .foregroundStyle(WCSStudioTheme.textMuted)
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    sectionHeader("iCloud")
                } footer: {
                    Text("Container: \(CloudKitGallerySync.containerIdentifier). Enable iCloud + CloudKit for this App ID if saves fail.")
                        .font(.caption2)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                }

                Section {
                    Link(destination: URL(string: "https://example.com/support")!) {
                        Label("Support", systemImage: "lifepreserver")
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                    }
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy", systemImage: "hand.raised")
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                    }
                } header: {
                    sectionHeader("Links")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(WCSStudioTheme.textMuted)
            .textCase(.uppercase)
    }
}
