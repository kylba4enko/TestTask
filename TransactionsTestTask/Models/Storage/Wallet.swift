//
//  Wallet.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import Foundation
import CoreData

final class Wallet: NSManagedObject {
    @NSManaged public var currency: String
    @NSManaged public var balance: Double
    @NSManaged public var id: UUID
    @NSManaged public var transactions: NSSet
}
