//
// Created by Никита Шестаков on 22.02.2023.
//

import Foundation

struct CoordinatorEvent {
    enum Flow {
    }

    enum Notification {
    }

    enum EventType {
        case endFlow(Flow)
        case changeFlow(Flow)
        case notify(Notification)
    }

    let type: EventType
    let sender: AnyCoordinator?
}

/// Extension on ``AnyCoordinator`` to get rid of selfRetain & add events functionality
///
/// ``ChainedCoordinator`` already implemented on ``ChainedNavigationCoordinator``
/// and ``ChainedDrawerCoordinator`` to allow smooth transition from current coordinators
///
/// Main benefits:
/// * Better memory management (ChainedCoordinator deallocates on dismiss/pop vc as it supposed to be)
/// * No need to store references to concrete child coordinators as var someCoord: Coord?
/// * Ability to send event up the chain from child to distant parent without having direct reference to it
protocol ChainedCoordinator: AnyCoordinator {
    var chainParent: ChainedCoordinator? { get set }
    var chainChildren: [AnyCoordinator] { get set }

    /// Stores child coordinator reference in Array, to prevent deallocation while it is used
    ///
    /// ``removeChain()`` should be called, once child coordinator is not in use anymore
    /// consider using ``ChaindeNavgationCoordinator`` | ``ChainedDrawerCoordinator``
    /// and ``start(in: ChainedCoordinator)`` to automate this process
    func addChain(_ child: AnyCoordinator)

    /// Removes stored child reference from Array
    ///
    /// Once removed child coordinator will be deallocated from memory and should not be used anymore
    /// Also, if ``child`` implements ``ChainedCoordinator`` protocol, all it's children will be removed as well
    func removeChain(_ child: AnyCoordinator)

    /// Removes all childrens & clears reference to ``parent``, aka removes whole chain starting from this coordinator
    func removeSubChain()

    /// Removes ``self`` from ``parent`` & calls ``removesSubChain()`` to remove all childrens
    func removeSelfChain()

    /// Messaging channel for ``ChainedCoordinator``, allows to send events up the chain
    func handleEvent(_ event: CoordinatorEvent)

    /// Stops current and replaces it with needed scene.
    func stop(replacing replacement: ChainedCoordinator)
}

extension ChainedCoordinator {
    var rootChainParent: ChainedCoordinator? {
        chainParent?.rootChainParent ?? self
    }

    var chainToRoot: [ChainedCoordinator] { chainToRoot([]) }

    private func chainToRoot(_ accumulator: [ChainedCoordinator]) -> [ChainedCoordinator] {
        guard let parent = chainParent else {
            return [self] + accumulator
        }
        return parent.chainToRoot([self] + accumulator)
    }
}

extension ChainedCoordinator {
    func addChain(_ child: AnyCoordinator) {
        guard !chainChildren.contains(where: { $0 === child }) else { return }
        chainChildren.append(child)
        if let chained = child as? ChainedCoordinator {
            chained.chainParent = self
        }
    }

    func removeChain(_ child: AnyCoordinator) {
        if let idx = chainChildren.firstIndex(where: { $0 === child }) {
            chainChildren.remove(at: idx)
            (child as? ChainedCoordinator)?.removeSubChain()
        }
    }

    func removeSubChain() {
        for chain in chainChildren {
            removeChain(chain)
        }
        chainParent = nil
    }

    func removeSelfChain() {
        if let parent = chainParent {
            parent.removeChain(self)
        } else {
            removeSubChain()
        }
    }

    func handleEvent(_ event: CoordinatorEvent) {
        chainParent?.handleEvent(event)
    }
}
