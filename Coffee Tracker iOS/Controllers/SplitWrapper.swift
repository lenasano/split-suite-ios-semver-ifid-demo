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

    @Published private var userConsentValue: Bool?
    
    private let sdkAPIKey = "[front-end (client-side) Split API Key goes here]" // todo: use env variable

    private init() {
        let userID = Key(matchingKey: UUID().uuidString)
        
        // todo: try? SplitRum.setup(apiKey: "hello")
        
        let clientConfig = SplitClientConfig()
        clientConfig.logLevel = .verbose
        clientConfig.sdkReadyTimeOut = 1000  // Set the time limit (in milliseconds) for Split definitions to be downloaded and enable the .sdkReadyTimedOut event.
        clientConfig.userConsent = UserConsent.unknown
        
        
        // todo: userConsentValue = nil
        
        suite = DefaultSplitSuite.builder() //todo: different from docs!
            .setApiKey(sdkAPIKey)
            .setKey(userID)
            .setConfig(clientConfig)
            .build()!
        
        suite.client.on(event: .sdkReadyTimedOut) { [weak self] in // todo: different from docs!
            guard let self = self else { return }

            // The .sdkReadyTimedOut event fires when
            // (1) the Split SDK has reached the time limit for downloading the
            //     Split definitions, AND
            // (2) the Split definitions have also not been cached.
            
            DispatchQueue.main.async {
                self.isReadyTimedOut = true
            }
        }
        
        suite.client.on(event: .sdkReady) { [weak self] in
            guard let self = self else { return }
            
            // Set a flag (a @Published var) when the Split definitions are
            // downloaded.
            
            DispatchQueue.main.async {
                self.isReady = true
            }
            
            // evaluate a Split feature flag to enable Split to calculate RUM
            // metrics for distinct versions of this app
            /*
             attribute = { Version: get this app version }
             evaluateFeatureFlag(attributes)
             */
        }
        
        // Tip: The following events can also be received:
        //    .sdkReadyFromCache - faster than .sdkReady
        //    .sdkUpdated        - when new split definitions are received
    }
    /* todo: no user consent?
    public var isUserConsentUnknown: Bool {
        get {
            return UserConsent.unknown == factory.userConsent
        }
    }
    
    public var isUserConsentGranted: Bool {
        get {
            return UserConsent.granted == factory.userConsent
        }
        set {
            factory.setUserConsent(enabled: newValue)
            
            DispatchQueue.main.async {
                self.userConsentValue = newValue
            }
        }
    }
    */
    // MARK: - Split SDK Function Wrappers
    
    /// Retrieves the treatment for the given feature flag (split), as defined in the Split Management
    /// Console.
    /// Parameter: `split`: The name of the split, as defined in the Split Management Console.
    /// Warning: If the Split definitions were not loaded yet, this function will return "CONTROL".
    @discardableResult
    func evaluateFeatureFlag(_ split: String) -> String {
        return suite.client.getTreatment(split)
    }
    
    /// Retrieves the treatment for the given feature flag (split), as defined in the Split Management
    /// Console.
    /// Parameter: `split`: The name of the split, as defined in the Split Management Console.
    /// Warning: If the Split definitions were not loaded yet, this function will return "CONTROL".
    /*
     @discardableResult
     func evaluateFeatureFlag(_ split: String, attributes:[String, Any]) -> String {
        // todo: add attributes
        return factory.client.getTreatment(split)
    }*/
    
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
