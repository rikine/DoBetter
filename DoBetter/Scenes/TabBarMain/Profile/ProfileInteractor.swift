//
//  ProfileInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 19.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//


protocol ProfileBusinessLogic: TableBusinessLogic {
    func onButtonTap(_ request: Profile.Button.Request)
}

class ProfileInteractor: ProfileBusinessLogic,
                         InteractingType,
                         FlagLoadingType,
                         SocketListener {
    var presenter: ProfilePresentationLogic?
    var worker = ProfileWorker()
    weak var coordinator: ProfileCoordinator?

    var isLoading = false

    private let uid: String
    private var model: ProfileModel?
    private var followers: [ProfileModel] = []
    private var followings: [ProfileModel] = []
    private var statistics: StatisticsModel?

    private var tasksLikesLoadingUids: [String] = []
    private var tasksDoneLoadingUids: [String] = []
    private var tasks: [TaskModel] = []

    private lazy var currentUID = FirebaseAuthService.shared.getCurrentUid

    required init(uid: String) {
        self.uid = uid
        SocketIOManager.shared.observers.append(self)
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        Task { @MainActor in
            await fetchUser()
            await fetchStatistics()
            await fetchFollowing()
            await fetchTasks()
        }
    }

    @MainActor
    private func fetchUser() async {
        model.let {
            presenter?.presentTable(.init(model: $0, isLoading: isLoading))
        }

        do {
            let profile = try await worker.fetchUser(with: uid)
            model = profile

            presenter?.presentTable(.init(model: profile, isLoading: isLoading))
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
            coordinator?.stop()
        }
    }

    @MainActor
    private func fetchStatistics() async {
        do {
            let statistics = try await worker.fetchTaskStatistics(with: uid)
            self.statistics = statistics
            presenter?.presentStatistics(.init(statistics: statistics))
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
        }
    }

    @MainActor
    private func fetchFollowing() async {
        do {
            let followers = try await self.worker.fetchFollowers(with: self.uid)
            let followings = try await self.worker.fetchFollowings(with: self.uid)
            self.followings = followings
            self.followers = followers

            presenter?.presentUsers(.init(followers: followers, following: followings))
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
        }
    }

    @MainActor
    private func fetchTasks() async {
        do {
            tasks = try await worker.fetchTasks(for: uid)
            presenter?.presentTasks(.init(tasks: tasks,
                                          isLoadingDoneUIds: tasksDoneLoadingUids,
                                          isLoadingLikeUIds: tasksLikesLoadingUids))
        } catch {
            presenter?.presentError(.init(error: error, type: .banner))
        }
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onButtonTap(_ request: Profile.Button.Request) {
        guard let model else { return }

        switch request {
        case .edit: coordinator?.showEdit(with: model)
        case .follow: follow()
        case .user(let model): coordinator?.showProfile(with: model)
        case .doneTask(let model): makeTaskDone(model)
        case .allTasks: showAllTasks(model)
        case .allFollowers: coordinator?.showUsers(for: model, with: .followers)
        case .allFollowings: coordinator?.showUsers(for: model, with: .followings)
        case .task(let model): showTask(model)
        case .settings: showSettings(model)
        case .likeTask(let model): likeTask(model)
        }
    }

    private func follow() {
        model.let {
            presenter?.presentTable(.init(model: $0, isLoading: true))
        }

        Task { @MainActor in
            do {
                try await self.worker.followUser(with: self.uid)
            } catch {
                self.presenter?.presentError(.init(error: error, type: .banner))

                model.let {
                    presenter?.presentTable(.init(model: $0, isLoading: false))
                }
            }
        }
    }

    private func makeTaskDone(_ model: TaskModel) {
        guard model.ownerUID == currentUID else { return }

        tasksDoneLoadingUids.append(model.uid)
        presenter?.presentTasks(.init(tasks: tasks,
                                      isLoadingDoneUIds: tasksDoneLoadingUids,
                                      isLoadingLikeUIds: tasksLikesLoadingUids))

        Task { @MainActor in
            do {
                try await worker.makeTaskDone(uid: model.uid)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            tasksDoneLoadingUids.removeFirst(where: \.self, is: model.uid)
            presenter?.presentTasks(.init(tasks: tasks,
                                          isLoadingDoneUIds: tasksDoneLoadingUids,
                                          isLoadingLikeUIds: tasksLikesLoadingUids))
        }
    }

    private func likeTask(_ model: TaskModel) {
        tasksLikesLoadingUids.append(model.uid)
        presenter?.presentTasks(.init(tasks: tasks,
                                      isLoadingDoneUIds: tasksDoneLoadingUids,
                                      isLoadingLikeUIds: tasksLikesLoadingUids))

        Task { @MainActor in
            do {
                try await worker.likeTask(uid: model.uid)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            tasksLikesLoadingUids.removeFirst(where: \.self, is: model.uid)
            presenter?.presentTasks(.init(tasks: tasks,
                                          isLoadingDoneUIds: tasksDoneLoadingUids,
                                          isLoadingLikeUIds: tasksLikesLoadingUids))
        }
    }

    private func showAllTasks(_ model: ProfileModel) {
        coordinator?.showFollowingsTask(for: model)
    }

    private func showTask(_ model: TaskModel) {
        coordinator?.showTask(for: model)
    }

    private func showSettings(_ model: ProfileModel) {
        coordinator?.showSettings(for: model)
    }
}

extension ProfileInteractor {
    func onListen(event: SocketIOManager.Events, data: Any) {
        switch event {
        case .profilesUpdate:
            guard let profilesIds = data as? [String] else { return }
            guard profilesIds.contains(uid) || profilesIds.contains(currentUID) else { return }

            Task { @MainActor in
                await fetchUser()
                await fetchFollowing()
            }
        case .tasksUpdate:
            guard let data = data as? SocketIOManager.ActionWithIDS else { return }
            let tasksIds = data.ids.filter(where: \.self, isIn: tasks.map(\.uid))
            guard !tasksIds.isEmpty else { break }

            Task { @MainActor in
                await fetchStatistics()
                await fetchTasks()
            }
        }
    }
}
