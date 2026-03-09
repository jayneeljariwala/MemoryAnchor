import SwiftUI
import PhotosUI

struct MemoryCreationView: View {
    let onCancel: () -> Void
    let onSave: (_ note: String, _ imageData: Data?, _ audioFileName: String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MemoryCreationViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextEditor(text: $viewModel.noteText)
                        .frame(minHeight: 120)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                    }

                    if let imageData = viewModel.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Section("Voice Recording") {
                    Button(viewModel.isRecording ? "Stop Recording" : "Record Voice") {
                        viewModel.toggleRecording()
                    }

                    if let audioFileName = viewModel.audioFileName {
                        Text("Saved recording: \(audioFileName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.reset()
                        onCancel()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(viewModel.noteText, viewModel.imageData, viewModel.audioFileName)
                        viewModel.reset()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto else {
                    return
                }
                viewModel.imageData = try? await selectedPhoto.loadTransferable(type: Data.self)
            }
            .alert("Error", isPresented: errorPresentedBinding) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }

    private var canSave: Bool {
        !viewModel.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.imageData != nil
            || viewModel.audioFileName != nil
    }

    private var errorPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isVisible in
                if !isVisible {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}
