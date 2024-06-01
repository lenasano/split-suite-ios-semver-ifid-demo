/*
  CoffeeTrackeriOSApp.swift
  Coffee Tracker iOS

  Created by lena on 13/05/2024.

  Abstract:
  The entry point for the Coffee Tracker iOS app.
*/

import SwiftUI
import Foundation
import os

@main
struct CoffeeTrackeriOSApp: App {
    @StateObject private var split = SplitWrapper.instance
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ContengView", category: "Root View")
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                let isAsync = split.evaluateFeatureFlagUsingAttributes(SplitWrapper.flag.isAsyncOn)!
                
                if( isAsync.starts(with: "on") ) {
                    ContentViewAsync()
                } else {
                    ContentView()
                }
            }
            .onAppear() {
                logger.debug("App appeared!")
            }
            .disabled(!split.isReady && !split.isReadyTimedOut)
            .overlay(loadingOverlay)
            .environment(\.colorScheme, .dark)
            //.environmentObject(split) - we can pass the SplitWrapper to descendant views, but it's not needed in this demo
        }
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if !split.isReady && !split.isReadyTimedOut {
            ProgressView()
        
        }
    }
}

