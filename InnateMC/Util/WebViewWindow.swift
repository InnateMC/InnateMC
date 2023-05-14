//
// Copyright © 2022 InnateMC and contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import Cocoa
import SwiftUI
import WebKit

class WebViewWindow: NSWindowController {
    public static var current: WebViewWindow? = nil
    
    convenience init(url: URL) {
        let config: WKWebViewConfiguration = .init()
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView: WKWebView = .init(frame: .init(x: 0, y: 0, width: 400, height: 600), configuration: config)
        webView.load(URLRequest(url: url))
        let window: NSWindow = .init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 600), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.contentView = webView
        window.title = NSLocalizedString("login_with_microsoft", comment: "no u")
        self.init(window: window)
        Self.current = self
    }
}
