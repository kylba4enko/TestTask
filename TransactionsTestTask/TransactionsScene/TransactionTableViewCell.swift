import UIKit

final class TransactionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TransactionTableViewCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    func configure(transaction: Transaction) {
        timeLabel.text = FormatService.formatTime(transaction.date)
        let sign = transaction.isIncome ? "+" : "-"
        let formattedAmount = FormatService.formatCurrency(transaction.amount, currency: transaction.currency)
        amountLabel.text = "\(sign) \(formattedAmount)"
        amountLabel.textColor = transaction.isIncome ? .systemGreen : .systemRed
        categoryLabel.text = transaction.category.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = nil
        amountLabel.text = nil
        categoryLabel.text = nil
        amountLabel.textColor = .label
    }
    
    private func setupUI() {
        container.addArrangedSubview(timeLabel)
        container.addArrangedSubview(categoryLabel)
        contentView.addSubview(container)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
} 
