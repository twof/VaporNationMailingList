import Vapor
import Foundation
import Mailgun
//import FluentPostgreSQL
//import AppKit

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    try services.register(EngineServerConfig.detect())
    
    if let mailgunKey = ProcessInfo.processInfo.environment["MAILGUN_KEY"],
            let customMailgunURL = ProcessInfo.processInfo.environment["MAILGUN_URL"] {
        let mailgunEngine = MailgunStructEngine(apiKey: mailgunKey, customURL: customMailgunURL)
        services.register(mailgunEngine, as: Mailgun.self)
    } else {
        fatalError("Set up your mailgun env variables")
    }
}
