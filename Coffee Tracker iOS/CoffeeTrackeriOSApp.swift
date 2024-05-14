/*
  CoffeeTrackeriOSApp.swift
  Coffee Tracker iOS

  Created by lena on 13/05/2024.

  Abstract:
  The entry point for the Coffee Tracker iOS app.
*/

import SwiftUI
import os

@main
struct CoffeeTrackeriOSApp: App {
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ContengView", category: "Root View")
    var body: some Scene {
        WindowGroup {
            NavigationView {
                let isAsyncOn = true
                
                if( isAsyncOn ) {
                    if #available(iOS 15, *) {
                        ContentViewAsync()
                    } else {
                        ContentView()
                    }
                }
            }
            .onAppear() {
                logger.debug("App appeared!")
            }
        }
    }
}
