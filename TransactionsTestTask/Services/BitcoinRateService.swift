//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

/// Rate Service should fetch data from https://api.coindesk.com/v1/bpi/currentprice.json
/// Fetching should be scheduled with dynamic update interval
/// Rate should be cached for the offline mode
/// Every successful fetch should be logged with analytics service
/// The service should be covered by unit tests
///
protocol BitcoinRateService: AnyObject {
    var ratePublisher: AnyPublisher<Double, Never> { get }
}

final class BitcoinRateServiceImpl: BitcoinRateService {
    
    var ratePublisher: AnyPublisher<Double, Never> {
        rateSubject.eraseToAnyPublisher()
    }
    
    private let rateSubject = PassthroughSubject<Double, Never>()
    private var cancellable: Set<AnyCancellable> = []
    
    private let apiPath = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    
    init(interval: TimeInterval = 60) {
        fetchBitcoinRate()
        Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchBitcoinRate()
            }
            .store(in: &cancellable)
    }
    
    private func fetchBitcoinRate() {
        guard let apiURL = URL(string: apiPath) else {
            return
        }
        URLSession.shared.dataTaskPublisher(for: apiURL)
            .map(\.data)
            .decode(type: BitcoinRate.self, decoder: JSONDecoder())
            .map(\.bitcoin.usd)
            .replaceError(with: nil)
            .sink { [weak self] rate in
                guard let rate else {
                    return
                }
                self?.rateSubject.send(rate)
            }
            .store(in: &cancellable)
    }
}

