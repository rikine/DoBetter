//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation

struct ProfileModel: Codable, CellModelPayload, Equatable {
    let nickname: String
    let name: String?
    let uid: String
    let photoName: String?
    let isEditable: Bool
    let description: String?
    let isSecure: Bool

    var isFollowing: Bool?

    var photoUrl: URL? {
        photoName.map {
            var components = URLComponents(string: GlobalConstants.baseURL.absoluteString + "/v1/image")
            components?.queryItems = [.init(name: "name", value: $0)]
            return components?.url
        } ?? nil
    }

    mutating func toggleFollowing() {
        isFollowing = isFollowing.map { !$0 }
    }

    func initialsImage(with shape: IconModel.Shape = .largeSquircle) -> IconModel {
        let commonIcon = IconModel(shape: shape, shapeColor: .accent)
        guard let initials = name?.first ?? nickname.first else {
            return commonIcon
        }
        return .fromText(String(initials),
                         textStyle: .headline,
                         shape: shape,
                         shapeColor: .accent,
                         glyphTintColor: .constantWhite) ?? commonIcon
    }
}
