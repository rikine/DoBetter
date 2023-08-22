//
// Created by Никита Шестаков on 21.03.2023.
//

import Foundation
import UIKit

struct TaskModel: Codable, CellModelPayload, Equatable {
    enum Color: String, Codable, CaseIterable {
        case none = "clear", red = "red", green = "green", accent = "accent",
             elevated = "elevated", gray = "gray", pink = "pink", yellow = "yellow"
    }

    let uid: String
    let title: String
    let description: String?
    let imageName: String?
    var imageUrl: URL? {
        imageName.map {
            var components = URLComponents(string: GlobalConstants.baseURL.absoluteString + "/v1/image")
            components?.queryItems = [.init(name: "name", value: $0)]
            return components?.url
        } ?? nil
    }
    let endDate: Date?
    let isDone: Bool
    let section: SectionModel
    let createdAt: Date

    let isInProgress: Bool
    let isEditable: Bool
    let color: Color
    let isLiked: Bool
    let likesCount: Int

    let ownerUID: String
    let ownerName: String?
}

extension TaskModel {
    enum State: CaseIterable {
        typealias Statistics = Localization.Statistics

        case inProgress, expired, done, total

        var title: String {
            switch self {
            case .inProgress: return Statistics.inProgress.localized
            case .expired: return Statistics.expired.localized
            case .done: return Statistics.done.localized
            case .total: return Statistics.total.localized
            }
        }
    }

    var state: State {
        if isDone {
            return .done
        } else if let endDate, Date() > endDate {
            return .expired
        } else {
            return .inProgress
        }
    }
}

extension TaskModel.Color {
//    case none = "clear", red = "red", green = "green", accent = "accent",
//         elevated = "elevated", gray = "gray", pink = "pink", yellow = "yellow"
    var uiColor: UIColor {
        switch self {
        case .red: return .destructiveBackground
        case .green: return .constructiveBackground
        case .accent: return .accent.withAlphaComponent(UIColor.accent.alpha * 0.5)
        case .elevated: return .foreground4 // Ok
        case .gray: return .gray.withAlphaComponent(UIColor.accent.alpha * 0.5)
        case .pink: return .systemPink.withAlphaComponent(UIColor.accent.alpha * 0.3)
        case .yellow: return .yellow.withAlphaComponent(UIColor.accent.alpha * 0.3)
        case .none: return .smoke // Ok
        }
    }
}

enum SectionModel: String, CaseIterable, Codable {
    typealias Section = Localization.Task.Section

    case none = "none", home = "home", work = "work", business = "business", study = "study",
         friends = "friends", family = "family"

    var localized: String {
        switch self {
        case .none: return Section.none.localized
        case .home: return Section.home.localized
        case .work: return Section.work.localized
        case .business: return Section.business.localized
        case .study: return Section.study.localized
        case .friends: return Section.friends.localized
        case .family: return Section.family.localized
        }
    }
}
