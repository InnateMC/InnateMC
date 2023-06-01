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

public struct ScreenshotShareButton: NSViewRepresentable {
    var selectedItem: Screenshot?
    
    public func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: NSLocalizedString("share", comment: "Share"), target: context.coordinator, action: #selector(Coordinator.buttonClicked))
        context.coordinator.button = button
        button.bezelStyle = .rounded
        button.controlSize = .regular
        button.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }
    
    public func updateNSView(_ nsView: NSButton, context: Context) {
        context.coordinator.selectedItem = self.selectedItem
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(selectedItem: selectedItem)
    }
    
    public class Coordinator: NSObject {
        let delegate: ImgurSharingServiceDelegate = .init()
        var selectedItem: Screenshot?
        var button: NSButton?
        
        init(selectedItem: Screenshot?) {
            self.selectedItem = selectedItem
            super.init()
        }
        
        @objc func buttonClicked() {
            guard let selectedItem = selectedItem else {
                return
            }
            
            let sharingItems = [selectedItem.path as Any]
            let sharingServicePicker = NSSharingServicePicker(items: sharingItems)
            sharingServicePicker.delegate = self.delegate
            sharingServicePicker.show(relativeTo: .zero, of: button!, preferredEdge: .minY)
        }
    }
}
