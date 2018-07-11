//
//  Coordinator.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

/// The Coordinator protocol
protocol Coordinator: class {

    /// The array containing any child Coordinators
    var childCoordinators: [AnyObject] { get set }
}

extension Coordinator {

    /// Add a child coordinator to the parent
    func addChildCoordinator(_ childCoordinator: AnyObject) {
        childCoordinators.append(childCoordinator)
    }

    /// Remove a child coordinator from the parent
    func removeChildCoordinator(_ childCoordinator: AnyObject) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
}
