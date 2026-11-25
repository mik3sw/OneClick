//
//  KeepAwake.swift
//  OneClick
//

import IOKit.pwr_mgt

/// Keeps the Mac and its display awake through a power-management assertion,
/// the same mechanism `caffeinate` uses. macOS drops the assertion when the app quits.
final class KeepAwake {
    private var assertionID: IOPMAssertionID = 0
    private(set) var isActive = false

    func setActive(_ active: Bool) throws {
        guard active != isActive else { return }

        if active {
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "OneClick Keep Awake" as CFString,
                &assertionID
            )
            guard result == kIOReturnSuccess else {
                throw CommandError(kind: .failed, message: "macOS refused to keep the Mac awake.")
            }
        } else {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        isActive = active
    }
}
