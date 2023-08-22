//
// Created by Никита Шестаков on 02.04.2023.
//

import Foundation
import SocketIO

@objc protocol SocketListener: AnyObject {
    func onListen(event: SocketIOManager.Events, data: Any)
}

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()

    var manager: SocketManager = .init(socketURL: URL(string: "https://renderer-sockets.onrender.com/")!, config: [.log(true)])
    lazy var socket: SocketIOClient = manager.defaultSocket

    var observers: WeakArray<SocketListener> = .init()

    func connectSocket() {
        disconnectSocket()

        socket.on(clientEvent: .connect) { [weak self] (data, ack) in
            self?.socket.removeAllHandlers()
            self?.setupHandlers()
        }

        socket.connect()
    }

    func disconnectSocket() {
        socket.removeAllHandlers()
        socket.disconnect()
    }

    func checkConnection() -> Bool {
        if socket.manager?.status == .connected {
            return true
        }
        return false
    }

    private func setupHandlers() {
        socket.on(Events.profilesUpdate.listenerName) { [weak self] (response, emitter) in
            self?.observers.reap()
            self?.observers.forEach { listener in
                listener.onListen(event: .profilesUpdate, data: self?.parseIds(data: response) as Any)
            }
        }

        socket.on(Events.tasksUpdate.listenerName) { [weak self] (response, emitter) in
            self?.observers.reap()
            self?.observers.forEach { listener in
                listener.onListen(event: .tasksUpdate, data: self?.parseIdsWithAction(data: response) as Any)
            }
        }
    }

    private func parseIdsWithAction(data: [Any]) -> ActionWithIDS? {
        .init(from: data)
    }

    private func parseIds(data: [Any]) -> [String]? { data.first as? [String] }

    @objc enum Events: Int {
        case tasksUpdate, profilesUpdate

        var listenerName: String {
            switch self {
            case .tasksUpdate: return "tasks_update"
            case .profilesUpdate: return "profile_update"
            }
        }
    }

    enum Action: String {
        case update = "U", delete = "D", create = "C"
    }

    struct ActionWithIDS {
        let action: Action
        let ids: [String]
        let ownerUID: String?

        init?(from data: [Any]) {
            guard let data = data.first as? [String: Any] else { return nil }
            action = ((data["action"] as? String).map { Action(rawValue: $0) } ?? nil) ?? .update
            ids = (data["tasks"] as? [String]) ?? []
            ownerUID = data["ownerUID"] as? String
        }
    }
}
