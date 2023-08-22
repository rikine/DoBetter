//
// Created by Никита Шестаков on 25.02.2023.
//

import Foundation
import UIKit
import ViewNodes

public protocol ViewAnyModel {
    static var viewAnyType: UIView.Type { get }
    static var viewStaticIdentifier: String { get }
    var viewIdentifier: String { get }
    func setupAny(view: UIView)
    func makeView() -> UIView
}

public protocol ViewModel: ViewAnyModel {
    associatedtype ViewType: UIView
    func setup(view: ViewType)
}

public extension ViewModel {

    static var viewAnyType: UIView.Type {
        ViewType.self
    }

    static var viewStaticIdentifier: String {
        String(reflectingWithoutBundleName: Self.viewAnyType)
    }

    var viewIdentifier: String {
        Self.viewStaticIdentifier
    }

    func setupAny(view: UIView) {
        guard let view = assertionCast(view, to: ViewType.self) else { return }
        setup(view: view)
    }

    func makeView() -> UIView {
        makeDefaultView()
    }

    func makeDefaultView() -> UIView {
        let view: ViewType
        if ViewType.isSubclass(of: View.self) {
            view = ViewType()
        } else {
            view = ViewType(frame: .zero)
        }
        setup(view: view)
        return view
    }
}
