import CloudKit
import Foundation

/// Private-database snapshot of gallery rows for backup and cross-device merge.
/// Create the `GalleryArtwork` record type in the CloudKit Dashboard (Development) on first run, or let the client create fields from saves.
enum CloudKitGallerySync {
    /// Must match `WCSArtGalleryApp.entitlements` and the container enabled for this App ID in Apple Developer.
    static let containerIdentifier = "iCloud.wcs.WCSArtGalleryApp"

    private static let recordType = "GalleryArtwork"

    private static var database: CKDatabase {
        CKContainer(identifier: containerIdentifier).privateCloudDatabase
    }

    static func pushSnapshot(artworks: [Artwork]) async throws {
        let db = database
        for artwork in artworks {
            let recordID = CKRecord.ID(recordName: artwork.id.uuidString)
            let record = CKRecord(recordType: recordType, recordID: recordID)
            record["title"] = artwork.title as CKRecordValue
            record["artist"] = artwork.artist as CKRecordValue
            record["style"] = artwork.style as CKRecordValue
            record["year"] = artwork.year as CKRecordValue
            record["medium"] = artwork.medium as CKRecordValue
            record["desc"] = artwork.description as CKRecordValue
            record["featured"] = (artwork.isFeatured ? 1 : 0) as CKRecordValue
            record["saved"] = (artwork.isSaved ? 1 : 0) as CKRecordValue
            if let imageURL = artwork.imageURL {
                record["imageURL"] = imageURL as CKRecordValue
            }
            _ = try await db.save(record)
        }
    }

    static func pullArtworks() async throws -> [Artwork] {
        let db = database
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        let (matchResults, _) = try await db.records(matching: query)
        var out: [Artwork] = []
        out.reserveCapacity(matchResults.count)
        for (_, result) in matchResults {
            if case let .success(record) = result, let a = artwork(from: record) {
                out.append(a)
            }
        }
        return out
    }

    private static func artwork(from record: CKRecord) -> Artwork? {
        guard let id = UUID(uuidString: record.recordID.recordName),
              let title = record["title"] as? String,
              let artist = record["artist"] as? String
        else { return nil }
        let style = record["style"] as? String ?? ""
        let year = record["year"] as? String ?? ""
        let medium = record["medium"] as? String ?? ""
        let description = record["desc"] as? String ?? ""
        let featuredNum = record["featured"] as? NSNumber
        let savedNum = record["saved"] as? NSNumber
        let featured = featuredNum?.intValue == 1
        let saved = savedNum?.intValue == 1
        let imageURL = record["imageURL"] as? String
        return Artwork(
            id: id,
            title: title,
            artist: artist,
            style: style,
            year: year,
            medium: medium,
            description: description,
            isFeatured: featured,
            isSaved: saved,
            imageURL: imageURL
        )
    }
}
