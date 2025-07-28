//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import UIKit

final class AddTransactionViewController: UIViewController {
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categorySegmented: UISegmentedControl = {
        let control = UISegmentedControl(items: TransactionCategory.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(amountTextField)
        view.addSubview(categorySegmented)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            amountTextField.heightAnchor.constraint(equalToConstant: 48),
            
            categorySegmented.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 32),
            categorySegmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            categorySegmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            addButton.topAnchor.constraint(equalTo: categorySegmented.bottomAnchor, constant: 48),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func didTapAdd() {
        let amountText = amountTextField.text ?? ""
        let amount = Double(amountText) ?? 0
        let category = TransactionCategory.allCases[categorySegmented.selectedSegmentIndex]
    }
}
