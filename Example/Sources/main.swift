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
