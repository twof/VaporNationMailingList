import Routing
import Vapor
import Foundation
import Crypto
import Dispatch
import Mailgun

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("hello") { (req) in
        return "Hello World"
    }
    
    router.get("mail") { (req) -> Future<Response> in
        let content: MailgunFormData = MailgunFormData(
            from: "postmaster@twof.me",
            to: "example@aol.com",
            subject: "Newsletter",
            text: "This is a newsletter"
        )
        
        var mailgunClient = try req.make(Mailgun.self)
        print(mailgunClient.numMailSent)
        return try mailgunClient.sendMail(data: content, on: req)
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

