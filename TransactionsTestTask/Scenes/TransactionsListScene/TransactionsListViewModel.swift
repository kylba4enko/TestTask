import Foundation
import Combine

final class TransactionsListViewModel {
    
    private weak var coordinator: TransactionsListCoordinator?
    
    private let transactionsPageLimit = 20
    private var totalTransactions = 0
    
    @Published private(set) var currency: Currency = .btc
    @Published private(set) var balance: Double = 0
    @Published private(set) var coinRate: Double = 0
    @Published private(set) var groupedTransactions: [(date: Date, transactions: [Transaction])] = []
    @Published private var transactions: Set<Transaction> = []

    private lazy var wallet: Wallet = {
        storageService.fetchWallet(currency: currency) ?? storageService.addWallet(currency: currency)
    }()
    private let storageService: StorageService
    private let bitcoinRateService: BitcoinRateService
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: TransactionsListCoordinator?,
         storageService: StorageService = ServicesAssembler.storageService(),
         bitcoinRateService: BitcoinRateService = ServicesAssembler.bitcoinRateService()) {
        
        self.coordinator = coordinator
        self.storageService = storageService
        self.bitcoinRateService = bitcoinRateService
        
        listenForTransactions()
        listenForRateUpdates()
    }
    
    func topUp(amount: Double) {
        addTransaction(amount: amount)
    }
    
    func refreshWallet() {
        totalTransactions = storageService.fetchTransactionsCount(for: wallet)
        transactions.removeAll()
        loadBalance()
        loadTransactions()
        loadCurrencyRate()
    }
    
    func loadTransactions(for indexPath: IndexPath) {
        let lastSection = groupedTransactions.count - 1
        let lastRow = groupedTransactions[lastSection].transactions.count - 1
        guard indexPath.section == lastSection, indexPath.row == lastRow, transactions.count < totalTransactions else {
            return
        }
        loadTransactions()
    }
    
    func addTransaction() {
        coordinator?.addTransaction { [weak self] transaction in
            self?.addTransaction(amount: -abs(transaction.amount), category: transaction.category)
        }
    }
    
    private func loadTransactions() {
        let olderTransactions = storageService.fetchTransactions(for: wallet,
                                                                 offset: transactions.count,
                                                                 limit: transactionsPageLimit)
        transactions.formUnion(Set(olderTransactions))
    }
    
    private func addTransaction(amount: Double, category: TransactionCategory? = nil) {
        storageService.addTransaction(amount: amount, category: category, to: wallet)
        refreshWallet()
    }
    
    private func loadBalance() {
        balance = storageService.fetchWalletBalance(wallet)
    }
    
    private func loadCurrencyRate() {
        guard let rate = storageService.fetchCurrencyRate(for: currency)?.rate else {
            return
        }
        coinRate = rate
    }
    
    private func listenForTransactions() {
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
    
    private func listenForRateUpdates() {
        bitcoinRateService.ratePublisher
            .sink { [weak self] rate in
                guard let self else { return }
                self.storageService.addCurrencyRate(rate, for: currency)
                self.loadCurrencyRate()
            }
            .store(in: &cancellables)
    }
}
