//
//  RateLimitKeyStore.swift
//  RateLimitExample
//
//  Created by Athanasios Theodoridis on 30/09/2016.
//
//

import Foundation

/**
 Protocol for key stores suitable for holding rate limit values
*/
public protocol RateLimitKeyStore {
    
    /// Perform any initialization of the key-store
    func setup()
    
    /**
      Increments the number of hits for a key and returns the value
 
      - parameter key: The key in the key-value store
      - returns: An optional integer with the number of hits for that key
      if the key was found
    */
    func increment(key: String) -> Int?
    
    /**
      Resets the number of hits for a key
     
      - parameter key: The key to reset in the key-value store
    */
    func reset(key: String)
    
    /**
     Resets all the keys in the key-value store
    */
    func resetAll()

}
