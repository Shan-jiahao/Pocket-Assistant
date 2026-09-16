import SwiftUI
import UIKit

enum PocketAssistantTab: Hashable {
    case devices
    case headTrack
    case capture
}

struct PocketAssistantRoot: View {
    @State private var model = AppModel()
    @State private var selection: PocketAssistantTab = .headTrack
    @State private var didStart = false
    @State private var isPocketModeActive = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                PocketAssistantDevicesView()
            }
            .tag(PocketAssistantTab.devices)
            .tabItem { Label("设备", systemImage: "camera.fill") }

            NavigationStack {
                PocketAssistantHeadTrackView {
                    isPocketModeActive = true
                }
            }
            .tag(PocketAssistantTab.headTrack)
            .tabItem { Label("头追", systemImage: "viewfinder") }

            NavigationStack {
                PocketAssistantCaptureView {
                    selection = .devices
                }
            }
            .tag(PocketAssistantTab.capture)
            .tabItem { Label("拍摄", systemImage: "record.circle") }
        }
        .overlay {
            if isPocketModeActive {
                PocketAssistantPocketModeView(
                    onStop: {
                        model.headphoneMotion.tapControl()
                        isPocketModeActive = false
                    },
                    onExit: { isPocketModeActive = false }
                )
            }
        }
        .tint(PocketAssistantDesign.primary)
        .environment(model)
        .onAppear { startIfNeeded() }
        .onChange(of: model.keepScreenAwake) { _, _ in
            applyIdleTimerPolicy()
        }
        .onChange(of: model.headTrackingEnabled) { _, _ in
            model.headphoneMotion.sync()
            refreshHeadTrackActivity()
        }
        .onChange(of: model.headTrackCalibrated) { _, _ in
            if !model.headTrackCalibrated {
                isPocketModeActive = false
            }
            applyIdleTimerPolicy()
            refreshHeadTrackActivity()
        }
        .onChange(of: model.headTrackMotionFresh) { _, _ in
            refreshHeadTrackActivity()
        }
        .onChange(of: model.session.phase) { oldPhase, newPhase in
            if case .live = newPhase {
                model.noteBecameLive()
                model.headphoneMotion.sync()
                selection = .headTrack
            } else if case .live = oldPhase {
                model.headphoneMotion.noteLinkUnavailable()
                model.noteLeftLive()
            }
            refreshHeadTrackActivity()
        }
        .onChange(of: model.session.status) { _, _ in
            refreshHeadTrackActivity()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                model.session.noteSceneBecameActive()
                model.headphoneMotion.sync()
                refreshHeadTrackActivity()
            case .inactive, .background:
                isPocketModeActive = false
                model.headphoneMotion.noteSceneBecameInactive()
                model.session.noteSceneBecameInactive()
                applyIdleTimerPolicy()
                refreshHeadTrackActivity(isPaused: true)
            @unknown default:
                break
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        ) { _ in
            isPocketModeActive = false
            model.headphoneMotion.noteSceneBecameInactive()
            model.session.noteSceneBecameInactive()
            applyIdleTimerPolicy()
            refreshHeadTrackActivity(isPaused: true)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        ) { _ in
            model.session.noteSceneBecameActive()
            model.headphoneMotion.sync()
            refreshHeadTrackActivity()
        }
    }

    private func startIfNeeded() {
        guard !didStart else { return }
        didStart = true
        DiagnosticCenter.shared.install()
        AppModelDiagnosticsAnchor.model = model
        model.prepareStartup()
        model.headphoneMotion.attach(model: model)
        configureLiveActivityCommands()
        applyIdleTimerPolicy()
        refreshHeadTrackActivity()
        if model.savedCameras.isEmpty { selection = .devices }
    }

    private func applyIdleTimerPolicy() {
        UIApplication.shared.isIdleTimerDisabled =
            model.keepScreenAwake || model.headTrackCalibrated
    }

    private func configureLiveActivityCommands() {
        guard #available(iOS 17.0, *) else { return }
        PocketAssistantLiveActivityCommandRouter.toggleRecording = {
            guard model.session.isControlLinkReady, !model.session.controlBusy else { return }
            model.session.pressShutter()
        }
        PocketAssistantLiveActivityCommandRouter.openHeadTrack = {
            selection = .headTrack
        }
    }

    private func refreshHeadTrackActivity(isPaused: Bool = false) {
        guard #available(iOS 16.1, *) else { return }
        PocketAssistantHeadTrackLiveActivity.refresh(
            isEnabled: model.headTrackingEnabled,
            isCalibrated: model.headTrackCalibrated,
            pocketConnected: model.session.isControlLinkReady,
            motionReady: model.headTrackMotionFresh,
            isRecording: model.session.status.isRecording,
            recordElapsedSec: model.session.status.recordElapsedSec,
            batteryPercent: model.session.status.batteryPercent,
            captureMode: liveActivityCaptureMode,
            captureFormat: liveActivityCaptureFormat,
            isPaused: isPaused
        )
    }

    private var liveActivityCaptureMode: String {
        switch model.session.currentShootingMode {
        case .slowMo: "慢动作"
        case .video: "视频"
        case .timeLapse: "延时摄影"
        case .photo: "照片"
        case .hyperLapse: "运动延时"
        case .superNight: "超级夜景"
        case nil: "Pocket"
        }
    }

    private var liveActivityCaptureFormat: String {
        if let format = model.session.status.videoFormat { return format.chipLabel }
        if let resolution = model.session.status.videoResolution, model.session.status.fps > 0 {
            return "\(resolution.label) · \(model.session.status.fps)p"
        }
        return "等待相机状态"
    }
}
