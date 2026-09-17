import SwiftUI

struct PocketAssistantPocketModeView: View {
    let onStop: () -> Void
    let onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("口袋模式")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.78))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.12), in: Capsule())
                    .padding(.top, 24)

                Spacer()

                Image(systemName: "viewfinder")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(.white.opacity(0.76))
                    .accessibilityHidden(true)
                Text("头追进行中")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                Text("屏幕保持常亮 · 锁屏会安全停止")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 14) {
                    Button(action: onStop) {
                        Label("立即停止", systemImage: "stop.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .background(Color.red.opacity(0.82), in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityHint("停止头追并退出口袋模式")

                    Text("按住退出")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 1.2, perform: onExit)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("按住退出口袋模式")
                        .accessibilityHint("按住一秒后回到头追页面，头追继续运行")
                        .accessibilityAction { onExit() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .accessibilityIdentifier("pocketAssistant.headTrack.pocketMode.active")
    }
}
