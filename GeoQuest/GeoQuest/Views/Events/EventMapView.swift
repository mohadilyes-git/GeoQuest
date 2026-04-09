//
//  EventMapView.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 10/04/2026.
//

import SwiftUI

struct EventMapView: View {
    let event: Event
    
    var body: some View {
        Text(event.eventName)
    }
}
