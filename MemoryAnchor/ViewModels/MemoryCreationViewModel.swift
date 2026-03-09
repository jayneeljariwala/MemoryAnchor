import Foundation
import Combine
import AVFoundation

@MainActor
final class MemoryCreationViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var noteText = ""
    @Published var imageData: Data?
    @Published private(set) var isRecording = false
    @Published private(set) var audioFileName: String?
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    func reset() {
        noteText = ""
        imageData = nil
        audioFileName = nil
        isRecording = false
        audioRecorder?.stop()
        audioRecorder = nil
    }

    private func startRecording() {
        Task {
            do {
                try await requestPermissionIfNeeded()
                let fileName = "memory-\(UUID().uuidString).m4a"
                let url = Self.audioDirectory.appendingPathComponent(fileName)
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12_000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try session.setActive(true, options: .notifyOthersOnDeactivation)

                let recorder = try AVAudioRecorder(url: url, settings: settings)
                recorder.delegate = self
                recorder.record()
                audioRecorder = recorder
                audioFileName = fileName
                isRecording = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
    }

    private func requestPermissionIfNeeded() async throws {
        let session = AVAudioSession.sharedInstance()

        if #available(iOS 17.0, *) {
            let granted = await AVAudioApplication.requestRecordPermission()
            if !granted {
                throw MemoryCreationError.microphonePermissionDenied
            }
        } else {
            let granted = await withCheckedContinuation { continuation in
                session.requestRecordPermission { allowed in
                    continuation.resume(returning: allowed)
                }
            }

            if !granted {
                throw MemoryCreationError.microphonePermissionDenied
            }
        }
    }

    static var audioDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

enum MemoryCreationError: LocalizedError {
    case microphonePermissionDenied

    var errorDescription: String? {
        "Microphone access is required to record a voice memory."
    }
}
