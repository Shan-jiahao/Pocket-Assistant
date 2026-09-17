# Head-track field controls

## Outcome

Make the head-track control page compact below the iPhone safe area, keep the
screen awake while a calibrated head-track session is driving the Pocket, and
make its safety state visible on the Lock Screen and Dynamic Island. Keep the
bottom navigation in the operator workflow order: Devices, Head Track, Capture.

## Constraints

- iOS suspends ordinary apps when they lock or enter the background.
  `CMHeadphoneMotionManager` and the 25 Hz Pocket UDP control loop therefore
  cannot be promised as a background service.
- Do not claim that a Live Activity keeps the control loop, AirPods motion, or
  camera network alive. It is a state surface only.
- On every inactive/background event, continue to rest the existing gimbal
  stick, clear the calibration, and require a fresh calibration on return.
- Do not request unrelated background modes, including audio, location, or
  VoIP, merely to keep the app executing.
- Preserve the existing BLE -> SoftAP -> UDP/DUML transport and HeadTrack
  controller; no protocol or PID work belongs in this change.

## Scope

1. Use the standard inline navigation bar on the head-track page, leaving the
   system to reserve Dynamic Island and notch safe-area space.
2. Reduce the page's top content inset and the hero visual's height without
   reducing the minimum touch size of controls.
3. Keep the device awake automatically only while head tracking is calibrated
   and actively driving. The existing user preference remains effective at all
   other times.
4. Add a Pocket Assistant Live Activity that shows Pocket link state, AirPods
   motion state, and whether head tracking is ready, active, or safely paused.
   Tapping the activity returns to the app. The first release intentionally
   does not expose direct record/head-track commands from the widget extension,
   because it cannot safely own or reconnect the live camera control session.
5. Update the Chinese product guide and parity contract with the foreground
   operation boundary.
6. Add a calibrated-only Pocket Mode: a pure-black, low-distraction foreground
   control surface with an immediate stop action and a deliberate long-press
   exit. It must never be presented as a lock-screen or background workaround.
7. Expand the existing Live Activity into a Pocket control strip that exposes
   last-known connection, battery, capture mode, format, and recording elapsed
   time, and opens Pocket Assistant when tapped. It must not claim that this
   display keeps the camera session or head tracking alive in the background.

## Acceptance

- On iPhones with a Dynamic Island, notch, or neither, the head-track title
  begins below the system bar without the former large-title gap.
- Once calibrated, the display does not auto-lock from idle; stopping or any
  safety stop restores the normal idle behavior unless the user's always-awake
  preference is enabled.
- Pressing the side button, locking, switching apps, or backgrounding stops
  gimbal output immediately and makes the activity say it is paused.
- The Live Activity is visible on the Lock Screen and Dynamic Island when
  allowed by system settings, and always reflects the latest foreground state
  before the app is suspended.
- The tab order is Devices, Head Track, Capture. Pocket Mode can only open
  after calibration, preserves the existing foreground awake policy, and
  closes as soon as calibration clears or the app becomes inactive.
- With a connected Pocket, the Lock Screen and Dynamic Island show the Pocket
  control strip even when head tracking is off. Tapping it opens the app; it
  has a red record/stop action that rechecks the Pocket control link before
  using the existing shutter API. "校准并锁定" requires system authentication,
  opens the head-track page, and does not calibrate while the device is locked.
- Builds and focused tests pass. Real iPhone validation covers safe-area layout,
  auto-lock prevention, manual lock safety stop, and the Live Activity state.

## Risks

- iOS can hide, rate-limit, or disable Live Activities. The app must continue
  safely without one.
- A manually locked phone cannot retain real-time AirPods control under the
  supported iOS execution model; the UI must make that safety stop explicit.
