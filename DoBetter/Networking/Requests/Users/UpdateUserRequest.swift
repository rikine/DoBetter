//
// Created by Никита Шестаков on 01.04.2023.
//

import Foundation
import Moya

struct UpdateUserRequest {
    let nickname: String
    let name: String?
    let description: String?
    let image: UIImage?
    let shouldRemoveImage: Bool
}

extension UpdateUserRequest: Request, Authorizable {
    typealias Result = UpdateProfileResponse
    public var task: Task {
        .uploadMultipart(makeFormData())
    }

    public var parameters: [String: Any]? { nil }

    public var path: String { "/v1/user/update" }

    public var method: Moya.Method { .post }

    private func makeFormData() -> [MultipartFormData] {
        (image?.jpegData(compressionQuality: 0.7).map {
            [MultipartFormData(provider: .data($0), name: "file", fileName: "file", mimeType: "image/jpeg")]
        } ?? [])
            + [
            .init(provider: .data(nickname.data(using: .utf8)!), name: "nickname"),
            name.map { .init(provider: .data($0.data(using: .utf8)!), name: "name") },
            description.map { .init(provider: .data($0.data(using: .utf8)!), name: "description") },
            .init(provider: .data(shouldRemoveImage.description.data(using: .utf8)!), name: "shouldRemoveImage")
        ].flatten()
    }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(UpdateProfileResponse(success: true))) ?? Data()
        return json
    }
}

struct UpdateProfileResponse: Codable {
    let success: Bool
}
