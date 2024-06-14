/*
 
 Abstract:
 The wrapper that interfaces with the Split SDK and ensures that a
 SplitFactory is instantiated only once per session.
 
*/

import iOSSplitSuite
import Foundation
import os
import UIKit



class SplitWrapper /*: ObservableObject*/ {
    
    let logger = Logger(subsystem: "splitio-examples.Coffee-Tracker-iOS.Controllers.SplitWrapper", category: "Split")
    
    // MARK: - Strings that are also used in Split UI (exact match)
    
    struct flag {
        static let appVersion = "coffee_tracker_app_version"
        static let isAsyncOn  = "coffee_tracker_async_features"
    }

    struct flagAttribute {
        static let appVersion = "app_version"
        static let osVersion  = "os_version"
        static let osName     = "os_name"
    }

    // MARK: - SplitWrapper implementation
    
    static let instance: SplitWrapper = {
        return SplitWrapper()
    }()

    private let suite: SplitSuite
    
    //@Published var isReady: Bool = false
    //@Published var isReadyTimedOut: Bool = false
    
    // Retrieve the SDK API key
    // This is the front-end (client-side) Split API Key.
    // You first need to store this variable in your Swift project Scheme:
    // In Xcode, click Product | Scheme | Edit Scheme... | Run | Arguments, and add
    // a "SplitSdkApiKey" environment variable.
    
    private let sdkApiKey = ProcessInfo.processInfo.environment["SplitSdkApiKey"]

    private init() {
        
        // Define the config settings for the Split client
        
        let userID = Key(matchingKey: UUID().uuidString)    // Generates a unique UUIDs for testing during development or staging. This simulates multiple users.
                                                            // When the app is released (i.e. production), this key should be unique to each user. This would allow
                                                            // a smooth experience from each user's perspective (minimal feature on-off toggling).
        
        let clientConfig = SplitClientConfig()
        clientConfig.logLevel = .verbose
        clientConfig.sdkReadyTimeOut = 1000  // set the time limit (in milliseconds) for Split definitions to be downloaded and enable the .sdkReadyTimedOut event
        
        // Initialize the Split instance and start downloading Split feature flag
        // and segment definitions from Split cloud
        
        // ATTENTION: this next line is crashing at runtime
        suite = DefaultSplitSuite.builder() // NOTE: different from docs!
            .setApiKey(sdkApiKey!)
            .setKey(userID)
            .setConfig(clientConfig)
            .build()!
        
        // Handle the sdkReadyTimeOut event
        /* TODO: try here
        suite.client.on(event: .sdkReadyTimedOut) { [weak self] in
            guard let self = self else { return }

            // The .sdkReadyTimedOut event fires when
            // (1) the Split SDK has reached the time limit for downloading the
            //     Split definitions, AND
            // (2) the Split definitions have also not been cached.
            
            / * DispatchQueue.main.async {
                self.isReadyTimedOut = true
            }* /
        }
        
        // Handle the sdkReady event
        
        suite.client.on(event: .sdkReady) { [weak self] in
            guard let self = self else { return }
            
            // Set a flag (a @Published var) when the Split definitions are
            // downloaded.
            
            / * DispatchQueue.main.async {
                self.isReady = true
            }* /
        
            // Evaluate a Split feature flag to enable Split to distinguish Real User
            // Monitoring (RUM) metrics for specific release versions of this app.
            // The results are visible in the Split UI, on the feature flag's Metric
            // impact tab.
            
            //_ = evaluateFeatureFlagUsingAttributes(flag.appVersion)
        } */
        
        // Tip: The following events can also be received:
        //    .sdkReadyFromCache - faster than .sdkReady
        //    .sdkUpdated        - when new split definitions are received
    }
    
    // MARK: - Split SDK Function Wrappers
    /*
    /// Retrieves the treatment for the given feature flag, as defined in the Split UI (https://app.split.io)
    /// Parameter: `flagName`: The name of the Split feature flag, as defined in the Split UI.
    /// Warning: If the Split definitions are not yet loaded, this function returns "CONTROL".
    @discardableResult
    func evaluateFeatureFlag(_ flagName: String) -> String {
        return suite.client.getTreatment(flagName)
    }
    
    /// Retrieves the treatment for the given feature flag, as defined in the Split UI (https://app.split.io)
    /// in Data Hub > Live Tail.
    /// Note: Real User Monitoring (RUM) metrics for each user session will be correlated to the flag variation.
    /// In the Split UI, if the feature flag targeting rules assign flag (treatment) results based on the attribute(s)
    /// you pass in, then Split can alert you about positive or negative RUM impacts correlated to your attribute(s).
    /// Parameter: `flagName`: The name of the Split feature flag, as defined in the Split UI.
    /// Warning: If the Split definitions are not yet loaded, this function returns "CONTROL".
    @discardableResult
    func evaluateFeatureFlagUsingAttributes(_ flagName: String) -> String? {

        var attributes: [String:Any] = [:]
        
        switch flagName {
            
        case flag.appVersion :
            // Pass the Coffee Tracker iOS App version as an attribute
            let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            attributes[flagAttribute.appVersion] = appVersion.toThreePointVersionNumber() ?? appVersion
            
            return suite.client.getTreatment(flag.appVersion, attributes: attributes)
        
        case flag.isAsyncOn :
            
            let systemVersion = UIDevice.current.systemVersion
            
            // Pass the running OS name and version as an attribute
            attributes[flagAttribute.osName   ] = UIDevice.current.systemName
            attributes[flagAttribute.osVersion] = systemVersion.toThreePointVersionNumber() ?? systemVersion
            
            return suite.client.getTreatment(flag.isAsyncOn, attributes: attributes)
        
        default:
            logger.warning("evaluateFeatureFlagUsingAttribute method warning: No attributes are defined for \(flagName)")
            return nil
        }
        
    }
    
    /// Sends an event to Split cloud where it is logged, viewable in the Split UI (https://app.split.io)
    /// in Data Hub > Live Tail.
    /// Parameter: `event`: The string that will be displayed as the event name.
    /// Note: In the Split UI, you can define metrics to measure the events you send to Split cloud. Split associates the event with each active feature flag and displays the events
    /// captured for each feature flag variation (treatment) on the given feature flag's 'Metrics impact' tab.
    func trackEventForDefaultTrafficType(_ event: String) -> String {
        return
            suite.client.track(trafficType: "user", eventType: event)
                .description
    }
    
    /// Sends an event to Split cloud where it is logged (viewable in the Split UI | Data Hub | Live Tail).
    /// Important: A copy of this event is sent for the traffic type of all instantiated `SplitSuite` clients.
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
    } */
}
