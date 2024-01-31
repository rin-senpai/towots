//
//  TowotsApp.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import SwiftUI
import TootSDK

@main
struct TowotsApp: App {
    @StateObject var tootManager: TootManager = TootManager()

    @State var isActive: Bool = false
    @State var authIsPresented: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isActive {
                    if authIsPresented {
                        AuthorizeView()
                    } else {
                        ContentView()
                    }
                } else {
                    Text("splash splash")
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isActive = true
                        authIsPresented = !tootManager.authenticated
                    }
                }
            }
            .onChange(of: tootManager.authenticated) {
                withAnimation {
                    authIsPresented = !tootManager.authenticated
                }
            }
            .environmentObject(tootManager)
        }
    }
}
