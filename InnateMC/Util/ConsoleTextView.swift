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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import SwiftUI

import SwiftUI

struct ConsoleTextView: NSViewRepresentable {
    typealias NSViewType = NSTextView
    
    var text: String
    var layoutManager: NSLayoutManager
    var textContainer: NSTextContainer
    var font: NSFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.minSize = NSSize(width: 200, height: 50)
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = font
        textView.alignment = NSTextAlignment.natural
        textView.string = text
        textView.allowsUndo = false
        textView.textContainer = self.textContainer
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        self.textContainer.layoutManager = self.layoutManager
        nsView.string = text
        nsView.font = font
        nsView.textContainer = self.textContainer
    }
}

struct ConsoleTextView_Previews: PreviewProvider {
    static var ints = Array(1...10)
    static let layoutManager = NSLayoutManager()
    static let textContainer: NSTextContainer = {
        var cont = NSTextContainer()
        layoutManager.addTextContainer(cont)
        layoutManager.allowsNonContiguousLayout = true
        return cont
    }()

    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(ints, id: \.self) { i in
                ConsoleTextView(text: "This is console text \(i)", layoutManager: layoutManager, textContainer: textContainer)
            }
        }
    }
}
