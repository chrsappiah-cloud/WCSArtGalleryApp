import PhotosUI
import SwiftUI

struct UploadHubView: View {
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            List {
                Section("Local Upload") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Choose from Photos", systemImage: "photo.on.rectangle")
                    }
                    Text(
                        "Add a Files-based importer and multipart upload request to `/api/upload-artwork` in the next integration pass."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                Section("External APIs") {
                    Text("Use `/api/import-external` to ingest museum or institutional API feeds.")
                    Text(
                        "Recommended adapters: The Met Collection API, Cleveland Museum of Art Open Access API, Harvard Art Museums API."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Upload Hub")
        }
    }
}
