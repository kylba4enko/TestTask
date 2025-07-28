//
//  Coordinator.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import UIKit

protocol Coordinator {
    var rootNavigationController: UINavigationController { get }
    func start()
}

final class AppCoordinator: Coordinator {
    
    let rootNavigationController: UINavigationController
    
    init(rootNavigationController: UINavigationController = .init()) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        let transactionsViewController = TransactionsViewController()
        rootNavigationController.viewControllers = [transactionsViewController]
    }
}
