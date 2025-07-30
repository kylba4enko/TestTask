//
//  StorageServiceTests.swift
//  TransactionsTestTaskTests
//
//  Created by Maxim Kulbachenko on 30.07.2025.
//

import Testing
import Foundation
import CoreData
import Combine
@testable import TransactionsTestTask

/// In case we are testing StorageService - we have to use InMemory mode for storage
/// But there is an unresolved bug in CoreData with some functionality which crashes the tests in this mode so we are using default mode with ability to clean up storege after each test. But StorageService still have isInMemoryStore flag.
/// Bug: https://openradar.appspot.com/12021880


@Suite(.serialized)
struct StorageServiceTests {
    
    static let storeName = "Testing"
    
    @Suite(.serialized)
    final class WalletTests {
        
        let service = StorageServiceImpl(storeName: storeName)
        
        deinit {
            service.cleanup()
        }
        
        @Test func addWallet() throws {
            let wallet = service.addWallet(currency: .btc)
            
            #expect(wallet.currency == .btc)
        }
        
        @Test func fetchWallet() throws {
            let addedWallet = service.addWallet(currency: .usd)
            
            let fetchedWallet = service.fetchWallet(currency: .usd)
            
            #expect(fetchedWallet?.id == addedWallet.id)
            #expect(fetchedWallet?.currency == .usd)
        }
        
        @Test func fetchNonExistentWallet() throws {
            let wallet = service.fetchWallet(currency: .btc)
            
            #expect(wallet == nil)
        }
        
        @Test func fetchWalletBalance_EmptyWallet() throws {
            let wallet = service.addWallet(currency: .btc)
            
            let balance = service.fetchWalletBalance(wallet)
            
            #expect(balance == 0.0)
        }
        
        @Test func fetchWalletBalance_WithTransactions() throws {
            let wallet = service.addWallet(currency: .btc)
            
            service.addTransaction(amount: 100.0, category: .Groceries, to: wallet)
            service.addTransaction(amount: -50.0, category: .Taxi, to: wallet)
            service.addTransaction(amount: 25.0, category: nil, to: wallet)
            
            let balance = service.fetchWalletBalance(wallet)
            
            #expect(balance == 75.0)
        }
        
        @Test func multipleWalletsWithDifferentCurrencies() throws {
            let btcWallet = service.addWallet(currency: .btc)
            let usdWallet = service.addWallet(currency: .usd)
            
            service.addTransaction(amount: 1.5, category: .Electronics, to: btcWallet)
            service.addTransaction(amount: 1000.0, category: .Restaurant, to: usdWallet)
            
            let btcBalance = service.fetchWalletBalance(btcWallet)
            let usdBalance = service.fetchWalletBalance(usdWallet)
            
            #expect(btcBalance == 1.5)
            #expect(usdBalance == 1000.0)
        }
    }
    
    @Suite(.serialized)
    final class TransactionTests {
        
        let service = StorageServiceImpl(storeName: storeName)
        let wallet: Wallet
        
        init() {
            wallet = service.addWallet(currency: .btc)
        }
        
        deinit {
            service.cleanup()
        }
        
        @Test func addTransaction() throws {
            service.addTransaction(amount: 50.0, category: .Groceries, to: wallet)
            
            let transactions = service.fetchTransactions(for: wallet, offset: 0, limit: 10)
            
            #expect(transactions.count == 1)
            #expect(transactions.first?.amount == 50.0)
            #expect(transactions.first?.category == TransactionCategory.Groceries.rawValue)
            #expect(transactions.first?.wallet.id == wallet.id)
        }
        
        @Test func addTransactionWithoutCategory() throws {
            service.addTransaction(amount: -25.0, category: nil, to: wallet)
            
            let transactions = service.fetchTransactions(for: wallet, offset: 0, limit: 10)
            
            #expect(transactions.count == 1)
            #expect(transactions.first?.amount == -25.0)
            #expect(transactions.first?.category == nil)
        }
        
        @Test func fetchTransactionsCount() throws {
            service.addTransaction(amount: 10.0, category: .Taxi, to: wallet)
            service.addTransaction(amount: 20.0, category: .Electronics, to: wallet)
            service.addTransaction(amount: 30.0, category: .Restaurant, to: wallet)
            
            let count = service.fetchTransactionsCount(for: wallet)
            
            #expect(count == 3)
        }
        
        @Test func fetchTransactionsWithPagination() throws {
            for i in 1...25 {
                service.addTransaction(amount: Double(i), category: .Other, to: wallet)
            }
            
            let firstPage = service.fetchTransactions(for: wallet, offset: 0, limit: 10)
            let secondPage = service.fetchTransactions(for: wallet, offset: 10, limit: 10)
            let thirdPage = service.fetchTransactions(for: wallet, offset: 20, limit: 10)
            
            #expect(firstPage.count == 10)
            #expect(secondPage.count == 10)
            #expect(thirdPage.count == 5)
        }
        
        @Test func fetchTransactionsSortedByDate() throws {
            service.addTransaction(amount: 1.0, category: .Groceries, to: wallet)
            Thread.sleep(forTimeInterval: 0.001)
            service.addTransaction(amount: 2.0, category: .Taxi, to: wallet)
            Thread.sleep(forTimeInterval: 0.001)
            service.addTransaction(amount: 3.0, category: .Electronics, to: wallet)
            
            let transactions = service.fetchTransactions(for: wallet, offset: 0, limit: 10)
            
            #expect(transactions.count == 3)
            #expect(transactions[0].amount == 3.0)
            #expect(transactions[1].amount == 2.0)
            #expect(transactions[2].amount == 1.0)
        }
        
        @Test func fetchTransactionsForEmptyWallet() throws {
            let emptyWallet = service.addWallet(currency: .usd)
            let transactions = service.fetchTransactions(for: emptyWallet, offset: 0, limit: 10)
            let count = service.fetchTransactionsCount(for: emptyWallet)
            
            #expect(transactions.isEmpty)
            #expect(count == 0)
        }
    }
    
    @Suite(.serialized)
    final class CurrencyRateTests {
        
        let service = StorageServiceImpl(storeName: storeName)
        
        deinit {
            service.cleanup()
        }
        
        @Test func addCurrencyRate() throws {
            service.addCurrencyRate(45000.50, for: .btc)
            
            let rate = service.fetchCurrencyRate(for: .btc)
            
            #expect(rate?.rate == 45000.50)
            #expect(rate?.currency == .btc)
        }
        
        @Test func fetchNonExistentCurrencyRate() throws {
            let rate = service.fetchCurrencyRate(for: .usd)
            
            #expect(rate == nil)
        }
        
        @Test func fetchLatestCurrencyRate() throws {
            service.addCurrencyRate(45000.0, for: .btc)
            Thread.sleep(forTimeInterval: 0.001)
            service.addCurrencyRate(46000.0, for: .btc)
            Thread.sleep(forTimeInterval: 0.001)
            service.addCurrencyRate(47000.0, for: .btc)
            
            let rate = service.fetchCurrencyRate(for: .btc)
            
            #expect(rate?.rate == 47000.0)
        }
        
        @Test func multipleCurrencyRates() throws {
            service.addCurrencyRate(45000.0, for: .btc)
            service.addCurrencyRate(1.0, for: .usd)
            
            let btcRate = service.fetchCurrencyRate(for: .btc)
            let usdRate = service.fetchCurrencyRate(for: .usd)
            
            #expect(btcRate?.rate == 45000.0)
            #expect(btcRate?.currency == .btc)
            #expect(usdRate?.rate == 1.0)
            #expect(usdRate?.currency == .usd)
        }
    }
}
