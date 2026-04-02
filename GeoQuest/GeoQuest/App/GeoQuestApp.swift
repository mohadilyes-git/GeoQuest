//
//  GeoQuestApp.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 02/04/2026.
//

import SwiftUI
import FirebaseCore

@main
struct GeoQuestApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
