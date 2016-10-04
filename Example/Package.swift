import PackageDescription

let package = Package(
    name: "KituraRateLimitExample",
    dependencies: [
       .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
       .Package(url: "../", majorVersion: 0),
   ])
