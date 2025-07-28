//
//  CurrencyRate.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import Foundation
import CoreData

final class CurrencyRate: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var rate: Double
    @NSManaged public var currency: Currency
    @NSManaged public var id: UUID
}
