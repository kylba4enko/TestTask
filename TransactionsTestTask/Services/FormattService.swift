import Foundation

struct FormattService {

    static func formattCurrency(_ value: Double, currency: Currency) -> String {
        switch currency {
        case .btc:
            return String(format: "₿  %.4f", value)
        case .usd:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
        }
    }
    
    static func formattTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    static func formattDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 
