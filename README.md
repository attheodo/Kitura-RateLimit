# Kitura-RateLimit

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000?style=plastic)]()
[![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg)](https://developer.apple.com/swift/)

[![Logo](https://github.com/attheodo/ATHMultiSelectionSegmentedControl/raw/master/misc/logo.png  "kitura-RateLimit")](/)

Kitura middleware for basic request rate-limiting. Useful for limiting repeated/automated requests to public APIs and mitigating brute-force and scraping attempts.

## Installation
Add `KituraRateLimit` as a dependency in your project's `Package.swift` file and `import KituraRateLimit` wherever appropriate in your project files.

## Custom Key-Value Stores
Currently `KituraRateLimit` uses a thread-safe in-memory key-value store on top of `Kitura-Cache`. Thus, the hits per ip dataset cannot be shared by other servers and processes. In case you need that, I recommend writing a custom keystore conforming to `RateLimitKeyStore` using `kitura-redis` and the Redis key-value database.

## Usage

Check `/Example` application. 

```swift
import Kitura
import KituraRateLimit

let router = Router()


// MARK: - defaultConfig

// Apply rate limiting with default configuration in "/" path
router.get("/", allowPartialMatch: false, middleware: RateLimit(config: .defaultConfig, keyStore: MemoryCacheRateLimitKeyStore()))
router.get("/") {
    request, response, next in

    try response.status(.OK).send("Landing Page").end()

}


// MARK: - helloConfig

// Custom rate limit configuration for "/hello"
extension RateLimitConfig {
    static var helloConfig: RateLimitConfig {
        return RateLimitConfig(window: 100, maxRequests: 10, includeHeaders: true)
    }
}

// Apply rate limiting with custom configuratioon in "/hello"
router.get("/hello", allowPartialMatch: false, middleware: RateLimit(config: .helloConfig, keyStore: MemoryCacheRateLimitKeyStore()))
router.get("/hello") {
    request, response, next in

    try response.status(.OK).send("Hello there!").end()

}


// MARK: - customKeyConfig

// Custom rate limit configuration for "/hello"
extension RateLimitConfig {
    static var customKeyConfig: RateLimitConfig {
        return RateLimitConfig(window: 10, maxRequests: 10, includeHeaders: true, handler: RateLimitConfig.defaultHandler, keyHandler: RateLimitConfig.customKeyHandler)
    }
    
    public static var customKeyHandler: KeyHandler = {
        request in
        
        return request.queryParameters["client_id"] ?? ""
    }
}

// Apply rate limiting with custom configuratioon in "/hello"
// Veryfy that `router.get("/customKey"…` request queryParameters has a valid client_id
router.get("/customKey", allowPartialMatch: false, middleware: RateLimit(config: .customKeyConfig, keyStore: MemoryCacheRateLimitKeyStore()))
router.get("/customKey") {
    request, response, next in
    
    try response.status(.OK).send("Hello there!").end()
    
}


Kitura.addHTTPServer(onPort: 3000, with: router)
Kitura.run()

```

## Contributors

- attheodo, at@atworks.gr

## License

`kitura-RateLimit` is available under the MIT license. See the LICENSE file for more info.

## Changelog
- **v0.1.0**, *September 2016*
    - Initial release
