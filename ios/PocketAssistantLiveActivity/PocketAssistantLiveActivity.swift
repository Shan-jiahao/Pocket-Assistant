import ActivityKit
import SwiftUI
import WidgetKit

@main
struct PocketAssistantLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        PocketAssistantHeadTrackLiveActivityWidget()
    }
}

@available(iOS 16.1, *)
struct PocketAssistantHeadTrackLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PocketAssistantHeadTrackActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundStyle(tint(for: context.state.status))
                        .frame(width: 32, height: 32)
                        .background(tint(for: context.state.status).opacity(0.16), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.isRecording ? "正在录制" : context.state.captureMode)
                            .font(.headline)
                        Text(context.state.captureFormat)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    if context.state.isRecording, let startedAt = context.state.recordStartedAt {
                        Text(startedAt, style: .timer)
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.red)
                    } else {
                        Text(context.state.pocketConnected ? "已连接" : "已暂停")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tint(for: context.state.status))
                    }
                }

                HStack(spacing: 12) {
                    Label(batteryText(for: context.state), systemImage: "battery.75percent")
                    Spacer(minLength: 0)
                    Text(detail(for: context.state))
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(14)
            .activityBackgroundTint(Color.black.opacity(0.86))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: symbol(for: context.state.status))
                        .foregroundStyle(tint(for: context.state.status))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isRecording, let startedAt = context.state.recordStartedAt {
                        Text(startedAt, style: .timer)
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.red)
                    } else {
                        Text(shortTitle(for: context.state.status))
                            .font(.caption.weight(.bold))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.captureFormat)
                        Spacer()
                        Text(detail(for: context.state))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: symbol(for: context.state.status))
                    .foregroundStyle(tint(for: context.state.status))
            } compactTrailing: {
                Text(shortTitle(for: context.state.status))
                    .font(.caption2.weight(.bold))
            } minimal: {
                Image(systemName: symbol(for: context.state.status))
                    .foregroundStyle(tint(for: context.state.status))
            }
        }
    }

    private func title(for status: PocketAssistantHeadTrackActivityStatus) -> String {
        switch status {
        case .preparing: return "头追准备中"
        case .active: return "头追进行中"
        case .paused: return "头追已暂停"
        case .ready: return "Pocket 已连接"
        }
    }

    private func shortTitle(for status: PocketAssistantHeadTrackActivityStatus) -> String {
        switch status {
        case .preparing: return "准备"
        case .active: return "头追"
        case .paused: return "暂停"
        case .ready: return "Pocket"
        }
    }

    private func detail(
        for state: PocketAssistantHeadTrackActivityAttributes.ContentState
    ) -> String {
        if state.status == .paused { return "头追已安全停止；轻点打开 App" }
        if state.status == .ready { return "轻点打开拍摄控制" }
        let pocket = state.pocketConnected ? "Pocket 已连接" : "Pocket 未连接"
        let motion = state.motionReady ? "动作数据正常" : "等待 AirPods"
        return "\(pocket) · \(motion)"
    }

    private func symbol(for status: PocketAssistantHeadTrackActivityStatus) -> String {
        switch status {
        case .preparing: return "viewfinder"
        case .active: return "dot.radiowaves.left.and.right"
        case .paused: return "pause.circle.fill"
        case .ready: return "camera.fill"
        }
    }

    private func tint(for status: PocketAssistantHeadTrackActivityStatus) -> Color {
        switch status {
        case .preparing: return .blue
        case .active: return .green
        case .paused: return .orange
        case .ready: return .blue
        }
    }

    private func batteryText(
        for state: PocketAssistantHeadTrackActivityAttributes.ContentState
    ) -> String {
        state.batteryPercent >= 0 ? "Pocket \(state.batteryPercent)%" : "Pocket 电量 —"
    }
}
