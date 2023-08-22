//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

protocol LoadableBusinessLogic: AnyObject {
    func loadV2(_ request: Common.LoadV2.Request)
}

protocol CommonBusinessLogic: LoadableBusinessLogic {
    func didAppear(firstTime: Bool)
    func didDisappear()
}

extension CommonBusinessLogic {
    func didAppear(firstTime: Bool) {}
    func didDisappear() {}
}

extension CommonBusinessLogic where Self: InteractingType {

    /// Default behaviour before request start
    func startLoading(with request: Common.LoadV2.Request,
                      type loadingType: RequestLoadingType = .activityIndicator,
                      message: NSAttributedString? = nil) where Self: FlagLoadingType {
        self.isLoading = true

        switch loadingType {
        case .activityIndicator where request.isActivityPresentingNeeded:
            let presenter = assertionCast(presenter, to: ActivityIndicationPresentationLogic.self)
            presenter?.presentActivityIndication(.init(isShown: request.isActivityPresentingNeeded,
                                                       immediately: false,
                                                       ignoreRefreshControl: true,
                                                       message: message))
        default:
            break
        }

        // e.g. pull-to-refresh
        if request.shouldDropOldContent, let paging = self as? PagingBusinessLogic {
            paging.invalidatePagingState()
        }
    }

    /// Default behaviour after request finished (fullfilled or rejected)
    func finishLoading() where Self: FlagLoadingType {
        self.isLoading = false

        if let presenter = presenter as? ActivityIndicationPresentationLogic {
            presenter.presentActivityIndication(.init(isShown: false, immediately: false, ignoreRefreshControl: false))
        }
    }

    @discardableResult
    func isConnectedToNetwork(_ request: Common.Network.Request) -> Bool {
//        let connected = Service.shared.isConnectedToNetwork() /// TODO:
        let connected = false
        if !connected {
            let types: [ErrorHandling.ViewType] = request.shouldSaveContent ? [.banner] : [.banner, .placeholder]
            let presenter = assertionCast(presenter, to: PresentationLogic.self)
            types.forEach {
                presenter?.presentError(.init(error: NSError.networkError, type: $0))
            }
            presenter?.presentActivityIndication(.init(isShown: false, immediately: true, ignoreRefreshControl: false))
        }
        return connected
    }
}

/// Requires your type to have a flag which indicates whether some data is currently being loaded or not
protocol FlagLoadingType: AnyObject {
    var isLoading: Bool { get set }
}

extension NSError {
    static let networkError = NSError(domain: NSURLErrorDomain,
                                      code: NSURLErrorNotConnectedToInternet,
                                      userInfo: [NSLocalizedDescriptionKey:
                                      NSLocalizedString("Нет подключения к интернету", comment: "")])
}

