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
            to: "fabiobean2@gmail.com",
            subject: "Newsletter",
            text: "This is a newsletter"
        )
        
        let mailgunClient = try req.make(MailgunEngine.self)
        return try mailgunClient.sendMail(data: content, on: req)
    }
    
    router.on(HTTPMethod.options, at: ["anything"]) { (req) -> Future<HTTPStatus> in
        return Future(HTTPStatus.ok)
    }
   
    router.on(HTTPMethod.options, at: ["user"]) { (req) -> Future<Response> in
        return try Future(HTTPStatus.ok).encode(for: req).map(to: Response.self) { (response) in
            response.http.headers[HTTPHeaderName.accessControlAllowOrigin] = "*"
            response.http.headers[.accessControlAllowMethods] = "GET,POST,PUT,DELETE,OPTIONS"
            response.http.headers[.accessControlAllowHeaders] = "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, Access-Control-Allow-Origin"
            return response
        }
    }
    
    router.post("anything") { (req) -> Future<String> in
        return Future("Hello")
    }
    
    router.post("mass_mail") { (req) -> Future<HTTPStatus> in
        let mailgunClient = try req.make(MailgunEngine.self)
        
        return User.query(on: req).all().flatMap(to: HTTPStatus.self) { (users) in
            var mailgunFutures: [Future<Response>] = []
            
            for user in users {
                let content: MailgunFormData = MailgunFormData(
                    from: "postmaster@twof.me",
                    to: user.email,
                    subject: "Newsletter",
                    text: "Hello \(user.name)! This is a newsletter"
                )
                
                let mailgunRequest = try mailgunClient.sendMail(data: content, on: req)
                mailgunFutures.append(mailgunRequest)
            }
            
            return mailgunFutures.flatten().map(to: [Response].self) { (responses) in
                print(responses)
                return responses
            }.transform(to: HTTPStatus.ok)
        }
    }
    
    router.get("user") { (req) -> Future<[User]> in
        return User.query(on: req).all()
    }
    
    router.post(User.self, at: "user") { (req, newUser: User) -> Future<Response> in
        return try newUser.save(on: req).encode(for: req).map(to: Response.self) { (response) in
            response.http.headers[HTTPHeaderName.accessControlAllowOrigin] = "*"
            return response
        }
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

