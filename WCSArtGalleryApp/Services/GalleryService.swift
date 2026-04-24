import Foundation

protocol GalleryService: Sendable {
    func fetchArtworks() async throws -> [Artwork]
}

struct MockGalleryService: GalleryService {
    func fetchArtworks() async throws -> [Artwork] {
        [
            Artwork(
                id: UUID(),
                title: "Golden Kente Reverie",
                artist: "Ama Nkrumah",
                style: "Contemporary Textile",
                year: "2026",
                medium: "Acrylic on Canvas",
                description: "A rich tapestry-inspired composition that explores heritage and bold modern form.",
                isFeatured: true,
                isSaved: true
            ),
            Artwork(
                id: UUID(),
                title: "Ethereal Savannah",
                artist: "Kojo Asante",
                style: "Digital Impressionism",
                year: "2025",
                medium: "Digital Print",
                description: "A luminous landscape study with layered atmospheric light and expressive brush rhythm.",
                isFeatured: true,
                isSaved: false
            ),
            Artwork(
                id: UUID(),
                title: "Ancestral Echoes",
                artist: "Efua Tetteh",
                style: "Mixed Media",
                year: "2024",
                medium: "Ink, Gold Leaf, Collage",
                description: "Textural storytelling through symbols and memory fragments rooted in intergenerational identity.",
                isFeatured: true,
                isSaved: false
            ),
            Artwork(
                id: UUID(),
                title: "Silent Bronze",
                artist: "Yaw Mensah",
                style: "Sculptural Study",
                year: "2023",
                medium: "Bronze Cast",
                description: "A minimalist form language focused on posture, tension, and serenity.",
                isFeatured: false,
                isSaved: false
            )
        ]
    }
}
