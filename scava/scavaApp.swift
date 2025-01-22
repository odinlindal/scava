//
//  scavaApp.swift
//  scava
//
//  Created by Odin Lindal on 1/19/25.
//

import SwiftUI

@main
struct scavaApp: App {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
        }
    }
}
