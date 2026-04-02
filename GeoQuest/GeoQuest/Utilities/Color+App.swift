//
//  Color+App.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 02/04/2026.
//
import SwiftUI

extension Color {
    static let gqForestGreen = Color(hex: "#2D5A1B")
    static let gqLeafGreen   = Color(hex: "#4A8C2A")
    static let gqDeepBark    = Color(hex: "#1A3A0F")
    static let gqTrailAmber  = Color(hex: "#8B6914")
    static let gqSand        = Color(hex: "#C4924A")
    static let gqParchment   = Color(hex: "#F5F0E8")
    static let gqMoss        = Color(hex: "#A8C88A")
    static let gqCacheRed    = Color(hex: "#D94F2B")
    static let gqGoldReward  = Color(hex: "#F5C842")
    static let gqLightStone  = Color(hex: "#E8E0D0")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
