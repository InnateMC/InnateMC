//
// Copyright © 2022 Shrish Deshpande
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

import Cocoa
import InnateKit

class LoadingSheetViewController: NSViewController {
    @IBOutlet var myView: NSView!
    private let instance: Instance
//    private lazy var progressBar: BruhProgressIndicator = BruhProgressIndicator()

    public init(instance: Instance, nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        self.instance = instance
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let progressBar = view.subviews.filter {
            ($0.identifier?.rawValue == "progressBar")
        }
        .first! as! BruhProgressIndicator
        let p = instance.downloadLibs(progress: CustomDownloadProgress(progress: progressBar, current: 0, total: 2)) {
        }
        progressBar.maxValue = Double(p.total)
        progressBar.minValue = 0
    }
}

public class BruhProgressIndicator: NSProgressIndicator {
    public var newValue: Double?

    public override func draw(_ dirtyRect: NSRect) {
        if let newValue = newValue {
            self.doubleValue = newValue
        }
        super.draw(dirtyRect)
    }
}

fileprivate class CustomDownloadProgress: DownloadProgress {
    private let progress: BruhProgressIndicator
    
    fileprivate init(progress: BruhProgressIndicator, current: Int, total: Int) {
        self.progress = progress
        super.init(current: current, total: total)
    }
}
