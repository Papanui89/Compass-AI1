//
//  ContentView.swift
//  Compass AI
//
//  Created by Luis Carlos Cadena Alvarez on 7/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var emergencyViewModel = EmergencyViewModel()
    
    var body: some View {
        NavigationView {
            EmergencyView()
                .environmentObject(appState)
                .environmentObject(emergencyViewModel)
        }
        .onAppear {
            emergencyViewModel.recordAppOpen()
        }
    }
}

#Preview {
    ContentView()
}
