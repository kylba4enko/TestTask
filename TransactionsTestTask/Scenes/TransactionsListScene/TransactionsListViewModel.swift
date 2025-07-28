import Foundation
import Combine

final class TransactionsListViewModel {
    
    private weak var coordinator: TransactionsListCoordinator?
    
    @Published private(set) var currency: Currency = .btc
    @Published private(set) var balance: Double = 0
    @Published private(set) var coinRate: Double = 0
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var groupedTransactions: [(date: Date, transactions: [Transaction])] = []

    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: TransactionsListCoordinator?) {
        self.coordinator = coordinator
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
    
    func addTransaction(amount: Double, category: TransactionCategory) {
    }
    
    func topUp(amount: Double) {
    }
    
    func updateCoinRate(_ rate: Double) {
    }
    
    func loadInitialData() {
    }
    
    func addTransaction() {
        coordinator?.addTransaction { transaction in
            guard transaction.amount > .zero else { return }
            
        }
    }
}
