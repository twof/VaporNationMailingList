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
    
    router.post("mail") { (req) -> Future<Response> in
        let content = Mailgun.Message(
            from: "postmaster@twof.me",
            to: "fabiobean2@gmail.com",
            subject: "Newsletter",
            text: "This is a newsletter"
        )
        
        let mailgunClient = try req.make(Mailgun.self)
        return try mailgunClient.send(content, on: req).map({ (resp) in
            print(resp.debugDescription)
            return resp
        })
    }
    
//    router.on(HTTPMethod.OPTIONS, at: ["anything"]) { (req) in
//        return HTTPStatus.ok
//    }
//   
//    router.on(HTTPMethod.OPTIONS, at: ["user"]) { (req) in
//        return try Future(HTTPStatus.ok).encode(for: req).map(to: Response.self) { (response) in
//            response.http.headers[HTTPHeaderName.accessControlAllowOrigin] = "*"
//            response.http.headers[.accessControlAllowMethods] = "GET,POST,PUT,DELETE,OPTIONS"
//            response.http.headers[.accessControlAllowHeaders] = "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, Access-Control-Allow-Origin"
//            return response
//        }
//    }
    
    router.post("hello") { (req) in
        return "Hello"
    }
    
    router.post("mass_mail") { (req) -> Future<HTTPStatus> in
        let mailgunClient = try req.make(Mailgun.self)
        
        return User.query(on: req).all().flatMap(to: HTTPStatus.self) { (users) in
            var mailgunFutures: [Future<Response>] = []
            
            for user in users {
                let content = Mailgun.Message(
                    from: "postmaster@twof.me",
                    to: user.email,
                    subject: "Newsletter",
                    text: "Hello \(user.name)! This is a newsletter"
                )
                
                let mailgunRequest = try mailgunClient.send(content, on: req)
                mailgunFutures.append(mailgunRequest)
            }
            
            return mailgunFutures.flatten(on: req).map(to: [Response].self) { (responses) in
                print(responses)
                return responses
            }.transform(to: HTTPStatus.ok)
        }
    }
    
    router.get("user") { (req) -> Future<[User]> in
        return User.query(on: req).all()
    }
    
    router.post(User.self, at: "user") { (req, newUser: User) -> Future<Response> in
        return try newUser.save(on: req).encode(for: req)
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

