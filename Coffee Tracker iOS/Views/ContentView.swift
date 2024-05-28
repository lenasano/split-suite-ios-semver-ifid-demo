/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A wrapper view that instantiates the coffee tracker view and the data for the hosting controller.
*/

import SwiftUI
import os

struct ContentView: View {
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ContengView", category: "Root View")
    
    @Environment(\.scenePhase) private var scenePhase
    
    // Access the shared model object.
    let data = CoffeeData.shared
    
    // Access the shared model object.
    //let data = CoffeeData.shared
    
    // Create the main view, and pass the model.
    var body: some View {
        VStack {
            Spacer()
            if #available(iOS 15, *) {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(.brown)
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
            } else {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(Color(red: 0.6, green: 0.5, blue: 0.4)) // brown
                    .imageScale(.large)
            }
            Text("Coffee Tracker")
            Spacer()
            CoffeeTrackerView()
                .environmentObject(data)
                .onChange(of: scenePhase) { (phase) in
                    switch phase {
                        
                    case .inactive:
                        logger.debug("Scene became inactive.")
                        
                    case .active:
                        logger.debug("Scene became active.")
                        
                        // Make sure the app has requested authorization.
                        let model = CoffeeData.shared
                        model.healthKitController.requestAuthorization { (success) in
                            
                            // Check for errors.
                            if !success { fatalError("(x) Unable to authorize HealthKit") }
                            
                            // Check for updates from HealthKit.
                            model.healthKitController.loadNewDataFromHealthKit { _ in }
                        }
                        
                    case .background:
                        logger.debug("Scene moved to the background.")
                        
                        // Schedule a background refresh task
                        // to update the complications.
                        // TODO: figure out: cannot find 'scheduledBackgroundRefreshTasks'
                        // scheduleBackgroundRefreshTasks()
                        
                    @unknown default:
                        logger.debug("Scene entered unknown state.")
                        assertionFailure()
                    }
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
