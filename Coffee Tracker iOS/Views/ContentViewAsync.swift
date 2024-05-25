/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A wrapper view that instantiates the coffee tracker view and the data for the hosting controller.
*/

import SwiftUI
import os

@available(iOS 15, *)   // TODO: model.healthKitController.requestAuthorization only available for iOS 15+
struct ContentViewAsync: View {
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ContengView", category: "Root View")
    
    @Environment(\.scenePhase) private var scenePhase
    
    // Access the shared model object.
    let data: CoffeeDataAsync
    
    @MainActor
    init() {
        data = CoffeeDataAsync.shared
    }
    
    // Create the main view, and pass the model.
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.brown)
                .imageScale(.large)
                // .foregroundStyle(.tint) TODO: only available in iOS 15+
            Text("Coffee Tracker .async")
            Spacer()
            CoffeeTrackerViewAsync()
                .environmentObject(data)
                .onChange(of: scenePhase) { (phase) in
                    switch phase {
                    
                    case .inactive:
                        logger.debug("Scene became inactive.")
                    
                    case .active:
                        logger.debug("Scene became active.")
                        
                        Task {
                            // Make sure the app has requested authorization.
                            let model = CoffeeDataAsync.shared
                            let success = await model.healthKitController.requestAuthorization()
                            
                            // Check for errors.
                            if !success { fatalError("*** Unable to authenticate HealthKit ***") }
                            
                            // Check for updates from HealthKit.
                            await model.healthKitController.loadNewDataFromHealthKit()
                        }
                        
                    case .background:
                        logger.debug("Scene moved to the background.")
                        
                        // Schedule a background refresh task
                        // to update the complications.
                        // TODO: cannot find 'scheduleBackgroundRefreshTasks'
                        //scheduleBackgroundRefreshTasks()
                        
                    @unknown default:
                        logger.debug("Scene entered unknown state.")
                        assertionFailure()
                    }
                }
        }
        .padding()
    }
}

@available(iOS 15, *)
#Preview {
    ContentViewAsync()
}
