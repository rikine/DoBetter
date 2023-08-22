//
// Created by Никита Шестаков on 12.03.2023.
//

import Foundation
import Moya

struct CheckPhoneExistsRequest {
    let phone: String

    init(phone: String) {
        self.phone = phone
    }
}

extension CheckPhoneExistsRequest: Request {
    typealias Result = PhoneExists

    public var parameters: [String: Any]? { Self.makeParameters(["phone": phone]) }
    public var path: String { "/v1/user/check/phone_exists" }
    public var method: Moya.Method { .get }
    
    public var sampleData: Data {
        let json = (try? JSONEncoder().encode(PhoneExists(isExists: phone == "+1 (234) 567-8900"))) ?? Data()
        return json
    }
}

struct PhoneExists: Codable {
    let isExists: Bool
}
