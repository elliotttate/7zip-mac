// macOS navigation addition; the underlying panel commands retain 01 §3.5 / §3.8.
import AppKit

final class MacSidebar: NSVisualEffectView, NSOutlineViewDataSource, NSOutlineViewDelegate {
    private final class Entry {
        let title: String
        let symbol: String
        let path: String?
        let children: [Entry]
        init(_ title: String, _ symbol: String = "", path: String? = nil, children: [Entry] = []) {
            self.title = title
            self.symbol = symbol
            self.path = path
            self.children = children
        }
    }

    private let outline = NSOutlineView()
    private let groups: [Entry] = [
        Entry("Favorites", children: [
            Entry("Home", "house", path: NSHomeDirectory()),
            Entry("Desktop", "desktopcomputer", path: NSHomeDirectory() + "/Desktop"),
            Entry("Documents", "doc", path: NSHomeDirectory() + "/Documents"),
            Entry("Downloads", "arrow.down.circle", path: NSHomeDirectory() + "/Downloads"),
            Entry("Applications", "square.stack.3d.up", path: "/Applications"),
        ]),
        Entry("Locations", children: [
            Entry("Macintosh HD", "internaldrive", path: "/"),
            Entry("Volumes", "externaldrive", path: "/Volumes"),
        ]),
    ]
    var onNavigate: ((String) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        material = .sidebar
        blendingMode = .behindWindow
        state = .followsWindowActiveState
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        outline.headerView = nil
        outline.backgroundColor = .clear
        outline.style = .sourceList
        outline.rowHeight = 32
        outline.intercellSpacing = NSSize(width: 0, height: 2)
        outline.focusRingType = .none
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("places"))
        outline.addTableColumn(column)
        outline.outlineTableColumn = column
        outline.dataSource = self
        outline.delegate = self
        outline.target = self
        outline.action = #selector(selectedPlace)
        outline.setAccessibilityLabel("Sidebar")
        outline.setAccessibilityIdentifier("macSidebar")
        scroll.documentView = outline
        addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        outline.reloadData()
        outline.expandItem(nil, expandChildren: true)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func select(path: String) {
        let normalized = (path as NSString).standardizingPath
        let row = (0..<outline.numberOfRows).first {
            guard let entry = outline.item(atRow: $0) as? Entry, let place = entry.path else { return false }
            return (place as NSString).standardizingPath == normalized
        }
        if let row { outline.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false) }
        else { outline.deselectAll(nil) }
    }

    @objc private func selectedPlace() {
        guard let entry = outline.item(atRow: outline.selectedRow) as? Entry, let path = entry.path else { return }
        onNavigate?(path)
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        (item as? Entry)?.children.count ?? groups.count
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        ((item as? Entry)?.children ?? groups)[index]
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        !(item as! Entry).children.isEmpty
    }
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        (item as! Entry).path == nil
    }
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        (item as! Entry).path != nil
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let entry = item as! Entry
        let cell = NSTableCellView()
        let label = NSTextField(labelWithString: entry.title)
        label.font = .systemFont(ofSize: entry.path == nil ? 11 : 13,
                                 weight: entry.path == nil ? .semibold : .regular)
        label.textColor = entry.path == nil ? .secondaryLabelColor : .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(label)
        cell.textField = label
        if entry.path != nil {
            let icon = NSImageView()
            icon.image = NSImage(systemSymbolName: entry.symbol, accessibilityDescription: entry.title)
            icon.contentTintColor = .controlAccentColor
            icon.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(icon)
            cell.imageView = icon
            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
                icon.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 18), icon.heightAnchor.constraint(equalToConstant: 18),
                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 9),
            ])
        } else { label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2).isActive = true }
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -4),
        ])
        return cell
    }
}
