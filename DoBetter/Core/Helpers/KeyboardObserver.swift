//
// Created by Никита Шестаков on 07.03.2023.
//

import Foundation
import UIKit

extension KeyboardObserver {
    enum KeyboardEvent {
        case willShow
        case willHide
        case didChangeFrame
    }
}

final class KeyboardObserver {

    private var _keyboardWillShowObservations: [NotificationCenterObservation<UIKeyboardWillShow>] = []
    private var _keyboardWillHideObservations: [NotificationCenterObservation<UIKeyboardWillHide>] = []
    private var _keyboardDidChangeFrameObservations: [NotificationCenterObservation<UIKeyboardDidChangeFrame>] = []

    typealias KeyboardCallback = (_ payload: KeyboardNotificationPayload, _: KeyboardEvent) -> Void

    /// Sometimes the same event can be sent twice by system, compare with this property to avoid this case
    var lastEvent: KeyboardEvent = .willHide

    var lastPayload: KeyboardNotificationPayload?

    func observeKeyboard(notifications: Set<KeyboardEvent> = [.willShow, .willHide, .didChangeFrame],
                         // при дефолтном значении коллбэк будет срабатывать только при смене типа ивента
                         // когда подключена физическая клавиатура, вместо willShow приходит willHide ивент 🤡,
                         // и может понадобиться вызов коллбэка, даже если ивент не поменялся
                         // (например, на экране смс-подтверждения)
                         distinctUntilChanged: Bool = true,
                         callback: @escaping KeyboardCallback) {

        for event in notifications {

            func keyboardCallback(_ payload: KeyboardNotificationPayload) {
                guard !distinctUntilChanged || event != lastEvent else { return }
                lastEvent = event
                lastPayload = payload
                callback(payload, event)
            }

            switch event {
            case .willShow:
                let observation = NotificationCenter
                        .default
                        .addObserver(forNotification: UIKeyboardWillShow.self, using: keyboardCallback)
                _keyboardWillShowObservations.append(observation)
            case .willHide:
                let observation = NotificationCenter
                        .default
                        .addObserver(forNotification: UIKeyboardWillHide.self, using: keyboardCallback)
                _keyboardWillHideObservations.append(observation)
            case .didChangeFrame:
                let observation = NotificationCenter
                        .default
                        .addObserver(forNotification: UIKeyboardDidChangeFrame.self, using: keyboardCallback)
                _keyboardDidChangeFrameObservations.append(observation)
            }

        }
    }

    /// `KeyboardObserver` doesn't capture neither
    /// `constraint`, nor `superview`.
    ///
    /// - Parameter superview: The view to call `layoutIfNeeded()` on
    ///                        when the keyboard appears and disappears.
    func bindKeyboardTop(to constraint: NSLayoutConstraint,
                         constraintIsToSafeArea: Bool = false,
                         maintainingOffset offset: CGFloat,
                         inverse: Bool = false,
                         superview: UIView?,
                         // see distinctUntilChanged in 'observeKeyboard'
                         distinctUntilChanged: Bool = true,
                         callback: (KeyboardCallback)? = nil) {

        observeKeyboard(distinctUntilChanged: distinctUntilChanged) { [weak superview, weak constraint] payload, event in
            guard let superview = superview else { return }
            let trueKeyboardHeight = max(0, UIScreen.main.bounds.size.height
                - payload.frameEnd.origin.y - (constraintIsToSafeArea ? superview.safeAreaInsets.bottom : 0))
            constraint?.constant = (trueKeyboardHeight + offset) * (inverse ? -1 : 1)
            superview.layoutIfNeeded()

            callback?(payload, event)
        }
    }

    func removeObservations() {
        _keyboardWillShowObservations.removeAll()
        _keyboardWillHideObservations.removeAll()
    }
}


public protocol NotificationDescriptor {
    associatedtype Payload
    static var name: Notification.Name { get }
}

public protocol SystemNotificationDescriptor: NotificationDescriptor {
    static func convert(_ notification: Notification) -> Payload
}

public protocol CustomNotificationDescriptor: NotificationDescriptor {}

public final class NotificationCenterObservation<Descriptor: NotificationDescriptor> {

    private let token: NSObjectProtocol
    private let center: NotificationCenter

    fileprivate init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {

    public func addObserver<Descriptor: SystemNotificationDescriptor>(
        forNotification descriptor: Descriptor.Type,
        object: Any? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping (Descriptor.Payload) -> Void
    ) -> NotificationCenterObservation<Descriptor> {

        let token = addObserver(forName: descriptor.name,
                                object: object,
                                queue: queue, using: { notification in

            block(descriptor.convert(notification))
        })

        return NotificationCenterObservation(token: token, center: self)
    }

    public func addObserver<Descriptor: CustomNotificationDescriptor>(
        forNotification descriptor: Descriptor.Type,
        queue: OperationQueue? = nil,
        using block: @escaping (Descriptor.Payload) -> Void
    ) -> NotificationCenterObservation<Descriptor> {

        let token = addObserver(forName: descriptor.name,
                                object: nil,
                                queue: queue,
                                using: { notification in
                                    block((notification.object as! NotificationPayloadWrapper<Descriptor.Payload>).value)
                                })

        return NotificationCenterObservation(token: token, center: self)
    }

    public func post<Descriptor: NotificationDescriptor>(notification: Descriptor.Type, value: Descriptor.Payload) {
        let wrapped = NotificationPayloadWrapper(value: value)
        post(name: notification.name, object: wrapped)
    }

    public func post<Descriptor: NotificationDescriptor>(
        notification: Descriptor.Type
    ) where Descriptor.Payload == Void {
        post(name: notification.name, object: NotificationPayloadWrapper(value: ()))
    }
}

/// This is a workaround for [a bug in Swift](https://bugs.swift.org/browse/SR-3871)
private struct NotificationPayloadWrapper<T> {
    let value: T
}

struct KeyboardNotificationPayload {

    /// Фрейм клавиатуры в момент пришедшей нотификации
    let frameBegin: CGRect
    /// Фрейм клавиатуры по итогам действия из нотификации
    var frameEnd: CGRect
    let animationDuration: Double

    /// Корректная высота клавиатуры, так как значение frame.height в нотификациях может приходить криво
    var trueKeyboardHeight: CGFloat { max(0, UIScreen.main.bounds.size.height - frameEnd.origin.y) }

    fileprivate init(_ notification: Notification) {
        let userInfo = notification.userInfo
        frameBegin = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        frameEnd = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double

        /// There is a bug when you get expanded keyboard height in `keyboardFrameEndUserInfoKey`
        if notification.name == UIResponder.keyboardWillHideNotification {
            frameEnd.size.height = 0
        }
    }
}

enum UIKeyboardWillShow: SystemNotificationDescriptor {
    typealias Payload = KeyboardNotificationPayload

    static let name = UIResponder.keyboardWillShowNotification

    static func convert(_ notification: Notification) -> KeyboardNotificationPayload {
        return KeyboardNotificationPayload(notification)
    }
}

enum UIKeyboardWillHide: SystemNotificationDescriptor {
    typealias Payload = KeyboardNotificationPayload

    static let name = UIResponder.keyboardWillHideNotification

    static func convert(_ notification: Notification) -> KeyboardNotificationPayload {
        return KeyboardNotificationPayload(notification)
    }
}

enum UIKeyboardDidChangeFrame: SystemNotificationDescriptor {
    typealias Payload = KeyboardNotificationPayload

    static let name = UIResponder.keyboardDidChangeFrameNotification

    static func convert(_ notification: Notification) -> KeyboardNotificationPayload {
        return KeyboardNotificationPayload(notification)
    }
}

enum TaskDidChangeDescriptor: SystemNotificationDescriptor {
    typealias Payload = TaskModel

    static let name = NSNotification.Name(rawValue: "TaskDidChangeDescriptor")

    static func convert(_ notification: Notification) -> TaskModel {
        guard let task = notification.object as? TaskModel else {
            fatalError()
        }
        return task
    }
}

enum ProfileDidChangeDescriptor: SystemNotificationDescriptor {
    typealias Payload = ProfileModel

    static let name = NSNotification.Name(rawValue: "ProfileDidChangeDescriptor")

    static func convert(_ notification: Notification) -> ProfileModel {
        guard let user = notification.object as? ProfileModel else {
            fatalError()
        }
        return user
    }
}
