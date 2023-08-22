//
//  CreateTaskWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 03.04.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

import UIKit
import Foundation

class CreateTaskWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }

    func createOrUpdateTask(taskId: String?, title: String, description: String?, endDate: Date?, section: SectionModel,
                            color: TaskModel.Color, image: UIImage?, shouldRemoveImage: Bool) async throws {
        if let taskId {
            let _ = try await service.request(UpdateTaskRequest(uid: taskId, title: title, description: description, endDate: endDate,
                                                               section: section, color: color, image: image, shouldRemoveImage: shouldRemoveImage))
            return
        } else {
            let _ = try await service.request(CreateTaskRequest(title: title, description: description, endDate: endDate, section: section, color: color, image: image))
            return
        }
    }
}
