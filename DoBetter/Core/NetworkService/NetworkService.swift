//
// Created by Никита Шестаков on 21.02.2023.
//

import Foundation
import Moya

protocol NetworkServiceProtocol {
    func request<T: Request>(_ request: T) async throws -> T.Result

    func clear()
}

final class NetworkService: NetworkServiceProtocol {
    static let shared: NetworkServiceProtocol = {
        if CommandLine.arguments.contains("test") {
            return FakeNetworkService()
        }
        return NetworkService()
    }()

    private let provider: MoyaProvider<MultiTarget> = {
        MoyaProvider<MultiTarget>(plugins: [NetworkLoggerPlugin(configuration: .init(formatter: .init(),
                                                                                     output: NetworkLoggerPlugin.Configuration.defaultOutput,
                                                                                     logOptions: .verbose)),
            ManualCachePlugin()])
    }()

    private init() {}

    func request<T: Request>(_ request: T) async throws -> T.Result {
        func sendRequest() async throws -> T.Result {
            let response = try await provider.requestAsync(.target(request))
            return try T.decodeResult(from: response)
        }

        do {
            return try await sendRequest()
        } catch {
            guard (error as? ServerError)?.status == 403 else { throw error }

            do {
                let _ = try await FirebaseAuthService.shared.getToken()
                return try await sendRequest()
            } catch {
                NetworkService.shared.clear()
                AppCoordinator.shared.start()
                throw NetworkError.failureStatusCode
            }
        }
    }

    func clear() {
        _Concurrency.Task {
            try? FirebaseAuthService.shared.signOut()
        }

        URLCache.shared.removeAllCachedResponses()
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKey.bioAuthEnabled)
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKey.profileToken)
    }
}

final class FakeNetworkService: NetworkServiceProtocol {
    func request<T>(_ request: T) async throws -> T.Result where T: Request {
        try T.decodeResult(from: .init(statusCode: T.successStatusCode, data: request.sampleData))
    }

    func clear() {
        _Concurrency.Task {
            try? FirebaseAuthService.shared.signOut()
        }

        URLCache.shared.removeAllCachedResponses()
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKey.bioAuthEnabled)
        UserDefaults.standard.setValue(nil, forKey: UserDefaultsKey.profileToken)
    }
}

enum NetworkError: LocalizedError {
    case failureStatusCode
    case notEmptyResponse
    case cancelled
    case badInput

    var errorDescription: String? { Localization.unexpectedError.localized }
}

class AsyncMoyaRequestWrapper {
    typealias MoyaContinuation = CheckedContinuation<Result<Response, MoyaError>, Never>

    var performRequest: (MoyaContinuation) -> Moya.Cancellable?
    var cancellable: Moya.Cancellable?

    init(_ performRequest: @escaping (MoyaContinuation) -> Moya.Cancellable?) {
        self.performRequest = performRequest
    }

    func perform(continuation: MoyaContinuation) {
        cancellable = performRequest(continuation)
    }

    func cancel() {
        cancellable?.cancel()
    }
}

public extension MoyaProvider {
    private func requestAsyncRaw(_ target: Target) async -> Result<Response, MoyaError> {
        let asyncRequestWrapper = AsyncMoyaRequestWrapper { [weak self] continuation in
            guard let self = self else { return nil }
            return self.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: .success(response))
                case let .failure(moyaError):
                    continuation.resume(returning: .failure(moyaError))
                }
            }
        }

        return await withTaskCancellationHandler(operation: {
            await withCheckedContinuation { continuation in
                asyncRequestWrapper.perform(continuation: continuation)
            }
        }, onCancel: {
            asyncRequestWrapper.cancel()
        })
    }

    func requestAsync(_ target: Target) async throws -> Response {
        let response = await requestAsyncRaw(target)

        switch response {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
