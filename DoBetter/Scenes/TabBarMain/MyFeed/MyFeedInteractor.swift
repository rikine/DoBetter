//
//  MyFeedInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

protocol FeedBusinessLogic: TableBusinessLogic {
    func showProfile(_ request: MyFeed.Profile.Request)
    func showTask(_ request: MyFeed.Task.Request)
    func showFilters(_ request: MyFeed.Filters.Request)
    func onDoneTask(_ request: MyFeed.Done.Request)
    func onLikeTask(_ request: MyFeed.Like.Request)
    func search(_ request: SearchFollowings.Search.Request)
}

protocol FeedInteracting: FeedBusinessLogic, InteractingType, FlagLoadingType, PagingBusinessLogic {
    associatedtype Worker: FeedWorker
    var worker: Worker { get }

    var filters: MyFeed.Filters { get set }
    var loadingLikesTaskUID: [String] { get set }
    var loadingIsDoneTaskUID: [String] { get set }
    var models: [TaskModel] { get set }
    var currentUID: String { get set }

    func updateFilters(model: MyFeed.Filters)
    func presentTable(withDiffer: Bool, isLoading: Bool)
}

extension FeedInteracting {
    var feedPresenter: FeedPresentationLogic? { assertionCast(presenter, to: FeedPresentationLogic.self) }

    func search(_ request: SearchFollowings.Search.Request) {
        guard !isLoading else { return }
        guard let text = request.text, text.count >= 3 else {
            if filters.title != nil {
                filters.title = nil
                loadV2(.initial)
            }
            return
        }
        filters.title = text
        loadV2(.initial)
    }

    func onDoneTask(_ request: MyFeed.Done.Request) {
        defaultOnDoneTask(request)
    }

    func defaultOnDoneTask(_ request: MyFeed.Done.Request) {
        loadingIsDoneTaskUID.append(request.task.uid)
        presentTable(withDiffer: true, isLoading: isLoading)

        Task { @MainActor in
            do {
                try await worker.makeTaskDone(uid: request.task.uid)
                loadingIsDoneTaskUID.removeFirst(where: \.self, is: request.task.uid)
            } catch {
                loadingIsDoneTaskUID.removeFirst(where: \.self, is: request.task.uid)
                presentTable(withDiffer: true, isLoading: isLoading)
                feedPresenter?.presentError(.init(error: error, type: .banner))
            }
        }
    }

    func onLikeTask(_ request: MyFeed.Like.Request) {
        loadingLikesTaskUID.append(request.task.uid)
        presentTable(withDiffer: true, isLoading: isLoading)

        Task { @MainActor in
            do {
                try await worker.likeTask(uid: request.task.uid)
                loadingLikesTaskUID.removeFirst(where: \.self, is: request.task.uid)
            } catch {
                loadingLikesTaskUID.removeFirst(where: \.self, is: request.task.uid)
                presentTable(withDiffer: true, isLoading: isLoading)
                feedPresenter?.presentError(.init(error: error, type: .banner))
            }
        }
    }

    func updateFilters(model: MyFeed.Filters) {
        guard model != filters else { return }
        filters = model
        loadV2(.initial)
    }

    func presentTable(withDiffer: Bool, isLoading: Bool) {
        feedPresenter?.presentTable(.init(tasks: models, shouldShowLoading: isLoading,
                                          withDiffer: withDiffer, loadingDoneIds: loadingIsDoneTaskUID,
                                          loadingLikesIds: loadingLikesTaskUID,
                                          filterName: filters.title))
    }
}

protocol MyFeedBusinessLogic: FeedBusinessLogic {
    func showCreateTask(_ request: MyFeed.CreateTask.Request)
    func onRemove(_ request: MyFeed.Delete.Request)
}

class MyFeedInteractor: MyFeedBusinessLogic,
                        FeedInteracting,
                        Initializable {

    var presenter: MyFeedPresentationLogic?
    var worker = MyFeedWorker()
    weak var coordinator: MyFeedCoordinator?

    var isLoading = false

    var pagingState: PagingState = .init()

    var filters = MyFeed.Filters() {
        didSet {
            presenter?.presentFiltersCount(.init(count: filters.count))
        }
    }

    @ThreadSafeProperty
    var loadingLikesTaskUID: [String] = []

    @ThreadSafeProperty
    var loadingIsDoneTaskUID: [String] = []

    @ThreadSafeProperty
    var models: [TaskModel] = []

    lazy var currentUID = FirebaseAuthService.shared.getCurrentUid

    required init() {
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
                let models = try await worker.fetchTasks(lastUid: models.last?.uid,
                                                         forUserUid: "current",
                                                         filter: filters)
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

    func showProfile(_ request: MyFeed.Profile.Request) {
        guard request.uid == nil else { return }
        coordinator?.showProfile()
    }

    func showCreateTask(_ request: MyFeed.CreateTask.Request) {
        coordinator?.showCreateTask()
    }

    func showFilters(_ request: MyFeed.Filters.Request) {
        coordinator?.showFilters(model: filters)
    }

    func onRemove(_ request: MyFeed.Delete.Request) {
        Task { @MainActor in
            do {
                try await worker.removeTask(id: request.model.uid)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }
        }
    }

    func showTask(_ request: MyFeed.Task.Request) {
        coordinator?.showTask(with: request.model)
    }
}

extension MyFeedInteractor: SocketListener {
    func onListen(event: SocketIOManager.Events, data: Any) {
        guard event == .tasksUpdate, let data = data as? SocketIOManager.ActionWithIDS else { return }
        switch data.action {
        case .delete:
            if models.contains(where: \.uid, isIn: data.ids) {
                models.removeAll { model in data.ids.contains(model.uid) }
                presentTable(withDiffer: true, isLoading: isLoading)
            }
        case .update:
            let neededTasks = models.map(\.uid).filter(in: data.ids)
            if !neededTasks.isEmpty {
                Task { @MainActor in
                    do {
                        let models = try await worker.fetchTasks(lastUid: nil,
                                                                 count: nil,
                                                                 forUserUid: "current",
                                                                 neededIds: neededTasks,
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
        case .create:
            guard data.ownerUID == currentUID else { return }

            Task { @MainActor in
                do {
                    let models = try await worker.fetchTasks(lastUid: nil,
                                                             count: nil,
                                                             forUserUid: "current",
                                                             neededIds: data.ids,
                                                             filter: filters)

                    if !models.isEmpty {
                        self.models = models + self.models
                        self.presentTable(withDiffer: true, isLoading: isLoading)
                    }
                } catch {
                    presenter?.presentError(.init(error: error, type: .banner))
                }
            }
        }
    }
}
