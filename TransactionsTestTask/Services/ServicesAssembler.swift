//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

/// Services Assembler is used for Dependency Injection
/// There is an example of a _bad_ services relationship built on `onRateUpdate` callback
/// This kind of relationship must be refactored with a more convenient and reliable approach
///
/// It's ok to move the logging to model/viewModel/interactor/etc when you have 1-2 modules in your app
/// Imagine having rate updates in 20-50 diffent modules
/// Make this logic not depending on any module
enum ServicesAssembler {

    /// Created ratePublisher instead of callback in BitcoinRateService
    /// so now it takes as many subscribes as needed in any modules
    ///
    /// Created AppModule which starts in AppDelegate
    /// this class takes BitcoinRateService and AnalyticsService as arguments
    /// and responsible for rate updates listening and analytics event loging
    /// so ServicesAssembler does not responsible for this logic anymore
    ///
    static let bitcoinRateService: PerformOnce<BitcoinRateService> = {
         { BitcoinRateServiceImpl() }
    }()

    static let analyticsService: PerformOnce<AnalyticsService> = {
         { AnalyticsServiceImpl() }
    }()
    
    static let storageService: PerformOnce<StorageService> = {
         { StorageServiceImpl() }
    }()
}
