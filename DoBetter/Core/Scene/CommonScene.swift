//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation

enum Common {

    enum LoadV2 {
        enum Request: Equatable {
            case initial,
                 pullToRefresh,
                 nextPage,
                 silent,
                 soft,
                 force,
                 page(Int)

            var isPage: Bool {
                switch self {
                case .nextPage, .page:
                    return true
                default:
                    return false
                }
            }

            var isActivityPresentingNeeded: Bool {
                switch self {
                case .initial, .force, .soft:
                    return true
                default:
                    return false
                }
            }

            var isPreventCacheNeeded: Bool {
                self == .pullToRefresh || self == .force
            }

            var shouldDropOldContent: Bool { self != .nextPage }

            var shouldDropContentOnError: Bool {
                switch self {
                case .silent, .nextPage, .page, .pullToRefresh: return false
                default: return true
                }
            }

            var displayActivityIndicatorImmediately: Bool {
                self == .initial || self == .force
            }

            var shouldScrollToTop: Bool { self != .nextPage && self != .silent }

            /// Определяет, как новые данные будут группироваться с уже загруженными
            var groupBehaviour: GroupBehaviour {
                switch self {
                case .silent: return .insertToBeginning
                case .nextPage: return .append
                default: return .replace
                }
            }

            static func ==(lhs: Request, rhs: Request) -> Bool {
                switch (lhs, rhs) {
                case (.initial, .initial):
                    return true
                case (.pullToRefresh, .pullToRefresh):
                    return true
                case (.nextPage, .nextPage):
                    return true
                case (.silent, .silent):
                    return true
                case (.soft, .soft):
                    return true
                case (.force, .force):
                    return true
                case (.page(let lhsPage), .page(let rhsPage)):
                    return lhsPage == rhsPage
                default:
                    return false
                }
            }
        }
    }

    enum GroupBehaviour {
        /// Добавить новые элементы в начало массива, дублирующие элементы не добавляются
        case insertToBeginning
        /// Добавить новые элементы в конец массива
        case append
        /// Заменить элементы массива на новые элементы
        case replace
    }

    enum Network {
        struct Request {
            let shouldSaveContent: Bool

            init(shouldSaveContent: Bool = true) {
                self.shouldSaveContent = shouldSaveContent
            }
        }
    }
}

protocol PresentationLogic: ErrorPresenting,
                            ActivityIndicationPresentationLogic {
}

protocol Presenting: PresentingType,
                     PresentationLogic,
                     DefaultErrorPresenting,
                     ActivityIndicationPresenting {

}

protocol DisplayLogic: AnyObject,
                       ErrorDisplaying,
                       ActivityIndicationDisplaying {

}

protocol Displaying: DisplayingType,
                     DisplayLogic {

}
