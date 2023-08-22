//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation
import UIKit

struct StopperPlaceholder: Updatable {

    var title: Title?
    var subtitle: Subtitle
    var image: IconModel?

    init(title: Title? = nil, subtitle: Subtitle = .somethingWentWrong, image: IconModel? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }

    static let sorry = StopperPlaceholder(subtitle: .somethingWentWrong)
            .image(IconModel(image: StopperImage.warning)?.color(.foreground))

    struct Title: RawRepresentable, Hashable, Codable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
    }

    struct Subtitle: RawRepresentable, Hashable, Codable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
    }

    func image(_ newValue: IconModel?) -> Self {
        updated(\.image, with: newValue)
    }

    func subtitle(_ newValue: Subtitle) -> Self {
        updated(\.subtitle, with: newValue)
    }

    func title(_ newValue: Title) -> Self {
        updated(\.title, with: newValue)
    }
}

extension StopperPlaceholder.Title {
    static let emptyOwnTasks = StopperPlaceholder.Title(rawValue: Localization.MyFeed.stopperTitle.localized)
    static let emptyFollowingsTasks = StopperPlaceholder.Title(rawValue: Localization.OtherFeed.stopperTitle.localized)
    static let emptyOtherTasks = StopperPlaceholder.Title(rawValue: Localization.OtherFeed.stopperOtherTitle.localized)
}

extension StopperPlaceholder.Subtitle {
    static let emptyOwnTasks = StopperPlaceholder.Subtitle(rawValue: Localization.MyFeed.stopperSubtitle.localized)
    static let emptyFollowingsTasks = StopperPlaceholder.Subtitle(rawValue: Localization.OtherFeed.stopperSubtitle.localized)
    static let somethingWentWrong = StopperPlaceholder.Subtitle(rawValue: Localization.somethingWentWrong.localized)
}

class StopperImage: UIImage {
    convenience public init?(named name: String) {
        guard let image = UIImage(named: name),
              let cgImage = image.cgImage else { return nil }
        let scale = CGFloat(cgImage.width) / image.size.width
        self.init(cgImage: cgImage, scale: scale, orientation: .up)
    }

    static let sorryStopper = StopperImage(named: "sorry")!
    static let warning = StopperImage(named: "warning")!
}
