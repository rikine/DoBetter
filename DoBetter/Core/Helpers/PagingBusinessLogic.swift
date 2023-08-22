//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

/// Current state of pagination.
struct PagingState {
    var pageNumber = 0
    /// Indicates whether any data left to download in next cycle of pagination.
    /// Assigned to false when were downloaded less data pieces then the page size.
    var isMoreExists = true
}

/// Conform to this if want pagination. Watch DealsDetailsInteractor for an implementation.
protocol PagingBusinessLogic: AnyObject {
    var pagingState: PagingState { get set }
    var pageSize: Int { get }
    var rowsOffset: Int { get }
    func updatePaging(count: Int)
    func invalidatePagingState()
}

extension PagingBusinessLogic {
    var isMoreExists: Bool { pagingState.isMoreExists }
    var pageSize: Int { 20 }
    var rowsOffset: Int { pagingState.pageNumber * pageSize }

    /// Updating state based on how many data pieces were downloaded. If less then page size, then no more data left.
    func updatePaging(count: Int) {
        pagingState = .init(pageNumber: pagingState.pageNumber + 1,
                            isMoreExists: count >= pageSize)
    }

    /// Used when need to download data from the start. Ex: pullToRefresh.
    func invalidatePagingState() {
        pagingState = PagingState()
    }
}
