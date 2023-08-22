//
// Created by Никита Шестаков on 20.02.2023.
//

import Foundation
import ViewNodes

class ZStackWrapper<ContentView: View>: ZStack {
    var contentView: ContentView!

    init(contentPosition: Position, _ contentViewClosure: () -> ContentView) {
        super.init()
        content {
            contentView = contentViewClosure().position(contentPosition)
        }
    }
}
