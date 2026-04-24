import SwiftUI

struct WCSBackendAIStudioView: View {
    @StateObject private var vm = WCSBackendAIStudioViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    promptCard
                    actionRow(title: "Refine prompt", subtitle: "Shape language before pixels.", systemImage: "text.quote") {
                        Task { await vm.buildPrompt() }
                    }
                    if !vm.generatedPrompt.isEmpty {
                        Text(vm.generatedPrompt)
                            .font(.footnote)
                            .foregroundStyle(WCSStudioTheme.textMuted)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(WCSStudioTheme.panel.opacity(0.9))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                                    ),
                            )
                    }
                    actionRow(title: "Generate image", subtitle: "Uses your configured OpenAI key on the server.", systemImage: "sparkles") {
                        Task { await vm.generate() }
                    }
                    if let url = vm.generatedImageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                            default:
                                ProgressView()
                                    .tint(WCSStudioTheme.accent)
                                    .frame(maxWidth: .infinity, minHeight: 200)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(WCSStudioTheme.heroGradient, lineWidth: 1),
                        )
                    }
                    if let err = vm.errorMessage, !err.isEmpty {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(Color(red: 1, green: 0.45, blue: 0.52))
                    }
                }
                .padding(18)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
        }
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prompt")
                .font(.caption.weight(.semibold))
                .foregroundStyle(WCSStudioTheme.textMuted)
                .textCase(.uppercase)
            TextField("Concept", text: $vm.concept, axis: .vertical)
                .lineLimit(3 ... 8)
                .foregroundStyle(WCSStudioTheme.textPrimary)
                .padding(12)
                .background(fieldFill)
            TextField("Style", text: $vm.style)
                .foregroundStyle(WCSStudioTheme.textPrimary)
                .padding(12)
                .background(fieldFill)
            TextField("Mood", text: $vm.mood)
                .foregroundStyle(WCSStudioTheme.textPrimary)
                .padding(12)
                .background(fieldFill)
            TextField("Palette", text: $vm.palette)
                .foregroundStyle(WCSStudioTheme.textPrimary)
                .padding(12)
                .background(fieldFill)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(WCSStudioTheme.panelElevated.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                ),
        )
    }

    private var fieldFill: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(WCSStudioTheme.panel.opacity(0.65))
    }

    private func actionRow(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void,
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(WCSStudioTheme.heroGradient)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(WCSStudioTheme.accent.opacity(0.15)),
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(WCSStudioTheme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                }
                Spacer()
                if vm.isWorking {
                    ProgressView()
                        .tint(WCSStudioTheme.accent)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(WCSStudioTheme.textMuted.opacity(0.5))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(WCSStudioTheme.panelElevated.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                    ),
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.isWorking)
    }
}
