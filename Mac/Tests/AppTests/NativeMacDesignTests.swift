import AppKit
import SevenZipKit
import XCTest
@testable import SevenZipAppHost

/// Exercise the visible native controls and render the complete window, including AppKit chrome.
final class NativeMacDesignTests: AppHostTestCase {
    private var controller: MainWindowController?
    private var savedPanels = 1
    private var savedToolbar: UInt32 = 0
    private var savedTheme: String?
    private var savedMode = 3
    private var savedColumns: Settings.ColumnLayout?
    private var savedSplitter = 0.5

    override func setUpWithError() throws {
        try super.setUpWithError()
        savedMode = Settings.listMode(0)
        savedSplitter = Settings.splitterPos
        Settings.splitterPos = 0.5
        savedColumns = Settings.columnLayout(forFolderType: "FSFolder")
        savedPanels = Settings.numPanels
        savedToolbar = Settings.toolbarsMask
        savedTheme = Settings.string(Settings.Key.theme)
        Settings.numPanels = 1
        Settings.toolbarsMask = 12
        Settings.setListMode(3, 0)
        Settings.removeKey("FM.Columns.FSFolder")
        controller = MainWindowController()
        controller?.window?.setContentSize(NSSize(width: 1040, height: 560))
        controller?.showWindow(nil)
    }

    override func tearDown() {
        controller?.closeDiscardingState()
        controller = nil
        Settings.setListMode(savedMode, 0)
        Settings.splitterPos = savedSplitter
        if let savedColumns { Settings.setColumnLayout(savedColumns, forFolderType: "FSFolder") }
        else { Settings.removeKey("FM.Columns.FSFolder") }
        Settings.numPanels = savedPanels
        Settings.toolbarsMask = savedToolbar
        Settings.setString(savedTheme, Settings.Key.theme)
        AppTheme.applyStored()
        super.tearDown()
    }

    private func find<T: NSView>(_ type: T.Type, in view: NSView?) -> T? {
        guard let view else { return nil }
        if let match = view as? T { return match }
        for child in view.subviews { if let match = find(type, in: child) { return match } }
        return nil
    }

    func testSidebarKeyboardActionAndToolbarHistory() throws {
        let main = try XCTUnwrap(controller)
        let outline = try XCTUnwrap(find(NSOutlineView.self, in: main.window?.contentView))
        // Keyboard selection has no clickedRow. The action must use selectedRow.
        outline.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
        XCTAssertTrue(NSApp.sendAction(try XCTUnwrap(outline.action), to: outline.target, from: outline))
        XCTAssertTrue(wait(for: "sidebar Home") { main.focusedPanel.currentPath.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == NSHomeDirectory().trimmingCharacters(in: CharacterSet(charactersIn: "/")) })
        outline.selectRowIndexes(IndexSet(integer: 4), byExtendingSelection: false)
        XCTAssertTrue(NSApp.sendAction(try XCTUnwrap(outline.action), to: outline.target, from: outline))
        XCTAssertTrue(wait(for: "sidebar Downloads") { main.focusedPanel.currentPath.contains("/Downloads") })
        let toolbar = try XCTUnwrap(main.window?.toolbar)
        let back = try XCTUnwrap(toolbar.items.first { $0.itemIdentifier == .szBack })
        XCTAssertTrue(NSApp.sendAction(try XCTUnwrap(back.action), to: back.target, from: back))
        XCTAssertTrue(wait(for: "toolbar Back") { main.focusedPanel.currentPath.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == NSHomeDirectory().trimmingCharacters(in: CharacterSet(charactersIn: "/")) })
        let forward = try XCTUnwrap(toolbar.items.first { $0.itemIdentifier == .szForward })
        XCTAssertTrue(NSApp.sendAction(try XCTUnwrap(forward.action), to: forward.target, from: forward))
        XCTAssertTrue(wait(for: "toolbar Forward") { main.focusedPanel.currentPath.contains("/Downloads") })
    }

    func testNativeWindowLightDarkAndTwoPanels() throws {
        try ShowcaseDemo.make()
        let main = try XCTUnwrap(controller)
        let window = try XCTUnwrap(main.window)
        var loaded = false
        main.focusedPanel.navigate(to: ShowcaseDemo.folder) { _ in loaded = true }
        XCTAssertTrue(wait(for: "demo listed") { loaded && main.focusedPanel.rows.count >= 10 })
        XCTAssertEqual(window.toolbarStyle, .unified)
        XCTAssertEqual(window.toolbar?.displayMode, .iconOnly)
        let commands = window.toolbar?.items.filter {
            [NSToolbarItem.Identifier.szAdd, .szExtract, .szTest, .szCopy, .szMove, .szDelete, .szInfo].contains($0.itemIdentifier)
        } ?? []
        XCTAssertEqual(commands.count, 7)
        XCTAssertTrue(commands.allSatisfy { $0.image != nil && $0.action != nil })
        let panel = main.focusedPanel
        if let row = panel.rows.firstIndex(where: { $0.name == "Project backup.7z" }) {
            panel.tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            panel.focusedIndex = row
        }
        panel.listFocusOverride = true
        defer { panel.listFocusOverride = nil }
        for theme in [AppTheme.light, .dark] {
            Settings.theme = theme
            panel.refreshSelectionAppearance()
            try render(window, name: "native-macos-\(theme.rawValue)")
        }
        main.switchOnOffOnePanel()
        XCTAssertEqual(main.visiblePanels.count, 2)
        window.contentView?.layoutSubtreeIfNeeded()
        XCTAssertTrue(wait(for: "two panels settle") {
            window.contentView?.layoutSubtreeIfNeeded()
            return main.visiblePanels.allSatisfy { $0.view.frame.width >= 120 }
        }, "panel widths: \(main.visiblePanels.map { $0.view.frame.width })")
        main.toggleSidebar(nil)
        window.contentView?.layoutSubtreeIfNeeded()
        XCTAssertTrue(wait(for: "sidebar collapse settles") {
            window.contentView?.layoutSubtreeIfNeeded()
            return main.visiblePanels.allSatisfy { $0.view.frame.width >= 120 }
        }, "panel widths: \(main.visiblePanels.map { $0.view.frame.width })")
        window.setContentSize(NSSize(width: 360, height: 260))
        window.contentView?.layoutSubtreeIfNeeded()
        XCTAssertTrue(main.visiblePanels.allSatisfy { $0.view.frame.width >= 120 })
    }

    func testVisibleToolbarOpensArchiveDialogs() throws {
        try ShowcaseDemo.make()
        let main = try XCTUnwrap(controller)
        let window = try XCTUnwrap(main.window)
        var loaded = false
        main.focusedPanel.navigate(to: ShowcaseDemo.folder) { _ in loaded = true }
        XCTAssertTrue(wait(for: "archive selection ready") { loaded })
        let row = try XCTUnwrap(main.focusedPanel.rows.firstIndex { $0.name == "Project backup.7z" })
        main.focusedPanel.setSelectedIndexes(IndexSet(integer: row))
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
        main.focusedPanel.focusList()
        for id in [NSToolbarItem.Identifier.szAdd, .szExtract] {
            let item = try XCTUnwrap(window.toolbar?.items.first { $0.itemIdentifier == id })
            XCTAssertTrue(ModalProbe.present(timeout: 20, {
                XCTAssertTrue(NSApp.sendAction(item.action!, to: item.target, from: item))
            }) { dialog in
                XCTAssertFalse(dialog.title.isEmpty)
                XCTAssertFalse(dialog === window)
            })
        }
    }

    private func render(_ window: NSWindow, name: String) throws {
        let view = try XCTUnwrap(window.contentView?.superview)
        view.layoutSubtreeIfNeeded()
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
        let deadline = Date().addingTimeInterval(0.25)
        while Date() < deadline { RunLoop.current.run(mode: .default, before: deadline) }
        window.displayIfNeeded()
        let rep = try XCTUnwrap(view.bitmapImageRepForCachingDisplay(in: view.bounds))
        window.effectiveAppearance.performAsCurrentDrawingAppearance {
            view.cacheDisplay(in: view.bounds, to: rep)
        }
        let data = try XCTUnwrap(rep.representation(using: .png, properties: [:]))
        try FileManager.default.createDirectory(atPath: TestPaths.screenshots, withIntermediateDirectories: true)
        try data.write(to: URL(fileURLWithPath: TestPaths.screenshots + "/" + name + ".png"))
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
