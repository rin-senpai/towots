//
//  ContentView.swift
//  Towots
//
//  Created by りん on 28/1/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
//                SearchView()
            Text("ah yes such search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            Text("The notifications of all time")
                .tabItem {
                    Label("Activity", systemImage: "heart")
                }
            
//                UserAccountView()
            Text("most account settings of all time")
                .tabItem {
                    Label("Me", systemImage: "person")
                }
        }
    }
}

#Preview {
    ContentView()
}
