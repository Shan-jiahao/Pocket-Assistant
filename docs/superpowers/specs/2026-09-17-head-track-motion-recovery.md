# Head-track motion recovery and diagnostic clarity

## Outcome

Keep AirPods head motion available through foreground lifecycle transitions and
recover a stalled Core Motion stream without weakening the existing immediate
gimbal safety stop. Make field reports distinguish current runtime state from
historical system diagnostics.

## Constraints

- Preserve the existing `HeadTrack` controller, BLE -> SoftAP -> UDP/DUML path,
  and 25 Hz gimbal stick sender.
- A real AirPods disconnect, stale motion sample, Pocket link loss, or inactive
  app still rests the gimbal immediately and clears calibration.
- Recovery may restart Core Motion, but it must never resume gimbal movement
  without a fresh user calibration.
- Do not add background modes or claim lock-screen head tracking.

## Scope

1. Serialize Core Motion startup so repeated sync/delegate callbacks cannot
   issue overlapping `startDeviceMotionUpdates` calls.
2. After the 250 ms safety timeout, clear calibration and automatically rebuild
   the motion stream using the existing bounded push retries and pull fallback.
3. Ignore connection callbacks caused by an intentional lifecycle stop, and
   debounce a pre-sample disconnect notification so an immediate matching
   connect does not flicker the UI or masquerade as a physical disconnect.
4. Make recovery logs grammatical when the first reconnect attempt succeeds.
5. Label MetricKit payloads and the rolling journal as historical/cross-launch
   material in shared diagnostic reports.

## Acceptance

- At most one motion start request is in flight before a first sample arrives.
- A stale sample immediately stops gimbal output and clears calibration, then
  starts a clean motion stream; recovered samples do not drive until the user
  calibrates again.
- An inactive/background lifecycle stop cannot be undone by a late AirPods
  delegate callback.
- A transient disconnect/connect before the first sample produces no false
  disconnected state; a confirmed disconnect still fails safe.
- Focused policy tests, Swift package tests, lint, and iOS simulator build/tests
  pass. Physical AirPods validation remains required for motion delivery.
