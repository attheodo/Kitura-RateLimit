//
//  RateLimitConfiguration.swift
//  RateLimitExample
//
//  Created by Athanasios Theodoridis on 30/09/2016.
//
//

import Foundation
import Kitura

/**
 Enum representing configuration options for the RateLimit middleware
*/
public enum RateLimitOption: Equatable {
  
    /// The window in seconds
    case window(Int)
    /// Max requests coming from an ip per each window time
    case maxRequests(Int)
    /// Whether to include headers in the response to show request limit
    /// and current usage
    case includeHeaders(Bool)
    /// A custom handler to execute when max requests limit has been hit
    case handler(RouterHandler)
    
    public var description: String {
        
        let d: String
        
        switch self {
        case .window:
            d = "window"
        case .maxRequests:
            d = "maxRequests"
        case .includeHeaders:
            d = "includeHeaders"
        case .handler:
            d = "handler"
        }
        
        return d
    }

}

public func ==(lhs: RateLimitOption, rhs: RateLimitOption) -> Bool {
    return lhs.description == rhs.description
}

public struct RateLimitConfiguration: ExpressibleByArrayLiteral, Collection {
    
    public typealias Element = RateLimitOption
    public typealias Index = Array<RateLimitOption>.Index
    public typealias Generator = Array<RateLimitOption>.Generator
    public typealias SubSequence =  Array<RateLimitOption>.SubSequence
    
    private var backingArray = [RateLimitOption]()
    
    public var startIndex: Index {
        return backingArray.startIndex
    }
    
    public var endIndex: Index {
        return backingArray.endIndex
    }
    
    public var isEmpty: Bool {
        return backingArray.isEmpty
    }
    
    public var count: Index.Stride {
        return backingArray.count
    }
    
    public var first: Generator.Element? {
        return backingArray.first
    }
    
    public subscript(position: Index) -> Generator.Element {
        get {
            return backingArray[position]
        }
        
        set {
            backingArray[position] = newValue
        }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            return backingArray[bounds]
        }
        
        set {
            backingArray[bounds] = newValue
        }
    }
    
    public init(arrayLiteral elements: Element...) {
        backingArray = elements
    }
    
    public func generate() -> Generator {
        return backingArray.makeIterator()
    }
    
    public func index(after i: Index) -> Index {
        return backingArray.index(after: i)
    }
    
    public mutating func insert(_ element: Element, replacing replace: Bool = true) {
        for i in 0..<backingArray.count where backingArray[i] == element {
            guard replace else { return }
            
            backingArray[i] = element
            
            return
        }
        
        backingArray.append(element)
    }
    
}
