//
//  RuntimePreferencesView.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/15/22.
//

import SwiftUI

struct RuntimePreferencesView: View {
    var body: some View {
            HStack {
                Form {
                    Toggle("Send read receipts", isOn: .constant(false))

                    TextField("Pls work", text: .constant("1826"))
                    
                    Picker("Profile Image Size:", selection: .constant("lg")) {
                        Text("Large").tag("lg")
                        Text("Medium").tag("md")
                        Text("Small").tag("sm")
                    }
                    .pickerStyle(.inline)

                    Button("Clear Image Cache") {}
                }
                
            }
            .padding(.all, 16.0)
    }
}

struct RuntimePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        RuntimePreferencesView()
    }
}
