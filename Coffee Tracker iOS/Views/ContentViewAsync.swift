/*
 
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 A wrapper view that instantiates the coffee tracker view and the data for the hosting controller.
 
*/

import SwiftUI
import os


struct ContentViewAsync: View {
    
    let logger = Logger(subsystem: "splitio-examples.Coffee-Tracker-iOS.Views.ContentViewAsync", category: "Root View")
    
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
                        
                        // Make sure the app has requested authorization.
                        let model = CoffeeDataAsync.shared
                        
                        if #available(iOS 15, *) {
                            Task {
                                let success = await model.healthKitController.requestAuthorization() // requires iOS 15+
                                
                                // Check for errors.
                                if !success { fatalError("(x) Unable to authorize HealthKit") }
                                
                                // Check for updates from HealthKit.
                                await model.healthKitController.loadNewDataFromHealthKit()
                            }
                        } else {
                            Task {
                                await model.healthKitController.requestAuthorization { (success) in // bizarre, since requestAuthorization is not async
                                    
                                    // Check for errors.
                                    if !success { fatalError("(x) Unable to authorize HealthKit") }
                                    
                                    // Check for updates from HealthKit.
                                    Task { await model.healthKitController.loadNewDataFromHealthKit() }
                                }
                            }
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
