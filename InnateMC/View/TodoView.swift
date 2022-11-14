//
//  TodoView.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/14/22.
//

import SwiftUI

struct TodoView: View {
    var body: some View {
        Text("TODO")
            .fontWeight(.bold)
            .foregroundColor(Color.red)
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView()
    }
}
