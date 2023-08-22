//
//  SearchFollowingsInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 26.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//


protocol SearchFollowingsBusinessLogic: TableBusinessLogic {
    func followUser(_ request: SearchFollowings.Follow.Request)
    func search(_ request: SearchFollowings.Search.Request)
    func showUser(_ request: SearchFollowings.User.Request)
    func searchHidden(_ request: SearchFollowings.SearchHidden.Request)
}

class SearchFollowingsInteractor: SearchFollowingsBusinessLogic,
                                  InteractingType,
                                  PagingBusinessLogic,
                                  FlagLoadingType {

    var presenter: SearchFollowingsPresentationLogic?
    var worker = SearchFollowingsWorker()
    weak var coordinator: SearchFollowingsCoordinator?

    var isLoading = false

    var pagingState: PagingState = .init()

    private let model: ProfileModel?
    private let type: SearchFollowings.SearchType
    private var currentFilter: String?

    @ThreadSafeProperty
    private var loadingUIds: [String] = []

    @ThreadSafeProperty
    private var models: [ProfileModel] = []

    required init(for model: ProfileModel?, type: SearchFollowings.SearchType) {
        self.model = model
        self.type = type
        SocketIOManager.shared.observers.append(self)
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        guard !isLoading, request != .nextPage || isMoreExists else { return }
        startLoading(with: request, type: .none)

        if request.shouldDropOldContent {
            invalidatePagingState()
            models.removeAll(keepingCapacity: true)
        }

        if request == .initial {
            presentTable(withDiffer: true)

            if type == .all { presenter?.presentSearchHidden(.init()) }
        }

        Task { @MainActor in
            do {
                let models = try await self.worker.fetchUsers(from: self.models.last?.uid,
                                                              for: self.model?.uid, with: self.type, filter: currentFilter)
                updatePaging(count: models.count)
                self.models += models
                self.presentTable(withDiffer: true, isLoading: self.pagingState.isMoreExists)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
            }

            self.finishLoading()
        }
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func followUser(_ request: SearchFollowings.Follow.Request) {
        loadingUIds.append(request.user.uid)
        presentTable(withDiffer: true)

        Task { @MainActor in
            do {
                try await self.worker.followUser(with: request.user.uid)
                self.loadingUIds.removeFirst(where: \.self, is: request.user.uid)
            } catch {
                self.loadingUIds.removeFirst(where: \.self, is: request.user.uid)
                self.presenter?.presentError(.init(error: error, type: .banner))
                self.presentTable(withDiffer: true)
            }
        }
    }

    func search(_ request: SearchFollowings.Search.Request) {
        guard !isLoading else { return }
        guard let text = request.text, text.count >= 3 else {
            if currentFilter != nil {
                currentFilter = nil
                loadV2(.initial)
            }
            return
        }
        currentFilter = text
        loadV2(.initial)
    }

    func showUser(_ request: SearchFollowings.User.Request) {
        coordinator?.showProfile(request.user)
    }

    func searchHidden(_ request: SearchFollowings.SearchHidden.Request) {
        coordinator?.showSearchHidden()
    }

    private func presentTable(withDiffer: Bool) {
        presentTable(withDiffer: withDiffer, isLoading: isLoading)
    }

    private func presentTable(withDiffer: Bool, isLoading: Bool) {
        presenter?.presentTable(.init(users: models,
                                      shouldShowLoading: isLoading,
                                      withDiffer: withDiffer,
                                      updatingProfilesIds: loadingUIds,
                                      searchText: currentFilter))
    }
}

extension SearchFollowingsInteractor: SocketListener {
    func onListen(event: SocketIOManager.Events, data: Any) {
        switch event {
        case .profilesUpdate:
            guard let usersIds = data as? [String] else { return }
            let neededIds = usersIds.filter(where: \.self, isIn: models.map(\.uid))
            guard !neededIds.isEmpty else { return }

            Task { @MainActor in
                do {
                    let users = try await self.worker.fetchUsers(from: nil, count: nil, for: nil, with: .all,
                                                                 filter: nil, neededUsersIds: neededIds)

                    users.forEach { model in
                        guard let index = self.models.firstIndex(where: { $0.uid == model.uid }) else { return }
                        self.models[index] = model
                    }

                    self.presentTable(withDiffer: true)
                } catch {
                    self.presenter?.presentError(.init(error: error, type: .banner))
                }
            }
        case .tasksUpdate: break
        }
    }
}
