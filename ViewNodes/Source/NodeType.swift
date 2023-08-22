//
//  Node.swift
//  ViewNodes
//
//  Created by Maxime Tenth on 10/9/19.
//  Copyright © 2019 vision-invest. All rights reserved.
//

import Foundation

private var nodeStack: [NodeType] = []

public typealias VoidClosure = () -> Void

public func outOfStack<T: NodeType>(_ makeNode: () -> T) -> T {
    let currentStack = nodeStack
    nodeStack = []
    let node = makeNode()
    nodeStack = currentStack
    return node
}

public protocol NodeType: AnyObject {
    var parent: NodeType? { get set }
    var subnodes: [NodeType] { get set }
    func addSubnode(_ node: NodeType)
    func removeFromParent()
}

extension NodeType {
    public func addSubnodes(_ contentClosure: VoidClosure?) {
        parent = nodeStack.last
        parent?.addSubnode(self)
        nodeStack.append(self)
        contentClosure?()
        nodeStack.removeLast()
    }

    public func setSubnodes(_ contentClosure: VoidClosure) {
        parent = nodeStack.last
        nodeStack.append(self)
        subnodes.forEach { $0.parent = nil }
        subnodes.removeAll()
        contentClosure()
        nodeStack.removeLast()
    }

    public func removeFromParent() {
        guard let parentNode = parent else { return }
        if let index = (parentNode.subnodes.firstIndex { $0 === self }) {
            parentNode.subnodes.remove(at: index)
        }
    }
}
