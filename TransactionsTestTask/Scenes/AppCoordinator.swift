//
//  Coordinator.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

protocol TransactionsListCoordinator: Coordinator {
    func addTransaction(onAddTransaction: @escaping (NewTransaction) -> ())
}

final class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let transactionsViewModel = TransactionsListViewModel(coordinator: self)
        let transactionsViewController = TransactionsListViewController(viewModel: transactionsViewModel)
        navigationController.viewControllers = [transactionsViewController]
    }
}

extension AppCoordinator: TransactionsListCoordinator {
    
    func addTransaction(onAddTransaction: @escaping (NewTransaction) -> ()) {
        let addTransactionViewController = AddTransactionViewController()
        addTransactionViewController.onAddTransaction = { [weak self] newTransaction in
            onAddTransaction(newTransaction)
            self?.navigationController.dismiss(animated: true)
        }
        navigationController.present(addTransactionViewController, animated: true)
    }
}
 

