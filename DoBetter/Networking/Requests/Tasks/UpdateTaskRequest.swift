//
// Created by Никита Шестаков on 09.04.2023.
//

import Foundation
import Moya

struct UpdateTaskRequest {
    let uid: String
    let title: String
    let description: String?
    let endDate: Date?
    let section: SectionModel
    let color: TaskModel.Color
    let image: UIImage?
    let shouldRemoveImage: Bool
}

extension UpdateTaskRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse

    public var task: Task {
        .uploadMultipart(makeFormData())
    }

    public var parameters: [String: Any]? { nil }

    public var path: String { "/v1/tasks/update" }

    public var method: Moya.Method { .post }

    private func makeFormData() -> [MultipartFormData] {
        (image?.jpegData(compressionQuality: 0.7).map {
            [MultipartFormData(provider: .data($0), name: "file", fileName: "file", mimeType: "image/jpeg")]
        } ?? [])
            + [
            .init(provider: .data(uid.data(using: .utf8)!), name: "uid"),
            .init(provider: .data(title.data(using: .utf8)!), name: "title"),
            description.map { .init(provider: .data($0.data(using: .utf8)!), name: "description") },
            endDate.map { .init(provider: .data(Decoding.dateTimeFormatterWithTimeZone.string(from: $0).data(using: .utf8)!), name: "endDate") },
            .init(provider: .data(section.rawValue.data(using: .utf8)!), name: "section"),
            .init(provider: .data(color.rawValue.data(using: .utf8)!), name: "color"),
            .init(provider: .data(shouldRemoveImage.description.data(using: .utf8)!), name: "shouldRemoveImage")
        ].flatten()
    }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}
