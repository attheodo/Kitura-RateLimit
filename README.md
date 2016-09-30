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
```swift
import KituraRateLimit

private var customHandler: RouterHandler = { request, response, next in

    let message = "Oh ma g0d you're such a hax0r"

    if let _ = request.accepts(type: "text/html") {
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        try response.send(message).status(.tooManyRequests).end()
    } else if let _ = request.accepts(type: "application/json") {
        try response.send(json: JSON(["error": message])).status(.tooManyRequests).end()
    }

    try response.status(.tooManyRequests).end()

}

let config = [
    .window(10),               // The time window in seconds
    .maxRequests(100),         // Max number of requests per time window
    .includeHeaders(true),     // Include response headers showing limit and current usage
    .handler(customHandler)    // A custom response handler to use when limit has reached
]

let rateLimitMiddleware = RateLimit(config: config, keyStore: MemoryCacheRateLimitKeyStore())

// apply to all routes
router.all(middleware: rateLimitMiddleware)

// demo route
router.get("/") {
    request, response, next in

    try response.status(.OK).send("I am scrape resistant!").end()

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
