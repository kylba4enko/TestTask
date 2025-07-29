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
    @NSManaged public var category: String?
    @NSManaged public var wallet: Wallet
    
    var isIncome: Bool {
        amount > 0
    }
    
    var currency: Currency {
        wallet.currency
    }
}

enum TransactionCategory: String, CaseIterable {
    case Groceries
    case Taxi
    case Electronics
    case Restaurant
    case Other
}
