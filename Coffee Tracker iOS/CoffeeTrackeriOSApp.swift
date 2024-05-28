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
    @StateObject private var split = SplitWrapper.instance
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ContengView", category: "Root View")
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                // TODO: use attributes here to pass the iOSVersion so that the rollout
                // can be version-granular
                let isAsync = split.evaluateFeatureFlag(SplitWrapper.flag.iOSVersion)
                
                if( "on" == isAsync ) {
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
            .disabled(!split.isReady && !split.isReadyTimedOut)
            .overlay(loadingOverlay)
            .environment(\.colorScheme, .dark)
            //.environmentObject(split)
        }
    }
    
    @ViewBuilder private var loadingOverlay: some View {
        if !split.isReady && !split.isReadyTimedOut {
            ProgressView()
        
        }
    }
}
