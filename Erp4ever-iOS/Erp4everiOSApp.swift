//
//  Erp4everiOSApp.swift
//  Erp4everiOSApp
//
//  Created by OhChangEun on 9/29/25.
//

import SwiftUI

@main
struct Erp4everiOSApp: App {
    @StateObject private var session = SessionManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
