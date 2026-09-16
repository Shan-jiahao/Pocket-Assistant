import AppIntents
import Foundation

@available(iOS 17.0, *)
@MainActor
enum PocketAssistantLiveActivityCommandRouter {
    static var toggleRecording: (() -> Void)?
    static var openHeadTrack: (() -> Void)?

    static func performToggleRecording() {
        toggleRecording?()
    }

    static func performOpenHeadTrack() {
        openHeadTrack?()
    }
}

@available(iOS 17.0, *)
struct PocketAssistantToggleRecordingIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "开始或停止录制"

    func perform() async throws -> some IntentResult {
        await PocketAssistantLiveActivityCommandRouter.performToggleRecording()
        return .result()
    }
}

@available(iOS 17.0, *)
struct PocketAssistantOpenHeadTrackIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "校准并锁定"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await PocketAssistantLiveActivityCommandRouter.performOpenHeadTrack()
        return .result()
    }
}
