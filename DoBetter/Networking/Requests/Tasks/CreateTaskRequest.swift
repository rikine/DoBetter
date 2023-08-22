//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct CreateTaskRequest {
    let title: String
    let description: String?
    let endDate: Date?
    let section: SectionModel
    let color: TaskModel.Color
    let image: UIImage?
}

extension CreateTaskRequest: Request, Authorizable {
    typealias Result = TaskModel

    public var task: Task {
        .uploadMultipart(makeFormData())
    }

    public var parameters: [String: Any]? { nil }

    public var path: String { "/v1/tasks/create" }

    public var method: Moya.Method { .post }

    private func makeFormData() -> [MultipartFormData] {
        (image?.jpegData(compressionQuality: 0.7).map {
            [MultipartFormData(provider: .data($0), name: "file", fileName: "file", mimeType: "image/jpeg")]
        } ?? [])
            + [
            .init(provider: .data(title.data(using: .utf8)!), name: "title"),
            description.map { .init(provider: .data($0.data(using: .utf8)!), name: "description") },
            endDate.map { .init(provider: .data(Decoding.dateTimeFormatterWithTimeZone.string(from: $0).data(using: .utf8)!), name: "endDate") },
            .init(provider: .data(section.rawValue.data(using: .utf8)!), name: "section"),
            .init(provider: .data(color.rawValue.data(using: .utf8)!), name: "color")
        ].flatten()
    }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(Self.tasks[0])) ?? Data()
        return json
    }
    
    static var tasks: [TaskModel] {
        let endTime = Date(timeIntervalSince1970: 23353463)
        let createTime = Date(timeIntervalSince1970: 1234)
        
        return [
            .init(uid: "task1", title: "title1", description: "description 1", imageName: nil, endDate: endTime, isDone: false, section: .business, createdAt: createTime, isInProgress: false, isEditable: true, color: .none, isLiked: false, likesCount: 0, ownerUID: "test1", ownerName: "Test Name1"),
            .init(uid: "task2", title: "title2", description: "description 2", imageName: nil, endDate: endTime, isDone: true, section: .home, createdAt: createTime, isInProgress: false, isEditable: true, color: .none, isLiked: false, likesCount: 0, ownerUID: "test1", ownerName: "Test Name1"),
            .init(uid: "task3", title: "title3", description: "description 3", imageName: nil, endDate: endTime, isDone: false, section: .work, createdAt: createTime, isInProgress: true, isEditable: true, color: .none, isLiked: false, likesCount: 0, ownerUID: "test1", ownerName: "Test Name1"),
            .init(uid: "task4", title: "title4", description: "description 4", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: true, color: .none, isLiked: true, likesCount: 1, ownerUID: "test1", ownerName: "Test Name1"),
            
            .init(uid: "task5", title: "title 5", description: "description 5", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test2", ownerName: "Test Name2"),
            .init(uid: "task6", title: "title 6", description: "description 6", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test2", ownerName: "Test Name2"),
            .init(uid: "task7", title: "title 7", description: "description 7", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test2", ownerName: "Test Name2"),
            .init(uid: "task8", title: "title 8", description: "description 8", imageName: nil, endDate: nil, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test2", ownerName: "Test Name2"),
            .init(uid: "task9", title: "title 9", description: "description 9", imageName: nil, endDate: nil, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test3", ownerName: "Test Name3"),
            .init(uid: "task10", title: "title 10", description: "description 10", imageName: nil, endDate: nil, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test3", ownerName: "Test Name3"),
            .init(uid: "task11", title: "title 11", description: "description 11", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: true, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test4", ownerName: "Test Name4"),
            .init(uid: "task12", title: "title 12", description: "description 12", imageName: nil, endDate: endTime, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test4", ownerName: "Test Name4"),
            .init(uid: "task13", title: "title 13", description: "description 13", imageName: nil, endDate: nil, isDone: false, section: .none, createdAt: createTime, isInProgress: false, isEditable: false, color: .none, isLiked: false, likesCount: 0, ownerUID: "test5", ownerName: "Test Name5"),
        ]
    }
}
