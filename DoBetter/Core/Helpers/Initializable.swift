//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import UIKit

protocol Initializable { init() }

public func makeInstance<T>(of type: T.Type) -> T {
    if let initializable = (T.self as? Initializable.Type)?.init() as? T {
        return initializable
    }
    if let vc = (type as? UIViewController.Type)?.init(nibName: nil, bundle: nil) as? T {
        return vc
    }
    fatalError("\(String(describing: T.self)) is not conform `Initializable`")
}
