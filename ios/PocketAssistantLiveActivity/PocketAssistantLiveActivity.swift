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
            HStack(spacing: 10) {
                Image(systemName: symbol(for: context.state.status))
                    .foregroundStyle(tint(for: context.state.status))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: context.state.status))
                        .font(.headline)
                    Text(detail(for: context.state))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                if context.state.status == .paused {
                    Text("解锁后继续")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .activityBackgroundTint(Color.black.opacity(0.86))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: symbol(for: context.state.status))
                        .foregroundStyle(tint(for: context.state.status))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(shortTitle(for: context.state.status))
                        .font(.caption.weight(.bold))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(detail(for: context.state))
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
        }
    }

    private func shortTitle(for status: PocketAssistantHeadTrackActivityStatus) -> String {
        switch status {
        case .preparing: return "准备"
        case .active: return "头追"
        case .paused: return "暂停"
        }
    }

    private func detail(
        for state: PocketAssistantHeadTrackActivityAttributes.ContentState
    ) -> String {
        if state.status == .paused { return "手机锁定或 App 进入后台，云台已安全停止" }
        let pocket = state.pocketConnected ? "Pocket 已连接" : "Pocket 未连接"
        let motion = state.motionReady ? "动作数据正常" : "等待 AirPods"
        return "\(pocket) · \(motion)"
    }

    private func symbol(for status: PocketAssistantHeadTrackActivityStatus) -> String {
        switch status {
        case .preparing: return "viewfinder"
        case .active: return "dot.radiowaves.left.and.right"
        case .paused: return "pause.circle.fill"
        }
    }

    private func tint(for status: PocketAssistantHeadTrackActivityStatus) -> Color {
        switch status {
        case .preparing: return .blue
        case .active: return .green
        case .paused: return .orange
        }
    }
}
