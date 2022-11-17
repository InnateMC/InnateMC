//
//  ContentView.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/14/22.
//

import SwiftUI

struct ContentView: View {
    @State public var searchTerm: String = ""
    
    var body: some View {
        VStack {
            NavigationView {
                TextField("Search...", text: $searchTerm)
                    .padding(.all, 6)
                List(InnateMCData.instances) { instance in
                    NavigationLink(instance.name, destination: Text(instance.name))
                }
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
