import SwiftUI

struct MemoryListView: View {
    @ObservedObject var viewModel: ARExperienceViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.memories) { memory in
                    Button {
                        viewModel.selectedMemory = memory
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(memory.note.isEmpty ? "Untitled Memory" : memory.note)
                                .lineLimit(2)
                                .font(.headline)

                            Text(memory.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    Task {
                        for index in offsets {
                            await viewModel.deleteMemory(viewModel.memories[index])
                        }
                    }
                }
            }
            .navigationTitle("Memories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await viewModel.loadMemories()
                        }
                    }
                }
            }
            .sheet(item: $viewModel.selectedMemory) { memory in
                MemoryDetailView(memory: memory)
            }
        }
    }
}
