import ActivityKit

@available(iOS 16.1, *)
struct PocketAssistantHeadTrackActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let status: PocketAssistantHeadTrackActivityStatus
        let pocketConnected: Bool
        let motionReady: Bool
    }
}

@available(iOS 16.1, *)
enum PocketAssistantHeadTrackActivityStatus: String, Codable, Hashable {
    case preparing
    case active
    case paused
}
