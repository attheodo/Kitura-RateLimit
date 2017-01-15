//
//  RateLimitConfiguration.swift
//  RateLimitExample
//
//  Created by Athanasios Theodoridis on 30/09/2016.
//
//

import Foundation
import Kitura
import SwiftyJSON

public typealias KeyHandler = (RouterRequest) -> String

public struct RateLimitConfig {
    
    let window: Int
    let maxRequests: Int
    let includeHeaders: Bool
    let handler: RouterHandler
    let keyHandler: KeyHandler
    
    public static var defaultConfig: RateLimitConfig {
        return self.init()
    }
    
    public init(window: Int = 10,
        maxRequests: Int = 100,
        includeHeaders: Bool = true,
        handler: @escaping RouterHandler = RateLimitConfig.defaultHandler,
        keyHandler: @escaping KeyHandler = RateLimitConfig.defaultKeyHandler) {
        
        self.window = window
        self.maxRequests = maxRequests
        self.includeHeaders = includeHeaders
        self.handler = handler
        self.keyHandler = keyHandler
    }
    
    public static var defaultHandler: RouterHandler = {
        request, response, next in
        
        let message = "Too many requests"
        
        if let _ = request.accepts(type: "text/html") {
            response.headers["Content-Type"] = "text/plain; charset=utf-8"
            try response.send(message).status(.tooManyRequests).end()
        } else if let _ = request.accepts(type: "application/json") {
            try response.send(json: JSON(["error": message])).status(.tooManyRequests).end()
        }
        
        try response.status(.tooManyRequests).end()
    }
    
    public static var defaultKeyHandler: KeyHandler = {
        request in
        
        return request.remoteAddress
    }

}

