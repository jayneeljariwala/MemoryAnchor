import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ARExperienceViewModel
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: ARExperienceViewModel(
                memoryManager: dependencies.memoryManager,
                arSessionManager: dependencies.arSessionManager
            )
        )
    }

    var body: some View {
        TabView {
            NavigationStack {
                ARExperienceScreen(
                    viewModel: viewModel,
                    arSessionManager: dependencies.arSessionManager
                )
                .navigationTitle("MemoryAnchors")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("AR View", systemImage: "arkit")
            }

            MemoryListView(viewModel: viewModel)
                .tabItem {
                    Label("Memories", systemImage: "list.bullet")
                }
        }
        .task {
            await viewModel.bootstrap()
        }
    }
}

#Preview {
    ContentView(dependencies: .live)
}
