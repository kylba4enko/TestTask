//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import UIKit

typealias NewTransaction = (amount: Double, category: TransactionCategory)

final class AddTransactionViewController: UIViewController {
    
    var onAddTransaction: ((NewTransaction) -> Void)?
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Amount"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let categories = TransactionCategory.allCases
    private var selectedCategoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    private func setupUI() {
        view.addSubview(amountTextField)
        view.addSubview(categoryPicker)
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            amountTextField.heightAnchor.constraint(equalToConstant: 48),
            
            categoryPicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 32),
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            categoryPicker.heightAnchor.constraint(equalToConstant: 120),
            
            addButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 48),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func didTapAdd() {
        let amountText = amountTextField.text ?? ""
        let amount = Double(amountText) ?? 0
        let category = categories[selectedCategoryIndex]
        onAddTransaction?(NewTransaction(amount, category))
    }
}

extension AddTransactionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categories[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryIndex = row
    }
}
