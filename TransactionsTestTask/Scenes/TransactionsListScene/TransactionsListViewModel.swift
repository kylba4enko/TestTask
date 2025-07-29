import Foundation
import Combine

final class TransactionsListViewModel {
    
    private weak var coordinator: TransactionsListCoordinator?
    
    @Published private(set) var currency: Currency = .btc
    @Published private(set) var balance: Double = 0
    @Published private(set) var coinRate: Double = 0
    @Published private(set) var transactions: Set<Transaction> = []
    @Published private(set) var groupedTransactions: [(date: Date, transactions: [Transaction])] = []

    private lazy var wallet: Wallet = {
        storageService.fetchWallet(currency: currency) ?? storageService.addWallet(currency: currency)
    }()
    private let storageService: StorageService
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: TransactionsListCoordinator?,
         storageService: StorageService = ServicesAssembler.storageService()) {
        
        self.coordinator = coordinator
        self.storageService = storageService
        
        $transactions
            .map { txs in
                let grouped = Dictionary(grouping: txs) { tx in
                    Calendar.current.startOfDay(for: tx.date)
                }
                return grouped
                    .map { (date, txs) in (date: date, transactions: txs.sorted { $0.date > $1.date }) }
                    .sorted { $0.date > $1.date }
            }
            .assign(to: &$groupedTransactions)
    }
    
    func topUp(amount: Double) {
        addTransaction(amount: amount)
    }
    
    func updateData() {
        balance = storageService.fetchWalletBalance(wallet)
        transactions = Set(storageService.fetchTransactions(for: wallet, offset: 0, limit: 20))
    }
    
    func addTransaction() {
        coordinator?.addTransaction { [weak self] transaction in
            self?.addTransaction(amount: -abs(transaction.amount), category: transaction.category)
        }
    }
    
    private func addTransaction(amount: Double, category: TransactionCategory? = nil) {
        let _ = storageService.addTransaction(amount: amount, category: category, to: wallet)
        updateData()
    }
    
    private func updateCoinRate(_ rate: Double) {
    }
}
