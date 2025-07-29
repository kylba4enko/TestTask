//
//  AppModule.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 29.07.2025.
//

import Combine

final class AppModule {
    
    private let bitcoinRateService: BitcoinRateService
    private let analyticsService: AnalyticsService
    private let storageService: StorageService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(bitcoinRateService: BitcoinRateService = ServicesAssembler.bitcoinRateService(),
         analyticsService: AnalyticsService = ServicesAssembler.analyticsService(),
         storageService: StorageService = ServicesAssembler.storageService()) {
        
        self.bitcoinRateService = bitcoinRateService
        self.analyticsService = analyticsService
        self.storageService = storageService
    }
    
    func start() {
        bitcoinRateService.ratePublisher
            .sink { [weak self] rate in
                let event = AnalyticsEvent(name: "bitcoin_rate_update",
                                           parameters: ["rate": String(format: "%.2f", rate)])
                self?.analyticsService.track(event: event)
            }
            .store(in: &cancellables)
        
        storageService.errorPublisher
            .sink { [weak self] error in
                let event = AnalyticsEvent(name: "storage_error",
                                           parameters: ["error": error.localizedDescription])
                self?.analyticsService.track(event: event)
            }.store(in: &cancellables)
    }
}
