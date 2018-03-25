import Vapor

public protocol CurlDebugConvertible {
    var cURLRepresentation: String { get }
}

extension HTTPRequest: CurlDebugConvertible {
    /// The textual representation used when written to an output stream, in the form of a cURL command.
    public var cURLRepresentation: String {
        var components = ["$ curl -i"]
        let host = url.host
        let httpMethod = self.method
        
        if httpMethod != .GET {
            components.append("-X \(httpMethod)")
        }
        
        //        if let credentialStorage = self.session.configuration.urlCredentialStorage {
        //            let protectionSpace = URLProtectionSpace(
        //                host: host,
        //                port: url.port ?? 0,
        //                protocol: url.scheme,
        //                realm: host,
        //                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
        //            )
        //
        //            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
        //                for credential in credentials {
        //                    components.append("-u \(credential.user!):\(credential.password!)")
        //                }
        //            } else {
        //                if let credential = delegate.credential {
        //                    components.append("-u \(credential.user!):\(credential.password!)")
        //                }
        //            }
        //        }
        //
        //        if session.configuration.httpShouldSetCookies {
        //            if
        //                let cookieStorage = session.configuration.httpCookieStorage,
        //                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty
        //            {
        //                let string = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
        //                components.append("-b \"\(string.substring(to: string.characters.index(before: string.endIndex)))\"")
        //            }
        //        }
        //
        var headers: [AnyHashable: Any] = [:]
        
        //        if let additionalHeaders = session.configuration.httpAdditionalHeaders {
        //            for (field, value) in additionalHeaders where field != AnyHashable("Cookie") {
        //                headers[field] = value
        //            }
        //        }
        
        for (field, value) in self.headers {
            headers[field] = value
        }
        
        for (field, value) in headers {
            components.append("-H \"\(field): \(value)\"")
        }
        let httpBody = self.body.description
        
        var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
        escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")
        
        components.append("-d \"\(escapedBody)\"")
        
        components.append("\"\(url.absoluteString)\"")
        
        return components.joined(separator: " \\\n\t")
    }
}

