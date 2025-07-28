//
//  Transaction.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import Foundation
import CoreData

final class Transaction: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var amount: Double
    @NSManaged public var category: Int16
    @NSManaged public var type: Int16
    @NSManaged public var wallet: Wallet
}

enum TransactionCategory: Int, CaseIterable {
    case groceries
    case taxi
    case electronics
    case restaurant
    case other
    
    var title: String {
        switch self {
        case .groceries:
            "Groceries"
        case .taxi:
            "Taxi"
        case .electronics:
            "Electronics"
        case .restaurant:
            "Restaurant"
        case .other:
            "Other"
        }
    }
}

enum TransactionType: Int {
    case income
    case expense
    
    var title: String {
        switch self {
        case .income:
            "Income"
        case .expense:
            "Outcome"
        }
    }
}
