# Pocket Assistant Paid-Team In-App Device Link

## Outcome

Pocket Assistant uses the owner's paid Apple Developer team and product bundle
identifier so pairing can request joining the Pocket camera Wi-Fi from inside
the app. The existing BLE → SoftAP → UDP/DUML control path remains unchanged.

## Scope

- Configure only the `PocketAssistant` iOS target with the paid team and product
  bundle identifier.
- Retain the existing Hotspot Configuration entitlement.
- Present automatic join as the normal connection flow.
- Reveal manual Settings → Wi-Fi instructions only when iOS reports that
  automatic join is unavailable.
- Keep Personal Team builds and runtime failures recoverable through the manual
  path.

## Out of scope

- Camera protocol changes, a second connection implementation, or PID changes.
- iOS, camera, or accessory firmware updates.
- Publishing a build to App Store Connect or inviting external testers.

## Acceptance criteria

- A physical-iPhone build signs as `com.shanjiahao.pocketassistant` for team
  `8HS6U9RZJM`.
- The signed app contains
  `com.apple.developer.networking.HotspotConfiguration = true`.
- Normal pairing asks iOS to join the camera network without telling the user to
  leave the app first.
- If automatic join is unavailable, the target SSID and manual return flow are
  still shown.
- Existing tests and the Pocket Assistant simulator/device builds pass.

## Risks and verification

The iOS system owns the Join prompt, and a simulator cannot exercise BLE or
camera SoftAP. Build signing and entitlements can be verified locally; the
prompt, DHCP path, UDP handshake, and control readiness require a powered Pocket
and a physical iPhone.
