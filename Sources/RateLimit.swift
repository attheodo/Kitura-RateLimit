//
//  RateLimit.swift
//  kitura-rate-limit
//
//  Created by Athanasios Theodoridis on 29/09/2016.
//
//

import Foundation

import Kitura
import SwiftyJSON
import Dispatch

public class RateLimit: RouterMiddleware {
    
    private var window: Int
    private var maxRequests: Int
    private var shouldIncludeHeaders: Bool
    private var handler: RouterHandler
    
    /// A timer to flush the key-store every <window> seconds
    private var timer: DispatchSourceTimer?
    private let timerQueue: DispatchQueue
    
    /// The key-value store to use to store request hits per ip
    private var keyStore: RateLimitKeyStore
    
    public init(config: RateLimitConfig, keyStore: RateLimitKeyStore) {
        
        self.keyStore = keyStore
        self.timerQueue = DispatchQueue(label: "com.kitura-rate-limit.timerQueue")
        
        self.window = config.window
        self.maxRequests = config.maxRequests
        self.shouldIncludeHeaders = config.includeHeaders
        self.handler = config.handler
        
        startFlushTimer()
    
    }
    
    deinit {
        
        guard let _ = timer else{
            return
        }
        
        timer!.cancel()
        timer = nil
        
    }
    
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        
        if let currentHits = keyStore.increment(key: request.remoteAddress) {
            
            if shouldIncludeHeaders {
                
                let remainingRequests = maxRequests - currentHits
                
                response.headers.append("X-RateLimit-Limit", value: String(maxRequests))
                response.headers.append("X-RateLimit-Remaining", value: String(max(remainingRequests, 0)))
            
            }
            
            if currentHits > maxRequests {
                try! handler(request, response, next)
            }
                     
            next()
            
        } else {
            next()
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
     A helper method to initialize the timer with the `window` interval
     to reset all keys from the current `keyStore`
    */
    private func startFlushTimer() {
        
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        
        timer!.scheduleRepeating(deadline: DispatchTime.now(), interval: Double(window))
        timer!.setEventHandler() {
            self.keyStore.resetAll()
        }
        
        timer!.resume()
    
    }
    
}
