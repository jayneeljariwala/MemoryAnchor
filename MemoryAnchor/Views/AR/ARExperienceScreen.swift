import SwiftUI
import ARKit

struct ARExperienceScreen: View {
    @ObservedObject var viewModel: ARExperienceViewModel
    let arSessionManager: ARSessionManaging

    @State private var currentSession: ARSession?

    var body: some View {
        ZStack(alignment: .top) {
            ARViewContainer(
                memories: viewModel.memories,
                pendingPlacement: viewModel.pendingPlacement,
                restoredWorldMap: viewModel.restoredWorldMap,
                arSessionManager: arSessionManager,
                onSurfaceTap: { anchorName, transform in
                    viewModel.beginMemoryPlacement(anchorName: anchorName, transform: transform)
                },
                onMemoryTap: { anchorName in
                    viewModel.selectMemory(with: anchorName)
                },
                onSessionAvailable: { session in
                    currentSession = session
                }
            )
            .ignoresSafeArea()

            Text("Tap a detected horizontal surface to place a memory anchor.")
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 12)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save Map") {
                    guard let currentSession else {
                        return
                    }
                    Task {
                        await viewModel.saveWorldMap(using: currentSession)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isCreationSheetPresented) {
            MemoryCreationView(
                onCancel: {
                    viewModel.cancelMemoryPlacement()
                },
                onSave: { note, imageData, audioFileName in
                    Task {
                        await viewModel.saveMemory(note: note, imageData: imageData, audioFileName: audioFileName)
                        if let currentSession {
                            await viewModel.saveWorldMap(using: currentSession)
                        }
                    }
                }
            )
        }
        .sheet(item: $viewModel.selectedMemory) { memory in
            MemoryDetailView(memory: memory)
        }
        .alert("Error", isPresented: errorPresentedBinding) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
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
