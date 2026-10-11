# Native macOS design

The October 11, 2026 design revision follows the user's request for a polished macOS
interface. It replaces Windows pixel matching as the visual goal while retaining
the archive engine, commands, keyboard shortcuts, language support, view modes,
saved column layouts, and two-panel operation.

- AppKit owns the unified title-bar toolbar, overflow, customization, and accessibility.
- A translucent source-list sidebar opens Home, Desktop, Documents, Downloads,
  Applications, the filesystem root, and mounted volumes in the active panel.
  It can be hidden from the toolbar and collapses in narrow windows.
- File rows use SF Pro, blue vector folders, rounded system-accent selections,
  alternating backgrounds, and the user's macOS scrollbar preference.
- Fresh column layouts show the name, size, modification time, and packed size
  where available. All other properties remain in the column menu; saved layouts
  retain the user's choices.
- Settings uses native segmented tabs and pop-up controls. Dialogs have more
  vertical space, a system-accent progress indicator, and native background colors.
- Fresh installations follow the system appearance. Explicit Light/Dark choices
  remain in effect.

## Original artwork

The Dock icon, archive document family, toolbar paths, and blue folders are original
artwork dedicated under [CC0](../Mac/Resources/Icons/LICENSE.md). The generator
draws each required size independently, from 16 to 1024 pixels, with no third-party
dependencies or paid assets. System sidebar symbols are supplied by macOS.

`Mac/scripts/make-icons.sh` regenerates the artwork, assembles the asset catalog
and Finder document icons, renders a contact sheet, and checks transparency,
dimensions, nonblank pixels, and the packaged representations. Small ICNS slots
allow the color quantization introduced by Apple's `iconutil`.

## Verification

The app builds with warnings treated as errors. The engine suite passes 451 tests
on each of arm64 and x86_64 (five platform-specific tests are skipped per run).
The 50 passing focused AppKit checks cover dialog layout, menus, multi-window
behavior, archive commands, the new native controls, and this repository's updater.
The icon pipeline verifies 203 PNGs and 280 packaged ICNS representations.

`NativeMacDesignTests` exercises keyboard sidebar actions, Back/Forward toolbar
actions, the seven archive/file commands, sidebar visibility, narrow-window
resizing, and two-panel layout. It renders the complete window in Light and Dark
to `Mac/build/screenshots/native-macos-{light,dark}.png`.

`Mac/scripts/showcase.sh --no-ui` renders the compression, extraction, and Settings
dialogs. The historical `WinMatch`, `ListFeel`, `SFFont`, `Recheck`, and related
pixel-comparison tests encode the previous Windows appearance. Their pixel,
geometry, font-size, icon, and default-column assertions need migration to this
design; they should not be used to restore the old presentation.

The opt-in `ShowcaseUITests/testNativeMacWindows` captures the running app through
XCUITest. The current machine refused to initialize that runner with
"Authentication canceled. System authentication is running." No live UI test
ran in that attempt; the previews above come from the passing app-hosted renders.

Use the Xcode installation present on the machine via `DEVELOPER_DIR`. This
machine uses `/Applications/Xcode-beta.app`; the global Xcode selection is unchanged.
