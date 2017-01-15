//
//  KeyHandler.swift
//  KituraRateLimitExample
//
//  Created by Ugo Arangino on 15/01/2017.
//
//

import Kitura

/**
 Converts a `RouterRequest` to a key

 - Parameter routerRequest: The `RouterRequest` object that is used to work with
                     the incoming request.
 - returns: A  key for a `RateLimitKeyStore`
 */
public typealias KeyHandler = (RouterRequest) -> String
