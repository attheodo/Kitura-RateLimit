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
    
    // Default options
    
    // Allow only 100 requests every 10 seconds
    private var window: Int = 10
    private var maxRequests: Int = 100
    
    /// Sent headers showing max & current requests by default
    private var shouldIncludeHeaders: Bool = true
    
    /// Default response handler
    private var handler: RouterHandler = { request, response, next in
        
        let message = "Too many requests"
        
        if let _ = request.accepts(type: "text/html") {
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            try response.send(message).status(.tooManyRequests).end()
        } else if let _ = request.accepts(type: "application/json") {
            try response.send(json: JSON(["error": message])).status(.tooManyRequests).end()
        }
        
        try response.status(.tooManyRequests).end()
        
    }
    
    /// A timer to flush the key-store every <window> seconds
    private var timer: DispatchSourceTimer?
    private let timerQueue: DispatchQueue
    
    /// The key-value store to use to store request hits per ip
    private var keyStore: RateLimitKeyStore
    
    public init(config: RateLimitConfiguration = [], keyStore: RateLimitKeyStore) {
        
        self.keyStore = keyStore
        self.timerQueue = DispatchQueue(label: "com.kitura-rate-limit.timerQueue")
        
        for option in config {
            
            switch option {
            case let .window(window):
                self.window = window
            case let .maxRequests(maxRequests):
                self.maxRequests = maxRequests
            case let .includeHeaders(shouldIncludeHeaders):
                self.shouldIncludeHeaders = shouldIncludeHeaders
            case let .handler(handler):
                self.handler = handler
            }
            
        }
        
        self.keyStore.setup()
        
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
