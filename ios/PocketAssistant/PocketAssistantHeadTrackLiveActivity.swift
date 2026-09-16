import ActivityKit
import Foundation

@available(iOS 16.1, *)
@MainActor
enum PocketAssistantHeadTrackLiveActivity {
    static func refresh(
        isEnabled: Bool,
        isCalibrated: Bool,
        pocketConnected: Bool,
        motionReady: Bool,
        isRecording: Bool,
        recordElapsedSec: Int,
        batteryPercent: Int,
        captureMode: String,
        captureFormat: String,
        isPaused: Bool = false
    ) {
        guard isEnabled || pocketConnected else {
            end()
            return
        }

        let status: PocketAssistantHeadTrackActivityStatus =
            if isPaused {
                .paused
            } else if isCalibrated {
                .active
            } else if !isEnabled {
                .ready
            } else {
                .preparing
            }
        let state = PocketAssistantHeadTrackActivityAttributes.ContentState(
            status: status,
            pocketConnected: pocketConnected,
            motionReady: motionReady,
            isRecording: isRecording,
            recordStartedAt: isRecording
                ? Date().addingTimeInterval(-TimeInterval(recordElapsedSec)) : nil,
            batteryPercent: batteryPercent,
            captureMode: captureMode,
            captureFormat: captureFormat
        )
        let content = ActivityContent(state: state, staleDate: nil)

        Task {
            if let activity = Activity<PocketAssistantHeadTrackActivityAttributes>.activities.first
            {
                await activity.update(content)
                return
            }

            do {
                _ = try Activity.request(
                    attributes: PocketAssistantHeadTrackActivityAttributes(),
                    content: content,
                    pushType: nil
                )
            } catch {
                // Live Activities are optional system chrome. Head tracking must
                // remain available when they are disabled or rate-limited.
            }
        }
    }

    static func end() {
        Task {
            for activity in Activity<PocketAssistantHeadTrackActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
