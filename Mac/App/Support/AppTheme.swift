// AppTheme.swift — macOS appearance. Fresh installations follow the system; an explicit
// Light or Dark preference remains authoritative. Applies to every window and dialog.

import AppKit

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    /// The `NSApp.appearance` the theme sets: nil follows the system.
    var appearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        }
    }

    // MARK: - the drop-down's texts (macOS addition: lang IDs of its own, see `langID`)

    /// Lang IDs outside every 7-Zip block (the official files stop at 7830s), so a translator can
    /// add them to a Lang/*.txt (a line "9900" then the four texts) and the built-in English is the
    /// fallback. "System" falls back to IDD_SYSTEM's caption (2200, "System"), which every official
    /// translation already carries.
    static let labelLangID: UInt32 = 9900
    var langID: UInt32 {
        switch self {
        case .system: return 9901
        case .light: return 9902
        case .dark: return 9903
        }
    }

    var fallbackTitle: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var title: String {
        if self == .system, Lang.translated(langID) == nil { return Lang.text(2200, fallbackTitle) }
        return Lang.text(langID, fallbackTitle)
    }

    static var labelText: String { Lang.text(labelLangID, "Theme:") }

    // MARK: - applying

    /// Sets `NSApp.appearance` from the stored theme.
    static func applyStored() {
        apply(Settings.theme)
    }

    static func apply(_ theme: AppTheme) {
        let wanted = theme.appearance
        guard NSApp.appearance?.name != wanted?.name else { return }
        NSApp.appearance = wanted
    }

    private static var observer: NSObjectProtocol?

    /// Called from `applicationWillFinishLaunching`, before any window exists. Also follows later
    /// writes of the key (the Options page's Apply) and a test reset (a keyless notification).
    static func applyAtLaunch() {
        applyStored()
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: Settings.Group.view.notificationName, object: nil, queue: nil) { note in
            let key = note.userInfo?[Settings.keyUserInfoKey] as? String
            guard key == nil || key == Settings.Key.theme else { return }
            if Thread.isMainThread { applyStored() } else { DispatchQueue.main.async { applyStored() } }
        }
    }
}

extension Settings.Key {
    /// macOS only: the app's appearance (`AppTheme`).
    static let theme = "FM.Theme"
}

extension Settings {
    /// The theme of a fresh install follows the Mac’s appearance.
    static let defaultTheme = AppTheme.system

    /// `FM.Theme` (macOS only): System, Light or Dark. Every choice is
    /// stored, System as "system", so it survives a later change of the default.
    static var theme: AppTheme {
        get { string(Key.theme).flatMap(AppTheme.init(rawValue:)) ?? defaultTheme }
        set { setString(newValue.rawValue, Key.theme) }
    }
}
