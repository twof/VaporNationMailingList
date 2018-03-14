import Async
import WebSocket
import Foundation

extension Future where Expectation == String {
    public func send(to websocket: WebSocket) -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { (data) in
            websocket.send(string: data)
            return self
        }
    }
}

extension Future where Expectation == Data {
    public func send(to websocket: WebSocket) -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { (data) in
            websocket.send(data: data)
            return self
        }
    }
}
