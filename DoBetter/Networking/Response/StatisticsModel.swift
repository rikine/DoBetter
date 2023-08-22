//
// Created by Никита Шестаков on 26.03.2023.
//

import Foundation

struct StatisticsModel: Codable {
    let done: Int
    let expired: Int
    let total: Int
    let inProgress: Int

    static let test = StatisticsModel(done: 2, expired: 1, total: 3, inProgress: 4)
}
