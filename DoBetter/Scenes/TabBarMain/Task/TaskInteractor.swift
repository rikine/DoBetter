//
//  TaskInteractor.swift
//  DoBetter
//
//  Created by Никита Шестаков on 18.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

protocol TaskBusinessLogic: TableBusinessLogic {
    func onLike(_ request: TaskModels.Likes.Request)
    func onEdit(_ request: TaskModels.Edit.Request)
    func onRemove(_ request: TaskModels.Remove.Request)
    func onDone(_ request: TaskModels.Done.Request)
    func onProfile(_ request: TaskModels.Profile.Request)
}

class TaskInteractor: TaskBusinessLogic,
                      InteractingType,
                      FlagLoadingType {

    var presenter: TaskPresentationLogic?
    var worker = TaskWorker()
    weak var coordinator: TaskCoordinator?

    var isLoading = false

    private var taskModel: TaskModel
    private var userModel: ProfileModel?
    private var isLikeLoading = false

    required init(taskModel: TaskModel) {
        self.taskModel = taskModel

        SocketIOManager.shared.observers.append(self)
    }

    func loadV2(_ request: Common.LoadV2.Request) {
        Task { @MainActor in
            do {
                presenter?.presentTable(.init(task: taskModel, user: userModel, isLikeLoading: isLikeLoading))
                userModel = try await worker.fetchUser(userId: taskModel.ownerUID)
                taskModel = try await worker.fetchTask(uid: taskModel.uid)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            presenter?.presentTable(.init(task: taskModel, user: userModel, isLikeLoading: isLikeLoading))
        }
    }

    func didSelectRow(_ request: Table.Selection.Request) {}

    func onEdit(_ request: TaskModels.Edit.Request) {
        coordinator?.showEdit(with: taskModel)
    }

    func onRemove(_ request: TaskModels.Remove.Request) {
        startLoading(with: .initial)

        Task { @MainActor in
            do {
                try await worker.removeTask(id: taskModel.uid)
                coordinator?.stop()
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            finishLoading()
        }
    }

    func onDone(_ request: TaskModels.Done.Request) {
        Task { @MainActor in
            do {
                try await worker.makeTaskDone(uid: taskModel.uid)
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }
        }
    }

    func onLike(_ request: TaskModels.Likes.Request) {
        isLikeLoading = true
        presenter?.presentTable(.init(task: taskModel, user: userModel, isLikeLoading: isLikeLoading))

        Task { @MainActor in
            do {
                try await worker.likeTask(uid: taskModel.uid)
                isLikeLoading = false
            } catch {
                presenter?.presentError(.init(error: error, type: .banner))
            }

            presenter?.presentTable(.init(task: taskModel, user: userModel, isLikeLoading: isLikeLoading))
        }
    }

    func onProfile(_ request: TaskModels.Profile.Request) {
        coordinator?.showProfile(for: taskModel.ownerUID)
    }
}

extension TaskInteractor: SocketListener {
    func onListen(event: SocketIOManager.Events, data: Any) {
        guard let data = data as? SocketIOManager.ActionWithIDS,
              data.ids.contains(taskModel.uid)
        else { return }

        switch event {
        case .tasksUpdate: loadV2(.initial)
        default: break
        }
    }
}
