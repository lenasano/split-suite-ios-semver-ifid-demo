/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A delegate object for the WatchKit extension that implements the needed life cycle methods.
*/

import WatchKit
import os

// The app's extension delegate.
class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    let logger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.ExtensionDelegate",
                        category: "Extension Delegate")
    
    // MARK: - Delegate Methods
    
    // Called when a background task occurs.
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        logger.debug("Handling a background task...")
        logger.debug("App State: \(WKExtension.shared().applicationState.rawValue)")
        
        for task in backgroundTasks {
            logger.debug("Task: \(task)")
            
            switch task {
            // Handle background refresh tasks.
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                if #available(watchOS 8, *) {   // compile time condition (todo confirm)
                    
                    // use a feature flag to implement gradual rollout of implementation using swift concurrency
                    
                    if (true) { Task{ await checkForUpdatesFromHealthKitAsync(backgroundTask: backgroundTask) } }
                    else      {             checkForUpdatesFromHealthKit     (backgroundTask: backgroundTask)   }
                }
                else {
                                            checkForUpdatesFromHealthKit     (backgroundTask: backgroundTask)
                }
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    private func checkForUpdatesFromHealthKit(backgroundTask:WKApplicationRefreshBackgroundTask) {
        
        let model = CoffeeData.shared
        
        model.healthKitController.loadNewDataFromHealthKit { success in
            
            if success {
                // Schedule the next background update.
                scheduleBackgroundRefreshTasks()
                self.logger.debug("Background Task Completed Successfully!")
            }
            
            // Mark the task as ended, and request an updated snapshot, if necessary.
            backgroundTask.setTaskCompletedWithSnapshot(success)
        }
    }
    
    private func checkForUpdatesFromHealthKitAsync(backgroundTask:WKApplicationRefreshBackgroundTask) async {

        let model = CoffeeDataAsync.shared
        
        let success = await model.healthKitController.loadNewDataFromHealthKit()
        
        if success {
            // Schedule the next background update.
            scheduleBackgroundRefreshTasks()
            self.logger.debug("Background Task Completed Successfully!")
        }
        
        // Mark the task as ended, and request an updated snapshot, if necessary.
        backgroundTask.setTaskCompletedWithSnapshot(success)
        
    }
}

// Schedule the next background refresh task.

let scheduleLogger = Logger(subsystem: "com.example.apple-samplecode.Coffee-Tracker.watchkitapp.watchkitextension.scheduleLogger",
                            category: "Scheduler")

func scheduleBackgroundRefreshTasks() {
    
    scheduleLogger.debug("Scheduling a background task.")
    
    // Get the shared extension object.
    let watchExtension = WKExtension.shared()
    
    // If there is a complication on the watch face, the app should get at least four
    // updates an hour. So calculate a target date 15 minutes in the future.
    let targetDate = Date().addingTimeInterval(15.0 * 60.0)
    
    // Schedule the background refresh task.
    watchExtension.scheduleBackgroundRefresh(withPreferredDate: targetDate, userInfo: nil) { (error) in
        
        // Check for errors.
        if let error = error {
            scheduleLogger.error("An error occurred while scheduling a background refresh task: \(error.localizedDescription)")
            return
        }
        
        scheduleLogger.debug("Task scheduled!")
    }
}
