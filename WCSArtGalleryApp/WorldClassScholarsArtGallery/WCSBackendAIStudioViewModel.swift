import Combine
import Foundation

@MainActor
final class WCSBackendAIStudioViewModel: ObservableObject {
    @Published var concept = "A luminous healing garden for dementia-friendly art therapy"
    @Published var style = "cinematic fine art installation"
    @Published var mood = "elegant, calm, gallery-grade"
    @Published var palette = "ivory, charcoal, muted teal, warm gold"
    @Published var generatedPrompt = ""
    @Published var generatedImageURL: URL?
    @Published var isWorking = false
    @Published var errorMessage: String?

    private var promptPayload: WCSPromptRequest {
        WCSPromptRequest(
            concept: concept,
            style: style,
            mood: mood,
            palette: palette,
            aspectRatio: "1024x1024"
        )
    }

    func buildPrompt() async {
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            let response = try await WCSBackendAPIClient.shared.buildPrompt(request: promptPayload)
            generatedPrompt = response.finalPrompt
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generate() async {
        isWorking = true
        errorMessage = nil
        generatedImageURL = nil
        defer { isWorking = false }
        do {
            generatedImageURL = try await WCSBackendAPIClient.shared.generateImage(request: promptPayload)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
