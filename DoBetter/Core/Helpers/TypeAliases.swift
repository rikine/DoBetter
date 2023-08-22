//
// Created by Никита Шестаков on 19.02.2023.
//

import Foundation
import ViewNodes

typealias VoidClosure = ViewNodes.VoidClosure

typealias InitializableView = View & Initializable

/// allows to continue decoding parent entity if optional children fails to decode.
/// Same as wrapping init(from: Decoder) in do/catch { throw DecodingError.keyNotFoundMayBeIgnored }
protocol RecoverFromUnknownValueAsNil {}

/// Useful for @propertyWrapper<T?>
/// Synthesize value if key is missing
protocol Synthesizable: RecoverFromUnknownValueAsNil {
    static func synthesize() -> Synthesizable // -> Self
}
