//
//  GeoQuestApp.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 02/04/2026.
//

import SwiftUI

@main
struct GeoQuestApp: App {
    @AppStorage("loggedInUserID") private var loggedInUserID = 0
    
    var body: some Scene {
        WindowGroup {
            if loggedInUserID == 0 {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
