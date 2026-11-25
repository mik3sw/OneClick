//
//  HotKeyCenter.swift
//  OneClick
//

import Carbon.HIToolbox
import Observation

/// Registers global keyboard shortcuts with the system and runs the matching item.
///
/// Uses Carbon's `RegisterEventHotKey`, which works in any app without the
/// Accessibility permission that a global key monitor would need.
@Observable
final class HotKeyCenter {
    static let shared = HotKeyCenter()

    @ObservationIgnored private var registered: [UInt32: (ref: EventHotKeyRef, target: ItemReference)] = [:]
    @ObservationIgnored private var bindings: [(HotKey, ItemReference)] = []
    @ObservationIgnored private var nextID: UInt32 = 1
    @ObservationIgnored private var handler: EventHandlerRef?
    @ObservationIgnored private var suspendCount = 0
    @ObservationIgnored private var onTrigger: ((ItemReference) -> Void)?

    /// Shortcuts the system refused because another app already uses them.
    private(set) var conflicts: Set<HotKey> = []

    private init() {}

    /// Starts listening, registering every shortcut in `preferences` and re-registering when they change.
    func start(preferences: Preferences, onTrigger: @escaping (ItemReference) -> Void) {
        self.onTrigger = onTrigger
        installHandler()
        observe(preferences)
    }

    /// Temporarily unregisters every shortcut, e.g. while recording a new one.
    func suspend() {
        suspendCount += 1
        if suspendCount == 1 { unregisterAll() }
    }

    func resume() {
        suspendCount = max(0, suspendCount - 1)
        if suspendCount == 0 { registerAll() }
    }

    private func observe(_ preferences: Preferences) {
        withObservationTracking {
            bindings = preferences.shortcutBindings
        } onChange: { [weak self] in
            Task { @MainActor in self?.observe(preferences) }
        }
        if suspendCount == 0 { registerAll() }
    }

    private func registerAll() {
        unregisterAll()
        var refused: Set<HotKey> = []
        for (hotKey, target) in bindings {
            let id = nextID
            nextID &+= 1
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(
                hotKey.keyCode, hotKey.carbonModifiers,
                EventHotKeyID(signature: hotKeySignature, id: id),
                GetApplicationEventTarget(), 0, &ref)
            if status == noErr, let ref {
                registered[id] = (ref, target)
            } else {
                refused.insert(hotKey)
            }
        }
        conflicts = refused
    }

    private func unregisterAll() {
        for entry in registered.values {
            UnregisterEventHotKey(entry.ref)
        }
        registered.removeAll()
    }

    fileprivate func fire(_ id: UInt32) {
        guard suspendCount == 0, let target = registered[id]?.target else { return }
        onTrigger?(target)
    }

    private func installHandler() {
        guard handler == nil else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventType, nil, &handler)
    }
}

/// "OnCl", marks the shortcuts registered by OneClick.
nonisolated private let hotKeySignature: OSType = 0x4F6E_436C

/// Carbon calls this on the main thread when a registered shortcut is pressed.
nonisolated private func hotKeyHandler(_: EventHandlerCallRef?, event: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus {
    guard let event else { return OSStatus(eventNotHandledErr) }
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
        nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
    guard status == noErr, hotKeyID.signature == hotKeySignature else {
        return OSStatus(eventNotHandledErr)
    }
    let id = hotKeyID.id
    Task { @MainActor in
        HotKeyCenter.shared.fire(id)
    }
    return noErr
}
