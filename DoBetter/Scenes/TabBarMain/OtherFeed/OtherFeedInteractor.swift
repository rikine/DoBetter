//
//  OtherFeedInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//


protocol OtherFeedBusinessLogic: FeedBusinessLogic {
    func showUsers(_ request: OtherFeed.SearchUsers.Request)
}

class OtherFeedInteractor: OtherFeedBusinessLogic,
                           FeedInteracting {
    @ThreadSafeProperty
    var loadingLikesTaskUID: [String] = []

    @ThreadSafeProperty
    var loadingIsDoneTaskUID: [String] = []

    @ThreadSafeProperty
    var models: [TaskModel] = []

    var currentUID = FirebaseAuthService.shared.getCurrentUid

    var pagingState: PagingState = .init()

    var filters = MyFeed.Filters() {
        didSet {
            presenter?.presentFiltersCount(.init(count: filters.count))
        }
    }

    var presenter: OtherFeedPresentationLogic?
    var worker = OtherFeedWorker()
    weak var coordinator: OtherFeedCoordinator?

    var isLoading = false

    private let tasksForUid: String?

    required init(userUid: String? = nil) {
        tasksForUid = userUid
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
            presentTable(withDiffer: true, isLoading: true)
        }

        Task { @MainActor in
            do {
                self.presentTable(withDiffer: true, isLoading: true)
                let models = try await worker.fetchTasks(lastUid: models.last?.uid, forUserUid: tasksForUid, filter: filters)
                updatePaging(count: models.count)
                self.models += models
                self.presentTable(withDiffer: true, isLoading: self.pagingState.isMoreExists)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))
                self.presentTable(withDiffer: true, isLoading: false)
            }

            self.finishLoading()
        }
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func showUsers(_ request: OtherFeed.SearchUsers.Request) {
        coordinator?.showUsers()
    }

    func showProfile(_ request: MyFeed.Profile.Request) {
        guard let uid = request.uid else { return }
        coordinator?.showProfile(for: uid)
    }

    func showTask(_ request: MyFeed.Task.Request) {
        coordinator?.showTask(with: request.model)
    }

    func showFilters(_ request: MyFeed.Filters.Request) {
        coordinator?.showFilters(model: filters)
    }

    func onDoneTask(_ request: MyFeed.Done.Request) {
        guard currentUID == tasksForUid else { return }
        defaultOnDoneTask(request)
    }
}

extension OtherFeedInteractor: SocketListener {
    func onListen(event: SocketIOManager.Events, data: Any) {
        guard event == .tasksUpdate, let data = data as? SocketIOManager.ActionWithIDS else { return }

        switch data.action {
        case .update:
            let neededTasks = models.map(\.uid).filter(in: data.ids)
            if !neededTasks.isEmpty {
                Task { @MainActor in
                    do {
                        let models = try await worker.fetchTasks(lastUid: nil,
                                                                 count: nil,
                                                                 neededIds: neededTasks,
                                                                 forUserUid: tasksForUid,
                                                                 filter: filters)

                        models.forEach { model in
                            guard let index = self.models.firstIndex(where: { $0.uid == model.uid }) else { return }
                            self.models[index] = model
                        }

                        self.presentTable(withDiffer: true, isLoading: isLoading)
                    } catch {
                        presenter?.presentError(.init(error: error, type: .banner))
                    }
                }
            }
        case .delete:
            if models.contains(where: \.uid, isIn: data.ids) {
                models.removeAll { model in data.ids.contains(model.uid) }
                presentTable(withDiffer: true, isLoading: isLoading)
            }
        case .create: break
        }
    }
}
