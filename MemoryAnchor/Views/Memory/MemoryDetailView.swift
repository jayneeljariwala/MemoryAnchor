import SwiftUI

struct MemoryDetailView: View {
    let memory: MemoryAnchorModel

    @StateObject private var audioService = AudioPlaybackService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(memory.note)
                        .font(.body)

                    if let imageData = memory.imageData,
                       let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if let audioURL = audioURL {
                        Button(audioService.isPlaying ? "Stop Audio" : "Play Audio") {
                            audioService.isPlaying ? audioService.stop() : audioService.play(url: audioURL)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Text("Created: \(memory.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Memory")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear {
            audioService.stop()
        }
    }

    private var audioURL: URL? {
        guard let audioFileName = memory.audioFileName else {
            return nil
        }
        return MemoryCreationViewModel.audioDirectory.appendingPathComponent(audioFileName)
    }
}
