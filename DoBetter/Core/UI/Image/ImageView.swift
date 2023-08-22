//
//  ImageView.swift
//  VisionInvestUI
//
//  Created by Вадим Серегин on 25.10.2022.
//  Copyright © 2022 vision-invest. All rights reserved.
//

import UIKit

public class ImageView: UIImageView {

    override init(image: UIImage? = nil) {
        super.init(image: image)
        _updateContentModeByState()
    }

    override init(image: UIImage? = nil, highlightedImage: UIImage? = nil) {
        super.init(image: image, highlightedImage: highlightedImage)
        _updateContentModeByState()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _updateContentModeByState()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _updateContentModeByState()
    }

    /// Need state for different behaviour of placeholder and main image.
    public enum State {
        case placeholder
        /// Any image by default is main. If has a placeholder, state will switch to "placeholder", while loading an image.
        case main
    }

    private var state: State = .main {
        didSet {
            _updateContentModeByState()
        }
    }

    var contentModeByState: [State: ContentMode] = [.main: .center, .placeholder: .center] {
        didSet {
            _updateContentModeByState()
        }
    }

    private func _updateContentModeByState() {
        contentMode = contentModeByState[state] ?? .center
    }

    private enum Caches {
        @ThreadSafeProperty
        static var caches = [CacheLocation: ImageCache]()

        @ThreadSafeProperty
        static var dominantColorCache = [URL: UIColor]()
    }

    public enum CacheLocation: Hashable {
        case `default`, custom(String)
    }

    typealias ImageCache = [AnyHashable: IconModel]

    var cache: ImageCache {
        get {
            let cache: ImageCache
            if let existingCache = Caches.caches[cacheLocation] {
                cache = existingCache
            } else {
                let newCache = ImageCache()
                Caches.caches[cacheLocation] = newCache
                cache = newCache
            }
            return cache
        }
        set {
            Caches.caches[cacheLocation] = newValue
        }
    }

    public var cacheLocation: CacheLocation = .default

    public var dominantColor: UIColor? {
        guard let url = url else { return nil }
        return Caches.dominantColorCache[url]
    }

    // Using this only when image loading failed and current image is placeholder
    public var placeholderDominantColor: UIColor? {
        guard state == .placeholder, let placeholderImage = image else { return nil }
        return placeholderImage.pixelColor(at: .init(x: placeholderImage.size.width / 2, y: 0))
    }

    public typealias Completion = (UIImage?) -> Void
    public var didSetImage: Completion?

    public override var image: UIImage? {
        didSet {
            didSetImage?(image)
        }
    }

    public typealias DownloadCompletion = (Either<IconModel, Error>) -> Void
    public var didDownloadImage: DownloadCompletion?

    private var url: URL?
    private var downloadTask: ImageDownloader?

    public var convert: ImageConverter?

    /// Модель, которая делает иконку disabled
    public var disabledModel: IconModel.DisabledModel?

    /// Иконка, которая была изначально передана в ImageView (или получена из интернета)
    /// Без применения `disabledModel`
    public var enabledIconModel: IconModel?

    public func setImage(with url: URL?,
                         darkURL: URL? = nil,
                         placeholder: IconModel? = nil,
                         cacheMaxAge: TimeInterval? = nil,
                         completion: Completion? = nil,
                         downloadCompletion: DownloadCompletion? = nil) {
        guard url != self.url || url == nil else { return }
        self.url = url

        if downloadTask != nil {
            downloadTask?.cancelAllTasks()
            downloadTask = nil
        }

        didSetImage = completion
        didDownloadImage = downloadCompletion
        guard !tryToLoadModelFromCache(url: url) else { return }
        image = nil
        iconModel = nil

        icon(placeholder)
        state = .placeholder
        guard let url = url else { return }
        self.url = url

        downloadTask = ImageDownloader()

        Task { [weak self] in
            do {
                guard let (result, error, isCancelled) = try await self?.downloadTask?.loadImages(url: url, darkURL: darkURL, convert: convert, cacheMaxAge: cacheMaxAge) else {
                    return
                }
                if let result = result {
                    self?.applyFinalIconModel(result.model,
                                              dominantColor: result.dominantColor,
                                              url: result.url,
                                              isCancelled: isCancelled)
                } else if let error = error {
                    self?.didDownloadImage?(.right(error))
                }
            } catch {
                self?.didDownloadImage?(.right(error))
            }
        }
    }

    private func applyFinalIconModel(_ model: IconModel, dominantColor: UIColor, url: URL, isCancelled: Bool) {
        cache[url.absoluteString + (convert?.name ?? "default")] = model
        Caches.dominantColorCache[url] = dominantColor
        if !isCancelled {
            icon(model, animated: true)
            didDownloadImage?(.left(model))
            state = .main
            downloadTask = nil
        }
    }

    public func icon(_ icon: IconModel?, animated: Bool = false) {
        enabledIconModel = icon
        makeImage(from: icon?.makeDisabledIfNeeded(with: disabledModel), animated: animated)
    }

    func prepareForReuse() {
        downloadTask?.cancelAllTasks()
        downloadTask = nil
        url = nil
        image = nil
        iconModel = nil
        enabledIconModel = nil
        disabledModel = nil
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let model = iconModel else {
            return
        }
        image = model.makeImage()
    }

    private func tryToLoadModelFromCache(url: URL?) -> Bool {
        guard let url = url,
              let iconModel = cache[url.absoluteString + (convert?.name ?? "default")] else {
            return false
        }
        self.url = url
        icon(iconModel)
        didDownloadImage?(.left(iconModel))
        return true
    }
}
