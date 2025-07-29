//
//  UserAlertFactory.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 29.07.2025.
//

import UIKit

enum UserAlertFactory {
    case invalidAmount
    case topUp(currency: Currency, onSubmit: (String?) -> ())
    
    var viewController: UIAlertController {
        switch self {
        case .invalidAmount:
            let alert = UIAlertController(title: "Invalid amount",
                                          message: "Please enter a valid amount greater than zero.",
                                          preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            return alert
            
        case .topUp(let currency, let onSubmit):
            let alert = UIAlertController(title: "Top Up",
                                          message: "Enter amount in \(currency.abbreviation)",
                                          preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Amount"
                textField.keyboardType = .decimalPad
                alert.addAction(.init(title: "Add", style: .default, handler: { _ in
                    onSubmit(textField.text)
                }))
            }
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            return alert
        }
    }
}
