//
//  Compass_AIApp.swift
//  Compass AI
//
//  Created by Luis Carlos Cadena Alvarez on 7/27/25.
//

import SwiftUI

@main
struct Compass_AIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
