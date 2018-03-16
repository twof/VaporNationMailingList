import Vapor
import Foundation
import Mailgun
import FluentMySQL

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
        let mailgunEngine = MailgunEngine(apiKey: mailgunKey, customURL: customMailgunURL)
        services.register(mailgunEngine, as: MailgunProvider.self)
    } else {
        fatalError("Set up your mailgun env variables")
    }
    
    try services.register(FluentMySQLProvider())
    
    var databaseConfig = DatabaseConfig()
    let db: MySQLDatabase
    
    if let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"],
        let database = MySQLDatabase(databaseURL: databaseURL) {
        db = database
        print("using remote DB")
    } else {
        let (username, password, host, database) = ("root", "pass", "localhost", "mailinglist")
        db = MySQLDatabase(hostname: host, user: username, password: password, database: database)
        print("using local DB")
    }
    
    databaseConfig.add(database: db, as: .mysql)
    services.register(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: User.self, database: .mysql)
    services.register(migrationConfig)
}
