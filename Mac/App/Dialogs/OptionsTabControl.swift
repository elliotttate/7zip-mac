// Native macOS preference tabs. All existing page controllers and Apply/Cancel behavior remain.
import AppKit

final class OptionsTabControl: NSView {
    var onSelect: ((Int) -> Void)?
    private(set) var titles: [String] = []
    private(set) var selectedIndex = 0
    private let segments = NSSegmentedControl()
    static let tabTop: CGFloat = 0
    static let tabHeight: CGFloat = 28
    static let panelTop: CGFloat = 36
    static let frameColor = NSColor.separatorColor
    static let shadowColor = NSColor.clear
    static let tabFill = NSColor.controlBackgroundColor
    static let pageFill = NSColor.windowBackgroundColor

    override var isFlipped: Bool { true }

    override init(frame: NSRect) {
        super.init(frame: frame)
        segments.segmentStyle = .rounded
        segments.trackingMode = .selectOne
        segments.controlSize = .small
        segments.font = .systemFont(ofSize: 12)
        segments.target = self
        segments.action = #selector(selectedTab)
        segments.setAccessibilityLabel("Settings pages")
        addSubview(segments)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func setTitles(_ newTitles: [String]) {
        titles = newTitles
        segments.segmentCount = titles.count
        for (index, title) in titles.enumerated() { segments.setLabel(title, forSegment: index) }
        select(min(selectedIndex, max(0, titles.count - 1)))
        needsLayout = true
    }
    func select(_ index: Int) {
        guard titles.indices.contains(index) else { return }
        selectedIndex = index
        segments.selectedSegment = index
    }
    @objc private func selectedTab() {
        select(segments.selectedSegment)
        onSelect?(selectedIndex)
    }
    static func tabWidth(_ title: String) -> CGFloat {
        max(42, ceil((title as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: 12)]).width) + 20)
    }
    func tabRects() -> [NSRect] {
        var x: CGFloat = 0
        let total = max(1, titles.map(Self.tabWidth).reduce(0, +))
        let fit = min(1, bounds.width / total)
        return titles.map {
            let width = Self.tabWidth($0) * fit
            defer { x += width }
            return NSRect(x: x, y: 0, width: width, height: Self.tabHeight)
        }
    }
    override func layout() {
        super.layout()
        let widths = titles.map(Self.tabWidth)
        let total = max(1, widths.reduce(0, +))
        let fit = min(1, bounds.width / total)
        for (index, width) in widths.enumerated() { segments.setWidth(width * fit, forSegment: index) }
        segments.frame = NSRect(x: max(0, (bounds.width - total * fit) / 2), y: 0,
                                width: min(bounds.width, total), height: Self.tabHeight)
    }
}
