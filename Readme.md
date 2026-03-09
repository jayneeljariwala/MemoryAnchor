# MemoryAnchors

MemoryAnchors is an iOS AR app that lets users place digital memories in real-world spaces.

Using ARKit and RealityKit, users tap detected horizontal surfaces to create floating memory anchors. Each anchor can store:

- A text note
- A photo
- A voice recording

The app persists memory data with Core Data and stores AR world mapping data so anchors can be restored across launches.

## Tech Stack

- SwiftUI
- ARKit
- RealityKit
- Core Data
- AVFoundation

## Architecture

The project follows **MVVM** with modular services and dependency injection.

- `Models/`: app data structures (`MemoryAnchorModel`, `PendingMemoryPlacement`)
- `ViewModels/`: presentation and feature logic
- `Views/`: SwiftUI screens and AR container
- `Services/`: AR session management, persistence, audio playback, DI container
- `Utilities/`: shared helpers (`MatrixTransformCoder`)

## Main Features

1. AR world tracking with horizontal plane detection
2. Tap-to-place AR memory anchors
3. Memory creation flow (text, image, voice)
4. Persistent world map and anchor metadata
5. Interactive memory spheres in AR scene
6. Memory detail view with text, image, audio playback
7. Memory list screen with refresh/delete

## App Flow

1. Launch app -> loads saved memories and AR world map
2. In AR tab, tap a detected surface to place a memory anchor
3. Add memory content in the creation modal
4. Anchor appears as a floating sphere
5. Tap a sphere (or open from list) to view memory details

## Requirements

- iOS device with ARKit support (recommended for full AR testing)
- Camera permission
- Microphone permission (for voice recording)
- Photo library access (for selecting images)

## Getting Started

1. Open `MemoryAnchor.xcodeproj` in Xcode
2. Select an iOS target device (physical device recommended)
3. Build and run

## Notes

- AR world persistence quality depends on environmental tracking quality.
- For best results, scan the environment well before saving world map data.
