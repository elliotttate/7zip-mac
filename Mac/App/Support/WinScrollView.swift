// The shared scroll view follows the user's macOS scrollbar preference, including overlays.
// The historical class name is retained for the dialog and panel call sites.

import AppKit

class WinScrollView: NSScrollView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        super.scrollerStyle = NSScroller.preferredScrollerStyle
        autohidesScrollers = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.scrollerStyle = NSScroller.preferredScrollerStyle
        autohidesScrollers = true
    }

    override var scrollerStyle: NSScroller.Style {
        get { super.scrollerStyle }
        set { super.scrollerStyle = newValue }
    }
}
