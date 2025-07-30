//
//  BitcoinRateServiceTests.swift
//  TransactionsTestTaskTests
//
//  Created by Maxim Kulbachenko on 30.07.2025.
//

import Testing
import Foundation
@testable import TransactionsTestTask
import Combine

@Suite(.serialized)
struct BitcoinRateServiceTests {

    private let apiURL = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd")!
    private let validJSON = """
    {
        "bitcoin": {
            "usd": 45000.50
        }
    }
    """
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
    }
    
    @Test func testRatePublishedWithCorrectInterval() async throws {
        URLProtocolMock.testURLs = [apiURL: validJSON.data(using: .utf8)!]
        URLProtocolMock.response = HTTPURLResponse(
            url: apiURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        URLProtocolMock.error = nil
        
        let requestInterval: TimeInterval = 0.1
        let timeout: TimeInterval = 0.5
        let expectedCalls = Int(timeout / requestInterval)
        
        let service = BitcoinRateServiceImpl(session: session, interval: requestInterval)
        var receivedRates: [Double] = []
        var callTimestamps: [Date] = []
        
        let subscription = service.ratePublisher
            .sink { rate in
                receivedRates.append(rate)
                callTimestamps.append(Date())
            }

        try await Task.sleep(for: .seconds(timeout))
        
        subscription.cancel()

        #expect(receivedRates.count == expectedCalls)
    }
    
    @Test func testInitialRatePublished() async throws {
        URLProtocolMock.testURLs = [apiURL: validJSON.data(using: .utf8)!]
        URLProtocolMock.response = HTTPURLResponse(
            url: apiURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        URLProtocolMock.error = nil
        
        let service = BitcoinRateServiceImpl(session: session, interval: 60)
        var receivedRate: Double?
        
        let subscription = service.ratePublisher
            .sink { rate in
                receivedRate = rate
            }
        
        try await Task.sleep(for: .seconds(1))
        
        subscription.cancel()
        
        #expect(receivedRate == 45000.50)
    }
    
    @Test func testErrorHandling() async throws {
        URLProtocolMock.testURLs = [:]
        URLProtocolMock.response = nil
        URLProtocolMock.error = URLError(.notConnectedToInternet)
        
        let service = BitcoinRateServiceImpl(session: session, interval: 0.1)
        var receivedRates: [Double] = []
        
        let subscription = service.ratePublisher
            .sink { rate in
                receivedRates.append(rate)
            }
        
        try await Task.sleep(for: .seconds(0.3))
        
        subscription.cancel()
        
        #expect(receivedRates.isEmpty)
    }
}
