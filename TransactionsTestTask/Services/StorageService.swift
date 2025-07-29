//
//  StorageService.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 28.07.2025.
//

import CoreData

protocol StorageService {
    func fetchWalletBalance(_ wallet: Wallet) -> Double
    func fetchWallet(currency: Currency) -> Wallet?
    func addWallet(currency: Currency) -> Wallet
    
    func fetchTransactionsCount(for wallet: Wallet) -> Int
    func fetchTransactions(for wallet: Wallet, offset: Int, limit: Int) -> [Transaction]
    func addTransaction(amount: Double, category: TransactionCategory?, to wallet: Wallet)
    
    func fetchCurrencyRate(for currency: Currency) -> CurrencyRate?
    func addCurrencyRate(_ rate: Double, for currency: Currency)
}

final class StorageServiceImpl: StorageService {

    private let modelName = "TransactionsTestTask"
    
    private lazy var persistentContainer: NSPersistentContainer = {
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Unable to locate model")
        }
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func fetchWalletBalance(_ wallet: Wallet) -> Double {
        let sumExpression = NSExpressionDescription()
        sumExpression.name = "totalAmount"
        sumExpression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        sumExpression.expressionResultType = .doubleAttributeType
        
        let request = NSFetchRequest<NSDictionary>(entityName: "Transaction")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [sumExpression]
        request.predicate = NSPredicate(format: "wallet == %@", wallet)

        do {
            if let result = try context.fetch(request).first, let total = result["totalAmount"] as? Double {
                return total
            }
        } catch {
            // log error
        }
        return 0
    }
    
    func fetchWallet(currency: Currency) -> Wallet? {
        let request: NSFetchRequest<Wallet> = NSFetchRequest<Wallet>(entityName: "Wallet")
        request.predicate = NSPredicate(format: "currency == %d", currency.rawValue)
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            // log error
        }
        return nil
    }
    
    func addWallet(currency: Currency) -> Wallet {
        let newWallet = Wallet(context: context)
        newWallet.id = UUID()
        newWallet.currency = currency
        do {
            try context.save()
        } catch {
            // log error
        }
        return newWallet
    }
    
    func fetchTransactionsCount(for wallet: Wallet) -> Int {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "wallet == %@", wallet)
        do {
            return try context.count(for: request)
        } catch {
            // log error
        }
        return 0
    }

    func fetchTransactions(for wallet: Wallet, offset: Int, limit: Int) -> [Transaction] {
        let request = NSFetchRequest<Transaction>(entityName: "Transaction")
        request.predicate = NSPredicate(format: "wallet == %@", wallet)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchOffset = offset
        request.fetchLimit = limit
        do {
            return try context.fetch(request)
        } catch {
            // log error
        }
        return []
    }
    
    func addTransaction(amount: Double, category: TransactionCategory?, to wallet: Wallet) {
        let newTransaction = Transaction(context: context)
        newTransaction.id = UUID()
        newTransaction.amount = amount
        newTransaction.category = category?.rawValue
        newTransaction.date = Date()
        newTransaction.wallet = wallet
        do {
            try context.save()
        } catch {
            // log error
        }
    }
    
    func fetchCurrencyRate(for currency: Currency) -> CurrencyRate? {
        let request = NSFetchRequest<CurrencyRate>(entityName: "CurrencyRate")
        request.predicate = NSPredicate(format: "currency == %d", currency.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        do {
            return try context.fetch(request).first
        } catch {
            // log error
        }
        return nil
    }
    
    func addCurrencyRate(_ rate: Double, for currency: Currency) {
        let newRate = CurrencyRate(context: context)
        newRate.id = UUID()
        newRate.date = Date()
        newRate.rate = rate
        newRate.currency = currency
        do {
            try context.save()
        } catch {
            // log error
        }
    }
}
