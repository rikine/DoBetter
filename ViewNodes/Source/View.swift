//
//  View.swift
//  ViewNodes
//
//  Created by Maxime Tenth on 10/9/19.
//  Copyright © 2019 vision-invest. All rights reserved.
//

import UIKit

extension View {

    public enum Position {
        case center
        @available(*, deprecated, message: "use .size(.fill) instead")
        case fill
        case top
        case bottom
        case left
        case right

        case topRight
        case topLeft
        case bottomRight
        case bottomLeft
        case centerLeft
        case centerRight
    }

    public struct Size {

        public enum Dimension: Equatable {
            case fill
            case compact
            case equal(CGFloat)

            public var equalValue: CGFloat? {
                if case .equal(let value) = self {
                    return value
                }
                return nil
            }
        }

        public var width: Dimension
        public var height: Dimension
        static let fill = Size(width: .fill, height: .fill)
        static let compact = Size(width: .compact, height: .compact)
    }

    public enum Background {

        public struct Gradient {
            let colors: [UIColor]
            let from: CGPoint
            let to: CGPoint

            public init(colors: [UIColor], from: CGPoint, to: CGPoint) {
                self.colors = colors
                self.from = from
                self.to = to
            }

            public init(colors: UIColor..., from: CGPoint, to: CGPoint) {
                self.init(colors: colors, from: from, to: to)
            }
        }

        case view(UIColor?)
        case layer(UIColor?)
        case gradient(Gradient)

    }

    public struct Shadow {
        public init(color: UIColor?, opacity: Float?, radius: CGFloat?, offset: CGSize?) {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
        }

        let color: UIColor?
        let opacity: Float?
        let radius: CGFloat?
        let offset: CGSize?
    }

    public struct Corner {
        public init(radius: CGFloat, corners: UIRectCorner, masksToBounds: Bool = true) {
            self.radius = radius
            self.corners = corners
            self.masksToBounds = masksToBounds
        }

        let radius: CGFloat
        let corners: UIRectCorner
        let masksToBounds: Bool
    }

    public struct Border {
        let width: CGFloat
        let color: UIColor

        public init(width: CGFloat, color: UIColor) {
            self.width = width
            self.color = color
        }
    }

    public struct EdgeLine {
        let edge: UIRectEdge
        let width: CGFloat
        let color: UIColor
        let leadingPadding: CGFloat
        let trailingPadding: CGFloat
        let lineDashPattern: [NSNumber]?
        var isHidden: Bool

        func hidden(_ value: Bool) -> Self {
            var new = self
            new.isHidden = value
            return new
        }
    }

}

// swiftlint:disable type_body_length
open class View: UIView, NodeType {

    public struct Config {
        public var background: Background

        public init(backgroundColor: UIColor) {
            self.background = .view(backgroundColor)
        }

        public init(background: Background) {
            self.background = background
        }

        public mutating func reset() {
            self = Self.default
        }

        public static var `default`: Config = Config(backgroundColor: .white)
    }

    public static var config: Config = .default

    private var config: Config?
    public weak var parent: NodeType?
    public var subnodes: [NodeType] = []

    public var nodeSubviews: [View] {
        subviews.compactMap { $0 as? View }
    }

    // MARK: - Init
    @discardableResult
    public init() {
        super.init(frame: .zero)
        _apply(config: Self.config)
        addSubnodes(nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _apply(config: Self.config)
        addSubnodes(nil)
    }

    private func _apply(config: Config) {
        backgroundValue = config.background
    }

    // This attribute hides `init(coder:)` from subclasses
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Node

    @discardableResult
    open func insertHere() -> Self {
        addSubnodes(nil)
        return self
    }

    @discardableResult
    open func config(_ config: Config, applying: Bool = true) -> Self {
        self.config = config
        if applying {
            _apply(config: config)
        }
        return self
    }

    @discardableResult
    open func config(backgroundColor: UIColor, applying: Bool = true) -> Self {
        config(.init(backgroundColor: backgroundColor), applying: applying)
    }

    /// Config and apply if color exist
    @discardableResult
    open func configIfNeeded(backgroundColor: UIColor?) -> Self {
        guard let backgroundColor else { return self }
        return config(backgroundColor: backgroundColor, applying: true)
    }

    @discardableResult
    open func content(_ contentClosure: VoidClosure) -> Self {
        for view in subviews {
            view.removeFromSuperview()
        }
        let oldConfig = View.config
        if let config = config {
            View.config = config
        }
        defer { if config != nil { View.config = oldConfig } }

        setSubnodes(contentClosure)
        return self
    }

    open func addSubnode(_ node: NodeType) {
        subnodes.append(node)
        if let view = node as? View {
            super.addSubview(view)
        }
    }

    override public func removeFromSuperview() {
        super.removeFromSuperview()
        parent?.removeFromParent()
    }

    // MARK: - Properties

    public var identifierValue: String?

    // MARK: Properties - Layout

    public var size: Size = .compact
    public var paddingInsets: UIEdgeInsets = .zero
    public var positionValue: Position = .fill

    public var minSizeValue: CGSize?
    public var maxSizeValue: CGSize?

    // MARK: Properties - Touch Area
    public var touchPaddingInsets: UIEdgeInsets = .zero

    // MARK: Properties - Style

    /// Background is saved to update gradient background when theme changed
    private var backgroundValue: Background = .view(.red) { didSet { _updateBackground() } }

    private func _updateBackground() {

        @inline(__always)
        func removeGradient() {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
        }

        switch backgroundValue {
        case .view(let color):
            removeGradient()
            layer.backgroundColor = nil
            backgroundColor = color
        case .layer(let color):
            removeGradient()
            backgroundColor = nil
            layer.backgroundColor = color?.cgColor
        case .gradient(let gradient):
            let gradientLayer: CAGradientLayer = gradientLayer ?? CAGradientLayer()
            self.gradientLayer = gradientLayer

            gradientLayer.colors = gradient.colors.map(\.cgColor)
            gradientLayer.startPoint = gradient.from
            gradientLayer.endPoint = gradient.to

            layer.insertSublayer(gradientLayer, at: 0)

            backgroundColor = nil
            layer.backgroundColor = nil
        }
    }

    public var gradientLayer: CAGradientLayer?
    public weak var maskLayer: CAShapeLayer?
    public var borderLayer: CAShapeLayer?
    public var lineLayer: CAShapeLayer?

    public var shadowValue: Shadow?
    public var cornerValue: Corner?
    public var borderValue: Border?
    public var lineValue: EdgeLine?

    // MARK: Properties - Actions

    public var tapClosure: VoidClosure?
    private var tapRecognizer: UITapGestureRecognizer?

    public var highlightAnimation: HighlightAnimationProtocol?

    // MARK: Methods - Layout

    public final override func sizeThatFits(_ size: CGSize) -> CGSize {
        var result: CGSize = .zero

        let width = self.size.width.equalValue
        let height = self.size.height.equalValue

        if let width = width, let height = height {
            result = CGSize(width: width, height: height)
        } else {
            var sizeToFit = size
            sizeToFit.width = width ?? sizeToFit.width
            sizeToFit.height = height ?? sizeToFit.height
            sizeToFit -= paddingInsets.size

            if let sizeThatFits = contentSizeThatFits(sizeToFit) {
                result = sizeThatFits + paddingInsets.size
            }
            if let width = width {
                result.width = width
            }
            if let height = height {
                result.height = height
            }

        }
        if let minSizeValue = minSizeValue {
            result.width = max(result.width, minSizeValue.width)
            result.height = max(result.height, minSizeValue.height)
        }
        if let maxSizeValue = maxSizeValue {
            result.width = min(result.width, maxSizeValue.width)
            result.height = min(result.height, maxSizeValue.height)
        }
        return result
    }

    open func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        guard subviews.count > 0 else { return nil }
        return subviews.map { $0.sizeThatFits(size) }.reduce(into: CGSize.zero) { result, size in
            result.width = max(result.width, size.width)
            result.height = max(result.height, size.height)
        }
    }

    open override func layoutSubviews() {
        nodeLayoutSubviews()
        gradientLayer?.frame = bounds
        _layoutCorner()
        _layoutBorder()
        _layoutLine()
        super.layoutSubviews()
    }

    open func nodeLayoutSubviews() {
        let subviewFrame = bounds.inset(by: paddingInsets)
        for view in subviews {
            guard view.translatesAutoresizingMaskIntoConstraints else { continue }
            if contentMode == .top, case .equal = size.height {
                let fitsize = view.sizeThatFits(subviewFrame.size)
                if fitsize.height < subviewFrame.height {
                    var frame = subviewFrame
                    frame.size.height = fitsize.height
                    view.viewNodesSetFrame(frame)
                } else {
                    view.viewNodesSetFrame(subviewFrame)
                }
            } else {
                view.viewNodesSetFrame(subviewFrame)
            }
        }
    }

    // MARK: Methods -Touch Area

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.increase(by: touchPaddingInsets).contains(point)
    }

    // MARK: Methods - Style

    open func prepareForReuse() {

    }

    // MARK: - Setters

    @discardableResult
    public func identifier(_ newValue: String?) -> Self {
        identifierValue = newValue
        return self
    }

    @discardableResult
    open func hidden(_ newValue: Bool) -> Self {
        isHidden = newValue
        return self
    }

    // MARK: Setters - Layout

    @discardableResult
    public func minSize(_ newValue: CGSize?) -> Self {
        minSizeValue = newValue
        return self
    }

    @discardableResult
    public func minWidth(_ newValue: CGFloat) -> Self {
        var size = minSizeValue ?? .zero
        size.width = newValue
        minSizeValue = size
        return self
    }

    @discardableResult
    public func minHeight(_ newValue: CGFloat) -> Self {
        var size = minSizeValue ?? .zero
        size.height = newValue
        minSizeValue = size
        return self
    }

    @discardableResult
    public func maxSize(_ newValue: CGSize?) -> Self {
        maxSizeValue = newValue
        return self
    }

    @discardableResult
    public func maxWidth(_ newValue: CGFloat) -> Self {
        var size = maxSizeValue ?? CGSize(width: CGFloat.greatestFiniteMagnitude,
                                          height: CGFloat.greatestFiniteMagnitude)
        size.width = newValue
        maxSizeValue = size
        return self
    }

    @discardableResult
    public func maxHeight(_ newValue: CGFloat) -> Self {
        var size = maxSizeValue ?? .zero
        size.height = newValue
        maxSizeValue = size
        return self
    }

    @discardableResult
    public func size(_ newValue: CGFloat) -> Self {
        size.width = .equal(newValue)
        size.height = .equal(newValue)
        return self
    }

    @discardableResult
    public func width(_ newValue: CGFloat) -> Self {
        size.width = .equal(newValue)
        return self
    }

    @discardableResult
    public func height(_ newValue: CGFloat) -> Self {
        size.height = .equal(newValue)
        return self
    }

    @discardableResult
    public func size(_ newValue: Size.Dimension) -> Self {
        size.width = newValue
        size.height = newValue
        return self
    }

    @discardableResult
    public func size(_ newValue: CGSize) -> Self {
        size.width = .equal(newValue.width)
        size.height = .equal(newValue.height)
        return self
    }

    @discardableResult
    public func width(_ newValue: Size.Dimension) -> Self {
        size.width = newValue
        return self
    }

    @discardableResult
    open func height(_ newValue: Size.Dimension) -> Self {
        size.height = newValue
        return self
    }

    @discardableResult
    public func padding(_ newValue: UIEdgeInsets) -> Self {
        paddingInsets = newValue
        return self
    }

    // MARK: Setters - Highlight Animation

    @discardableResult
    public func highlightAnimation(animationProtocol: HighlightAnimationProtocol?) -> Self {
        highlightAnimation = animationProtocol
        return self
    }

    // Для удобства
    @discardableResult
    public func highlightAnimation(_ animation: HighlightAnimations?) -> Self {
        highlightAnimation(animationProtocol: animation?.protocol)
    }

    // MARK: Setters - Touch Area

    /// Change view touch size
    ///
    /// .touchPadding(.all(16)) to increase touch area for 16pt from all sides
    /// Only works if the new touch area lies within the boundaries of superview
    /// Otherwise, you need to override point(inside:) of superview
    @discardableResult
    public func touchPadding(_ newValue: UIEdgeInsets) -> Self {
        touchPaddingInsets = newValue
        return self
    }

    @discardableResult
    public func position(_ newValue: Position) -> Self {
        positionValue = newValue
        return self
    }

    // MARK: Setters - Style

    /// Short-hand for background(.view(color))
    @discardableResult
    open func background(color: UIColor) -> Self {
        backgroundValue = .view(color)
        return self
    }

    @discardableResult
    public func backgroundRecursively(color: UIColor) -> Self {
        _backgroundRecursively(color: color)
        return self
    }
    private func _backgroundRecursively(color: UIColor) {
        background(color: color)
        subnodes.forEach { ($0 as? View)?._backgroundRecursively(color: color) }
    }

    @discardableResult
    public func background(gradient colors: [UIColor], from: CGPoint = .top, to: CGPoint = .bottom) -> Self {
        backgroundValue = .gradient(.init(colors: colors, from: from, to: to))
        return self
    }

    @discardableResult
    public func background(gradient colors: UIColor..., from: CGPoint = .top, to: CGPoint = .bottom) -> Self {
        background(gradient: colors, from: from, to: to)
    }

    @discardableResult
    public func background(_ background: Background) -> Self {
        backgroundValue = background
        return self
    }

    // MARK: Setters - Style - Private

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            _updateBackground()
            _updateShadowColor()
            _updateBorderColor()
    }

    // MARK: Opacity

    @discardableResult
    public func opacity(_ newValue: CGFloat) -> Self {
        alpha = newValue
        return self
    }

    // MARK: Corner

    @discardableResult
    public func corner(radius: CGFloat, corners: UIRectCorner = .allCorners, masksToBounds: Bool = true) -> Self {
        // пояснение почему masksToBounds задается отдельно в _layoutCorner()
        layer.masksToBounds = masksToBounds
        cornerValue = .init(radius: radius, corners: corners, masksToBounds: masksToBounds)
        return self
    }

    private func _layoutCorner() {
        // maskToBounds задается во время сета значения, потому что оно ломает тени (:
        //
        // Это происходит из-за того, что при maskToBounds=true тени просто обрезаются и не видны.
        // Лайаут углов происходит в layoutSubviews(), т е каждый раз устанавливается такое значение, которое нужно для углов.
        // А значение maskToBounds для теней ставится только в сеттере
        // Я не знаю как оно работало столько лет, но сегодня последний день регресса, поэтому что-то сильно менять не хочу
        //

        // layer.masksToBounds = cornerValue.masksToBounds
        layer.cornerRadius = cornerValue?.radius ?? 0
        if let corners = cornerValue?.corners.cornerMask {
            layer.maskedCorners = corners
        }
    }

    // MARK: Border

    @discardableResult
    public func border(color: UIColor, width: CGFloat = 1) -> Self {
        borderValue = Border(width: width, color: color)
        return self
    }

    @discardableResult
    public func border(_ border: Border?) -> Self {
        borderValue = border
        return self
    }

    private func _layoutBorder() {
        guard let border = borderValue else { return }
        // Temporary solution made for performance
        layer.borderColor = border.color.cgColor
        layer.borderWidth = border.width
        return

        // TODO: Research for performance
        if let maskLayer = maskLayer, let maskPath = maskLayer.path {
            let borderLayer: CAShapeLayer = self.borderLayer ?? {
                let borderLayer = CAShapeLayer()
                self.borderLayer = borderLayer
                return borderLayer
            }()

            borderLayer.lineWidth = border.width * 2
            borderLayer.strokeColor = border.color.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.path = maskPath
            borderLayer.frame = maskLayer.frame
            layer.addSublayer(borderLayer)
        } else {
            borderLayer?.removeFromSuperlayer()
            borderLayer = nil
            layer.borderColor = border.color.cgColor
            layer.borderWidth = border.width
        }
    }

    private func _updateBorderColor() {
        layer.borderColor = borderValue?.color.cgColor
    }

    // MARK: Line

    @discardableResult
    public func line(edge: UIRectEdge,
                     width: CGFloat = 1,
                     color: UIColor,
                     leadingPadding: CGFloat = 0,
                     trailingPadding: CGFloat = 0,
                     lineDashPattern: [NSNumber]? = nil,
                     isHidden: Bool = false) -> Self {
        lineValue = EdgeLine(edge: edge,
                             width: width,
                             color: color,
                             leadingPadding: leadingPadding,
                             trailingPadding: trailingPadding,
                             lineDashPattern: lineDashPattern,
                             isHidden: isHidden)
        return self
    }

    @discardableResult
    public func lineHidden(_ value: Bool) -> Self {
        lineValue = lineValue?.hidden(value)
        return self
    }

    @discardableResult
    public func removeLine() -> Self {
        lineValue = nil
        lineLayer?.removeFromSuperlayer()
        return self
    }

    private func _layoutLine() {
        self.lineLayer?.removeFromSuperlayer()

        guard let line = lineValue, !line.isHidden else { return }

        let lineLayer: CAShapeLayer = self.lineLayer ?? CAShapeLayer()
        self.lineLayer = lineLayer
        let width: CGFloat = line.width

        lineLayer.strokeColor = line.color.cgColor
        lineLayer.lineDashPattern = line.lineDashPattern
        lineLayer.lineWidth = width

        let path = CGMutablePath()

        if line.edge.contains(.top) {
            path.addLines(between: [CGPoint(x: line.leadingPadding, y: 0),
                                    CGPoint(x: bounds.width - line.trailingPadding, y: 0)])
        }
        if line.edge.contains(.left) {
            path.addLines(between: [CGPoint(x: 0, y: line.leadingPadding),
                                    CGPoint(x: 0, y: bounds.height - width - line.trailingPadding)])
        }
        if line.edge.contains(.bottom) {
            path.addLines(between: [CGPoint(x: line.leadingPadding, y: bounds.height - width),
                                    CGPoint(x: bounds.width - line.trailingPadding, y: bounds.height - width)])
        }
        if line.edge.contains(.right) {
            path.addLines(between: [CGPoint(x: bounds.width, y: line.leadingPadding),
                                    CGPoint(x: bounds.width, y: bounds.height - width - line.trailingPadding)])
        }

        lineLayer.path = path
        self.layer.addSublayer(lineLayer)

    }

    // MARK: Shadow

    @discardableResult
    public func removeShadow() -> Self {
        shadowValue = nil
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        return self
    }

    @discardableResult
    public func shadow(_ shadow: Shadow) -> Self {
        shadowValue = shadow

        _updateShadowColor()

        if let opacity = shadow.opacity {
            layer.shadowOpacity = opacity
        }
        if let radius = shadow.radius {
            layer.shadowRadius = radius
        }
        if let offset = shadow.offset {
            layer.shadowOffset = offset
        }
        layer.masksToBounds = layer.shadowOpacity == 0
        return self
    }

    @discardableResult
    public func shadow(color: UIColor? = nil,
                       opacity: Float? = nil,
                       radius: CGFloat? = nil,
                       offset: CGSize? = nil) -> Self {
        shadow(Shadow(color: color, opacity: opacity, radius: radius, offset: offset))
    }

    private func _updateShadowColor() {
        layer.shadowColor = shadowValue?.color?.cgColor
    }

    // MARK: Setters - Actions

    @discardableResult
    open func onTap(_ value: VoidClosure?) -> Self {
        // TODO: recreate recognizer isn't really necessary
        tapClosure = value
        if let existingRecognizer = tapRecognizer {
            removeGestureRecognizer(existingRecognizer)
        }
        guard value != nil else { return self }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.tapRecognizer = tapRecognizer
        addGestureRecognizer(tapRecognizer)
        return self
    }

    @objc
    open func tapAction() {
        tapClosure?()
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        highlightAnimation?.animate(isHighlighted: true, view: self)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        highlightAnimation?.animate(isHighlighted: false, view: self)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        highlightAnimation?.animate(isHighlighted: false, view: self)
    }
}

extension UIView {

    func viewNodesSetFrame(_ frame: CGRect) {
        // `applyingTransformAnchorPointCenter` doesn't support rotation and custom anchor points.
        // If you need rotation and custom anchor points you can use `_viewNodesSetFrame` or
        // better implement `applying(transform: CGAffineTransform, anchorPoint: CGPoint) -> CGRect`.
        self.frame = frame.applyingTransformAnchorPointCenter(transform)
//        _viewNodesSetFrame(frame)
//        self.frame = frame.applying(transform: transform, anchorPoint: center)
    }

    private func _viewNodesSetFrame(_ frame: CGRect) {
        guard transform != .identity else {
            self.frame = frame
            return
        }
        let transform = self.transform
        self.transform = .identity
        self.frame = frame
        self.transform = transform
    }
}

extension UIView {
    public func dump() {
        dump(0)
    }

    private func dump(_ depth: Int) {
        let prefix = String(repeating: " ", count: depth)
        print("\(prefix)\(self)")
        for view in subviews {
            view.dump(depth + 1)
        }
    }
}

extension UIView {
    static let colorsPallete: [UIColor] = [.green, .yellow, .orange, .red, .purple]

    /// Recursive UIView colorization.
    /// Set view and all his subviews background colors corresponding to hierarchical level
    ///
    /// - Returns: Self
    ///
    @discardableResult
    public func colorize() -> Self {
        colorize(0)
        return self
    }

    private func colorize(_ depth: Int) {
        backgroundColor = Self.colorsPallete[depth % Self.colorsPallete.count]
        for view in subviews {
            view.colorize(depth + 1)
        }
    }

    /// Recursive UIView borders.
    /// Recursivly set a thin border to view and all his subviews
    ///
    /// - Returns: Self
    ///
    @discardableResult
    public func borderize() -> Self {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        for view in subviews {
            view.borderize()
        }
        return self
    }
}
