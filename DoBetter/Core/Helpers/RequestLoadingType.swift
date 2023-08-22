//
// Created by Никита Шестаков on 26.02.2023.
//

import Foundation

/// Type which describes displaying behaviour after request started
enum RequestLoadingType {
    /// All data is hidden, activity indicator overlaps the screen
    case activityIndicator
    /// Loader doesn't exist
    case none
}

