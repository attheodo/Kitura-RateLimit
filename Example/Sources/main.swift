import Kitura
import KituraRateLimit

let router = Router()

// Apply rate limiting with default configuration in "/" path
router.get("/", allowPartialMatch: false, middleware: RateLimit(config: .defaultConfig, keyStore: MemoryCacheRateLimitKeyStore()))
router.get("/") {
    request, response, next in

    try response.status(.OK).send("Landing Page").end()

}

// Custom rate limit configuration for "/hello"
extension RateLimitConfig {
    static var helloRouteConfig: RateLimitConfig {
        return RateLimitConfig(window: 100, maxRequests: 10, includeHeaders: true)
    }
}

// Apply rate limiting with custom configuratioon in "/hello"
router.get("/hello", allowPartialMatch: false, middleware: RateLimit(config: .helloRouteConfig, keyStore: MemoryCacheRateLimitKeyStore()))
router.get("/hello") {
    request, response, next in

    try response.status(.OK).send("Hello there!").end()

}

Kitura.addHTTPServer(onPort: 3000, with: router)
Kitura.run()
