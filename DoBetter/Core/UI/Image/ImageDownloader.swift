//  ImageDownloader.swift
//  Created by Vladimir Roganov on 22.08.2022.

import UIKit
//import Moya
import Foundation

class ImageDownloader {
    typealias ImageLoadResult = (model: IconModel, url: URL, dominantColor: UIColor)

    private let service = NetworkService.shared

    private var manuallyCancelled = false

    private var cancellables: [Task<ImageLoadResult, Error>] = []

    private var isCancelled: Bool {
        for cancellable in cancellables {
            if cancellable.isCancelled {
                return true
            }
        }
        return manuallyCancelled
    }

    func cancelAllTasks() {
        manuallyCancelled = true
//        for cancellable in cancellables {
//            cancellable.cancel()
//        }
        cancellables = []
    }

    func loadImages(url: URL, darkURL: URL?, convert: ImageConverter?, cacheMaxAge: TimeInterval?) async throws -> (ImageLoadResult?, Error?, Bool) {
        async let lightResult = try loadImage(url: url, convert: convert, cacheMaxAge: cacheMaxAge)
        async let darkResult = try loadImage(url: darkURL, convert: convert, cacheMaxAge: cacheMaxAge)

        do {
            let (light, dark) = try await (lightResult, darkResult)
            guard let light else { return guardUnreachable((nil, nil, false)) }
            let finalModel = MultiImage(light: light, dark: dark).finalModel()
            return ((finalModel, url, light.dominantColor), nil, isCancelled)
        } catch {
            return (nil, error, isCancelled)
        }
    }

    private func loadImage(url: URL?, convert: ImageConverter?, cacheMaxAge: TimeInterval?) async throws -> ImageLoadResult? {
        guard let url else { return nil }

        let task = Task {
            let data = try await service.request(AnyCommonRequest(url: url, cacheMaxAge: cacheMaxAge))

            guard var origImage = UIImage(data: data) else {
                throw NetworkError.failureStatusCode
            }
            if let alpha = convert?.alpha, alpha != 1.0 {
                origImage = origImage.alpha(CGFloat(alpha))
            }
            guard let iconModel = IconModel(shape: convert?.shape,
                                            border: convert?.border,
                                            image: origImage)?.scaledToShape()
            else {
                throw NetworkError.cancelled
            }
            return (model: iconModel, url: url, dominantColor: origImage.dominantColor)
        }

        cancellables.append(task)

        let result = await task.result
        switch result {
        case .success(let model):
            return model
        case .failure(let error):
            throw error
        }
    }

    /// Private struct introduced to combine 2 IconModels (light and dark) with optional dark model
    private struct MultiImage {
        let light: ImageLoadResult
        let dark: ImageLoadResult?

        func finalModel() -> IconModel {
            guard let dark = dark else {
                return light.model
            }
            let image = light.model.glyph.image
            (image.imageAsset)?.register(dark.model.glyph.image, with: .init(traitsFrom: [
                .current, .init(userInterfaceStyle: .dark)
            ]))
            guard let iconModel = IconModel(shape: light.model.shape,
                                            border: light.model.border,
                                            image: image)
            else {
                return light.model
            }
            return iconModel
        }
    }
}
