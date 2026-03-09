//
//  MemoryAnchorApp.swift
//  MemoryAnchor
//
//  Created by Jayneel Jariwala on 09/03/26.
//

import SwiftUI
import CoreData

@main
struct MemoryAnchorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
