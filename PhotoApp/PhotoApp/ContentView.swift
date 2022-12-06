//
//  ContentView.swift
//  ImageMapApp
//
//  Created by William Chin on 11/8/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            homeView()
                .tabItem(){
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            editView()
                .tabItem(){
                    Image(systemName: "square.and.pencil")
                    Text("Edit Photos")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
