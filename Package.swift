import PackageDescription

let package = Package(
    name: "KituraRateLimit",
    dependencies: [
       .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
       .Package(url: "https://github.com/IBM-Swift/Kitura-Cache", majorVersion: 1, minor: 0),
   ])
)
