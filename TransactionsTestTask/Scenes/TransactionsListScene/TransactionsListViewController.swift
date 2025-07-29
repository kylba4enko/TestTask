
import UIKit
import Combine

final class TransactionsListViewController: UIViewController {
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Top Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let coinRateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add transaction", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let viewModel: TransactionsListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: TransactionsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        setupTableView()
        bindViewModel()
        viewModel.refreshWallet()
    }
    
    private func setupUI() {
        let balanceStack = UIStackView(arrangedSubviews: [balanceLabel, topUpButton])
        balanceStack.axis = .horizontal
        balanceStack.spacing = 12
        balanceStack.alignment = .center
        balanceStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(balanceStack)
        view.addSubview(coinRateLabel)
        view.addSubview(addTransactionButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            coinRateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            coinRateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            coinRateLabel.widthAnchor.constraint(equalToConstant: 100),
            
            balanceStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            balanceStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            balanceStack.trailingAnchor.constraint(lessThanOrEqualTo: coinRateLabel.leadingAnchor, constant: -8),
            
            addTransactionButton.topAnchor.constraint(equalTo: balanceStack.bottomAnchor, constant: 24),
            addTransactionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addTransactionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 48),
            
            tableView.topAnchor.constraint(equalTo: addTransactionButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        topUpButton.addTarget(self, action: #selector(didTapTopUp), for: .touchUpInside)
        addTransactionButton.addTarget(self, action: #selector(didTapAddTransaction), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(TransactionTableViewCell.self,
                           forCellReuseIdentifier: TransactionTableViewCell.reuseIdentifier)
    }
    
    private func bindViewModel() {
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                guard let self else { return }
                balanceLabel.text = FormattService.formattCurrency(balance, currency: viewModel.currency)
            }
            .store(in: &cancellables)
        
        viewModel.$coinRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.coinRateLabel.text = FormattService.formattCurrency(rate, currency: .usd)
            }
            .store(in: &cancellables)
        
        viewModel.$groupedTransactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapTopUp() {
        let topUpAlert = UserAlertFactory.topUp(currency: viewModel.currency) { [weak self] text in
            guard let amount = text.asDouble, amount > 0 else {
                let amountAlert = UserAlertFactory.invalidAmount
                self?.present(amountAlert.viewController, animated: true)
                return
            }
            self?.viewModel.topUp(amount: amount)
        }
        present(topUpAlert.viewController, animated: true)
    }
    
    @objc private func didTapAddTransaction() {
        viewModel.addTransaction()
    }
}

extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.groupedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.groupedTransactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? TransactionTableViewCell else {
            return TransactionTableViewCell()
        }
        let transaction = viewModel.groupedTransactions[indexPath.section].transactions[indexPath.row]
        cell.configure(transaction: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = viewModel.groupedTransactions[section].date
        return FormattService.formattDay(date)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadTransactions(for: indexPath)
    }
}
