//
//  SplitWrapper.swift
//
//  The wrapper that interfaces with the Split SDK and ensures that a
//  SplitFactory is instantiated only once per session.
//
//  Coffee Tracker WatchKit Extension
//
//  Created by lena on 09/05/2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import iOSSplitSuite


class SplitWrapper: ObservableObject {

    static let instance: SplitWrapper = {
        return SplitWrapper()
    }()

    private let suite: SplitSuite
    
    @Published var isReady: Bool = false
    @Published var isReadyTimedOut: Bool = false
    
    // Retrieve the SDK API key
    // This is the front-end (client-side) Split API Key.
    // You first need to store this variable in your Swift project Scheme:
    // click Product | Scheme | Edit Scheme... | Run | Arguments, and add
    // a "SplitSdkApiKey" environment variable.
    private let sdkApiKey = ProcessInfo.processInfo.environment["SplitSdkApiKey"]

    private init() {
        
        // Define the config settings for the Split client
        
        let userID = Key(matchingKey: UUID().uuidString)
        
        let clientConfig = SplitClientConfig()
        clientConfig.logLevel = .verbose
        clientConfig.sdkReadyTimeOut = 1000  // set the time limit (in milliseconds) for Split definitions to be downloaded and enable the .sdkReadyTimedOut event
        
        // Initialize the Split instance and start downloading Split feature flag
        // and segment definitions from Split cloud
        
        suite = DefaultSplitSuite.builder() // TODO: different from docs!
            .setApiKey(sdkApiKey!)
            .setKey(userID)
            .setConfig(clientConfig)
            .build()!
        
        // Handle the sdkReadyTimeOut event
        
        suite.client.on(event: .sdkReadyTimedOut) { [weak self] in
            guard let self = self else { return }

            // The .sdkReadyTimedOut event fires when
            // (1) the Split SDK has reached the time limit for downloading the
            //     Split definitions, AND
            // (2) the Split definitions have also not been cached.
            
            DispatchQueue.main.async {
                self.isReadyTimedOut = true
            }
        }
        
        // Handle the sdkReady event
        
        suite.client.on(event: .sdkReady) { [weak self] in
            guard let self = self else { return }
            
            // Set a flag (a @Published var) when the Split definitions are
            // downloaded.
            
            DispatchQueue.main.async {
                self.isReady = true
            }
        
            // Evaluate a Split feature flag to enable Split to monitor Real User
            // Monitoring (RUM) metrics for distinct release versions of this app
            
            var attributes: [String:Any] = [:]
            attributes["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
            
            // pass in the attribute to set the flag for this user id
            _ = evaluateFeatureFlagUsingAttributes("FEATURE_FLAG_NAME", attributes: attributes)
        }
        
        // Tip: The following events can also be received:
        //    .sdkReadyFromCache - faster than .sdkReady
        //    .sdkUpdated        - when new split definitions are received
    }
    
    // MARK: - Split SDK Function Wrappers
    
    /// Retrieves the treatment for the given feature flag (split), as defined in the Split Management
    /// Console.
    /// Parameter: `split`: The name of the split, as defined in the Split Management Console.
    /// Warning: If the Split definitions were not loaded yet, this function will return "CONTROL".
    @discardableResult
    func evaluateFeatureFlag(_ flagName: String) -> String {
        return suite.client.getTreatment(flagName)
    }
    
    /// Retrieves the treatment for the given feature flag (split), as defined in the Split Management
    /// Console.
    /// Parameter: `split`: The name of the split, as defined in the Split Management Console.
    /// Warning: If the Split definitions were not loaded yet, this function will return "CONTROL".
    @discardableResult
    func evaluateFeatureFlagUsingAttributes(_ flagName: String, attributes: [String:Any]) -> String {
        return suite.client.getTreatment(flagName, attributes:attributes)
    }
    
    /// Sends an event to Split Cloud where it is logged.
    /// Parameter: `event`: The string that will be displayed as the event name.
    /// Important: Split associates the event with each active feature flag and displays the events
    /// captured for each feature flag treatment (variation) on the given feature flag's 'Metrics impact' tab.
    func trackEventForDefaultTrafficType(_ event: String) -> String {
        return
            suite.client.track(trafficType: "user", eventType: event)
                .description
    }
    
    /// Sends an event to Split Cloud where it is logged. A copy of this event is sent for the traffic type of all
    /// instantiated SplitSuite clients.
    /// Parameter: `event`: The string that will be displayed as the event name.
    /// Important: Split associates the event with each active feature flag and displays the events
    /// captured for each feature flag treatment (variation) on the given feature flag's 'Metrics impact' tab.
    func trackEventForAllTrafficTypes(_ event: String) -> String {
        return
            suite.track(eventType: event, value: nil, properties: nil) //todo: different than docs! -- value is needed
                .description
    }
    
    /// Sends the data stored in memory (impressions and events) to Split cloud and clears the successfully
    /// posted data. If a connection issue is experienced, the data will be sent on the next attempt.
    func flush() {
        return suite.client.flush()       // todo: why return? does this compile?
    }
    
    deinit {
        destroy()
    }
    
    /// Gracefully shuts down the Split SDK by stopping all background threads, clearing caches, closing
    /// connections, and flushing the remaining unpublished impressions and events.
    private func destroy() {
        return suite.client.destroy()     // return??
    }
}
