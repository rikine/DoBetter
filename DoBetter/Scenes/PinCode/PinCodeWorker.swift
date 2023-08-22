//
//  PinCodeWorker.swift
//  DoBetter
//
//  Created by Никита Шестаков on 05.03.2023.
//  Copyright (c) 2023 __MyCompanyName__. All rights reserved.
//

class PinCodeWorker {
    private let service: NetworkServiceProtocol

    init(service: NetworkServiceProtocol = NetworkService.shared) {
        self.service = service
    }
}
