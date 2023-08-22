//
// Created by Maxime Tenth on 10/14/19.
// Copyright (c) 2019 vision-invest. All rights reserved.
//

import UIKit

public enum Axis: Equatable {
    case vertical, horizontal
}

open class HStack: Stack {

    @discardableResult
    public init() { super.init(axis: .horizontal) }
}

open class VStack: Stack {

    @discardableResult
    public init() { super.init(axis: .vertical) }
}

open class HStackOf<V: View>: StackOf<V> {
    @discardableResult
    public init() { super.init(axis: .horizontal) }

    @discardableResult
    public init(view: @autoclosure @escaping () -> V) {
        super.init(axis: .horizontal, view: view())
    }
}

open class VStackOf<V: View>: StackOf<V> {
    @discardableResult
    public init() { super.init(axis: .vertical) }

    @discardableResult
    public init(view: @autoclosure @escaping () -> V) {
        super.init(axis: .vertical, view: view())
    }
}

// TODO: Implement later
// public class Space: NodeType {
//    public var parent: NodeType?
//    public var subnodes: [NodeType] = []
//    public init() {
//        addSubnodes(nil)
//    }
// }

// TODO [TechTask] [ViewNodes] fix Use of unimplemented initializer 'init()' for class 'ViewNodes.Stack'
open class Stack: View {

    public enum Alignment {
        case begin, middle, end, fill
        static public let left: Alignment = .begin
        static public let top: Alignment = .begin
        static public let center: Alignment = .middle
        static public let right: Alignment = .end
        static public let bottom: Alignment = .end
    }

    public let axis: Axis
    public var alignmentValue: Alignment = .fill
    public var spacingValue: CGFloat = 0

    public var arrangedSubviews: [View] = []

    var templateClosure: ((Int) -> View)?

    public var visibleSubviews: [View] {
        arrangedSubviews.filter { !$0.isHidden }
    }

    public init(axis: Axis) {
        self.axis = axis
        super.init()
    }

    @discardableResult
    public override func content(_ contentClosure: VoidClosure) -> Self {
        super.content(contentClosure)
        arrangedSubviews = nodeSubviews
        return self
    }

    func subviewsSizesThatFit(_ size: CGSize) -> [CGSize] {

        let subviews = visibleSubviews
        let widthToFit = size.width
        let spacings: CGFloat = spacingValue * CGFloat(subviews.count - 1)
        var reserved: CGFloat = 0
        var content: CGFloat = 0
        var fill: CGFloat = 0

        var fillCount: CGFloat = 0

        var sizes: [CGSize] = []
        // horizontal

        switch axis {
        case .horizontal:
            for view in subviews {
                var size: CGSize
                switch view.size.width {
                case .compact:
                    size = view.sizeThatFits(CGSize(width: view.maxSizeValue?.width ?? widthToFit,
                                                    height: .greatestFiniteMagnitude))
                    content += size.width

                case .fill:
                    size = .zero
                    fillCount += 1
                case .equal(let width):
                    size = CGSize(width: width, height: 0)
                    reserved += width
                }
                // FIXME: hot fix
                // maybe there is better solution
                if let height = view.size.height.equalValue {
                    size.height = max(size.height, height)
                }
                sizes.append(size)
            }

            fill = size.width - reserved - content - spacings

            return subviews.enumerated().map { (index, view) -> CGSize in

                switch view.size.width {
                case .compact:
                    return sizes[index]
                case .fill:
                    let width = fill / fillCount
                    let sizeToFit = CGSize(width: width, height: size.height)
                    var sizeThatFits = view.sizeThatFits(sizeToFit)
                    sizeThatFits.width = width
                    return sizeThatFits
                case .equal(let width):
                    let sizeToFit = CGSize(width: width, height: size.height)
                    var sizeThatFits = view.sizeThatFits(sizeToFit)
                    sizeThatFits.width = width
                    return sizeThatFits
                }
            }
        case .vertical:
            for view in subviews {
                let size: CGSize
                switch view.size.height {
                case .compact:
                    size = view.sizeThatFits(CGSize(width: widthToFit,
                                                    height: .greatestFiniteMagnitude))
                    content += size.height

                case .fill:
                    size = .zero
                    fillCount += 1
                case .equal(let height):
                    size = CGSize(width: 0, height: height)
                    reserved += height
                }
                sizes.append(size)
            }

            fill = size.height - reserved - content - spacings

            return subviews.enumerated().map { (index, view) -> CGSize in

                switch view.size.height {
                case .compact:
                    return sizes[index]
                case .fill:
                    let height = fill / fillCount
                    let sizeToFit = CGSize(width: size.width, height: height)
                    var sizeThatFits = view.sizeThatFits(sizeToFit)
                    sizeThatFits.height = height
                    return sizeThatFits
                case .equal(let height):
                    let sizeToFit = CGSize(width: size.width, height: height)
                    var sizeThatFits = view.sizeThatFits(sizeToFit)
                    sizeThatFits.height = height
                    return sizeThatFits
                }
            }
        }
    }

    open override func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        let subviews = visibleSubviews
        guard subviews.count > 0 else { return .zero }
        let sizes = subviewsSizesThatFit(size)

        let height: CGFloat
        let width: CGFloat
        switch axis {
        case .horizontal:
            // maxHeight
            height = sizes.map(\.height).reduce(CGFloat(0), { max($0, $1) })
            // totalWidth
            width = sizes.map(\.width).reduce(CGFloat(0), +) + spacingValue * CGFloat(subviews.count - 1)
        case .vertical:
            // maxWeight
            width = sizes.map(\.width).reduce(CGFloat(0), { max($0, $1) })
            // totalHeight
            height = sizes.map(\.height).reduce(CGFloat(0), +) + spacingValue * CGFloat(subviews.count - 1)
        }

        assert(height.isFinite && width.isFinite, "Incorrect dimension")
        return CGSize(width: width, height: height)
    }

    open override func nodeLayoutSubviews() {
        // TODO: possibly we have not to filter =)
        let subviews = visibleSubviews.filter { $0.translatesAutoresizingMaskIntoConstraints }
        let contentFrame = bounds.inset(by: paddingInsets)
        let sizes = subviewsSizesThatFit(contentFrame.size)

        // TODO: implement for both axis
        let spacing: CGFloat
        if axis == .horizontal {
            switch size.width {
            case .compact:
                spacing = spacingValue
            default:
                spacing = (contentFrame.width - sizes.map(\.width).reduce(0, +)) / CGFloat(subviews.count - 1)
            }
        } else {
            switch size.height {
            case .compact:
                spacing = spacingValue
            default:
                spacing = (contentFrame.height - sizes.map(\.height).reduce(0, +)) / CGFloat(subviews.count - 1)
            }
        }

        switch axis {
        case .horizontal:
            var lastPos = paddingInsets.left
            for (index, view) in subviews.enumerated() {
                let height: CGFloat
                if view.size.height == .fill || alignmentValue == .fill {
                    height = contentFrame.height
                } else {
                    height = sizes[index].height
                }

                let y: CGFloat
                switch alignmentValue {
                case .fill, .begin:
                    y = paddingInsets.top
                case .middle:
                    y = paddingInsets.top + (contentFrame.height - height) / 2
                case .end:
                    y = paddingInsets.top + contentFrame.height - height
                }

                let frame = CGRect(x: lastPos, y: y, width: sizes[index].width, height: height)
                view.viewNodesSetFrame(frame)
                view.setNeedsLayout()
                lastPos = frame.maxX + spacing
            }
        case .vertical:
            var lastPos = paddingInsets.top
            for (index, view) in subviews.enumerated() {
                let width: CGFloat

                //            height = sizes[index].height
                if view.size.width == .fill || alignmentValue == .fill {
                    width = contentFrame.width
                } else {
                    width = sizes[index].width
                }

                let x: CGFloat
                switch alignmentValue {
                case .fill, .begin:
                    x = paddingInsets.left
                case .middle:
                    x = paddingInsets.left + (contentFrame.width - width) / 2
                case .end:
                    x = paddingInsets.left + contentFrame.width - width
                }

                let frame = CGRect(x: x, y: lastPos, width: width, height: sizes[index].height)
                view.viewNodesSetFrame(frame)
                view.setNeedsLayout()
                lastPos = frame.maxY + spacing
            }
        }

    }

    @discardableResult
    public func alignment(_ newValue: Alignment) -> Self {
        alignmentValue = newValue
        return self
    }

    @discardableResult
    public func spacing(_ newValue: CGFloat) -> Self {
        spacingValue = newValue
        return self
    }

    /// Если нужно добавить ноду и ожидается лэйаут как для стэка, то используйте эту функцию
    public func addArrangedSubview(_ view: View) {
        arrangedSubviews.append(view)
        addSubnode(view)
    }
}

extension CGRect {
    init(primarySize: CGFloat,
         secondarySize: CGFloat,
         primaryOrigin: CGFloat,
         secondaryOrigin: CGFloat,
         axis: Axis) {
        switch axis {
        case .horizontal:
            self.init(origin: CGPoint(x: primaryOrigin, y: secondaryOrigin),
                      size: CGSize(width: primarySize, height: secondarySize))
        case .vertical:
            self.init(origin: CGPoint(x: secondaryOrigin, y: primaryOrigin),
                      size: CGSize(width: secondarySize, height: primarySize))
        }
    }
}

open class StackOf<V: View>: Stack {

    private func _subviewsOf(_ subviews: [UIView]) -> [V] { subviews.compactMap { $0 as? V } }
    public var subviewsOf: [V] { _subviewsOf(subviews) }
    public var visibleSubviewsOf: [V] { _subviewsOf(visibleSubviews) }

    open override func prepareForReuse() {
        super.prepareForReuse()
        arrangedSubviews.forEach { $0.prepareForReuse() }
    }

    open override func content(_ contentClosure: VoidClosure) -> Self {
        assert(false, "Use `template` to define content")
        return self
    }

    // Для потомков
    public override init(axis: Axis) {
        super.init(axis: axis)
    }

    public init(axis: Axis, view: @autoclosure @escaping () -> V) {
        super.init(axis: axis)
        template(view: view())
    }

    @discardableResult
    public func template(view: @autoclosure @escaping () -> V) -> Self {
        template(view)
    }

    @discardableResult
    public func template(_ newValue: @escaping () -> V) -> Self {
        templateClosure = { _ in newValue() }
        return self
    }

    @discardableResult
    public func template(_ newValue: @escaping (Int) -> V) -> Self {
        templateClosure = newValue
        return self
    }

    public func update<Model>(with models: [Model], _ updateView: (V, Model, Int) -> Void) {
        guard let subviewPrototype = templateClosure else { return templateAssert() }
        let countDiff = subviews.count - models.count
        if countDiff < 0 {
            let neededViewsCount = -countDiff
            for index in 0..<neededViewsCount {
                let view = subviewPrototype(index)
                addSubview(view)
                arrangedSubviews.append(view)
            }
        }
        for (index, view) in subviews.enumerated() {
            view.isHidden = index < countDiff
        }
        let visibleSubviews = self.visibleSubviews
        for (index, model) in models.enumerated() {
            let view: V! = visibleSubviews[index] as? V
            updateView(view, model, index)
        }
    }

    public func update<Model>(with models: [Model], _ updateView: (V, Model) -> Void) {
        update(with: models) { view, model, _ in updateView(view, model) }
    }

    public func insert<Model>(at index: Int, with model: Model, _ updateView: (V, Model, Int) -> Void) {
        guard let subviewPrototype = templateClosure else { return templateAssert() }
        guard let view = subviewPrototype(index) as? V else { return }
        if arrangedSubviews.count > index, subviews.count > index {
            insertSubview(view, at: index)
            arrangedSubviews.insert(view, at: index)
        } else {
            addSubview(view)
            arrangedSubviews.append(view)
        }
        updateView(view, model, index)
    }

    @inline(__always)
    private func templateAssert() {
        assertionFailure("use `template` before `update`", file: #fileID, line: #line)
    }
}

open class ZStack: View {
    public var visibleSubviews: [UIView] {
        subviews.filter { !$0.isHidden }
    }

    override public func nodeLayoutSubviews() {
        let subviews = self.subviews.filter { $0.translatesAutoresizingMaskIntoConstraints }
        let contentFrame = bounds.inset(by: paddingInsets)
        for view in subviews {
            var size = view.sizeThatFits(contentFrame.size)
            if let view = view as? View {
                switch view.size.height {
                case .fill: size.height = max(size.height, contentFrame.height)
                case .equal(let fixedHeight): size.height = max(size.height, fixedHeight)
                case .compact: break
                }
                switch view.size.width {
                case .fill: size.width = max(size.width, contentFrame.width)
                case .equal(let fixedWidth): size.width = max(size.width, fixedWidth)
                case .compact: break
                }
            }
            let subviewFrame: CGRect
            switch (view as? View)?.positionValue ?? .fill {
            case .center:
                subviewFrame = CGRect(origin: CGPoint(x: (frame.size.width - size.width) / 2,
                                                      y: (frame.size.height - size.height) / 2),
                                      size: size)
            case .centerLeft:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x,
                                                      y: (frame.size.height - size.height) / 2),
                                      size: size)
            case .centerRight:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x + contentFrame.width - size.width,
                                                      y: (frame.size.height - size.height) / 2),
                                      size: size)
            case .fill:
                subviewFrame = contentFrame
            case .top:
                subviewFrame = CGRect(origin: contentFrame.origin,
                                      size: CGSize(width: contentFrame.width, height: size.height))
            case .bottom:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x,
                                                      y: contentFrame.origin.y + contentFrame.height - size.height),
                                      size: CGSize(width: contentFrame.width, height: size.height))
            case .left:
                subviewFrame = CGRect(origin: contentFrame.origin,
                                      size: CGSize(width: size.width, height: contentFrame.height))
            case .right:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x + contentFrame.width - size.width,
                                                      y: contentFrame.origin.y),
                                      size: CGSize(width: size.width, height: contentFrame.height))

            case .topRight:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x + contentFrame.width - size.width,
                                                      y: contentFrame.origin.y),
                                      size: CGSize(width: size.width, height: size.height))
            case .topLeft:
                subviewFrame = CGRect(origin: contentFrame.origin,
                                      size: CGSize(width: size.width, height: size.height))
            case .bottomRight:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x + contentFrame.width - size.width,
                                                      y: contentFrame.origin.y + contentFrame.height - size.height),
                                      size: CGSize(width: size.width, height: size.height))
            case .bottomLeft:
                subviewFrame = CGRect(origin: CGPoint(x: contentFrame.origin.x,
                                                      y: contentFrame.origin.y + contentFrame.height - size.height),
                                      size: CGSize(width: size.width, height: size.height))
            }

            view.viewNodesSetFrame(subviewFrame)
        }
    }

    override public func contentSizeThatFits(_ size: CGSize) -> CGSize? {
        guard visibleSubviews.count > 0 else { return nil }
        return visibleSubviews.map { $0.sizeThatFits(size) }.reduce(into: .zero) { result, size in
            result.width = max(result.width, size.width)
            result.height = max(result.height, size.height)
        }
    }
}
