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
        isPaused: Bool = false
    ) {
        guard isEnabled else {
            end()
            return
        }

        let status: PocketAssistantHeadTrackActivityStatus =
            if isPaused {
                .paused
            } else if isCalibrated {
                .active
            } else {
                .preparing
            }
        let state = PocketAssistantHeadTrackActivityAttributes.ContentState(
            status: status,
            pocketConnected: pocketConnected,
            motionReady: motionReady
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
