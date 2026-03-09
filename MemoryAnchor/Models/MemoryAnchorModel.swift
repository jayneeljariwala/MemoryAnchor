import Foundation

struct MemoryAnchorModel: Identifiable, Equatable {
    let id: UUID
    let anchorName: String
    let note: String
    let imageData: Data?
    let audioFileName: String?
    let createdAt: Date
    let transformData: Data

    var hasAudio: Bool {
        audioFileName != nil
    }
}
