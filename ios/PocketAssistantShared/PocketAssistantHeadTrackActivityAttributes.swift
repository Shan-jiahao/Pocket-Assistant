import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct PocketAssistantHeadTrackActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let status: PocketAssistantHeadTrackActivityStatus
        let pocketConnected: Bool
        let motionReady: Bool
        let isRecording: Bool
        let recordStartedAt: Date?
        let batteryPercent: Int
        let captureMode: String
        let captureFormat: String
    }
}

@available(iOS 16.1, *)
enum PocketAssistantHeadTrackActivityStatus: String, Codable, Hashable {
    case ready
    case preparing
    case active
    case paused
}
