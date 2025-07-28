//
//  Wallet.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import Foundation
import CoreData

final class Wallet: NSManagedObject {
    @NSManaged public var balance: Double
    @NSManaged public var currency: Currency
    @NSManaged public var id: UUID
    @NSManaged public var transactions: NSSet
}

@objc
enum Currency: Int16 {
    case btc
    case usd
    
    var abbreviation: String {
        switch self {
        case .btc:
            "BTC"
        case .usd:
            "USD"
        }
    }
}
