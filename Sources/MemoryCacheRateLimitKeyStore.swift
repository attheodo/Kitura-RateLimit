//
//  MemoryCacheRateLimitKeyStore.swift
//  RateLimitExample
//
//  Created by Athanasios Theodoridis on 30/09/2016.
//
//

import Foundation
import KituraCache

/**
 Simple in-memory RateLimitKeyStore based on KituraCache
*/
public class MemoryCacheRateLimitKeyStore: RateLimitKeyStore {
    
    private var memoryCache: KituraCache?
    
    public func setup() {
        memoryCache = KituraCache(defaultTTL: 0, checkFrequency: 6000)
    }
    
    public func increment(key: String) -> Int? {
        
        guard let cache = memoryCache else {
            assertionFailure("memoryCache not initialized.")
            return nil
        }
        
        if let hits = cache.object(forKey: key) as? Int {
            cache.setObject(hits + 1, forKey: key)
            return hits + 1
        } else {
            cache.setObject(1, forKey: key)
            return 1
        }
        
    }
    
    public func reset(key: String) {
        
        guard let cache = memoryCache else {
            assertionFailure("memoryCache not initialized.")
            return
        }
        
        cache.removeObject(forKey: key)
    
    }
    
    public func resetAll() {
        
        guard let cache = memoryCache else {
            assertionFailure("memoryCache not initialized.")
            return
        }

        cache.removeAllObjects()
    
    }
    
}
