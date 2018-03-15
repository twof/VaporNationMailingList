import Foundation
import FluentMySQL
import Vapor

final public class User: Content {
    public var id: UUID?
    public var date: Date?
    public var name: String
    public var email: String
    
    init(id: UUID?=nil, date: Date=Date(), name: String, email: String) {
        self.id = UUID()
        self.date = date
        self.name = name
        self.email = email
    }
}

extension User: MySQLUUIDModel, Migration {
}

