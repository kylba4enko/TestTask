//
//  URLProtocolMock.swift
//  TransactionsTestTaskTests
//
//  Created by Maxim Kulbachenko on 30.07.2025.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    static var testURLs = [URL?: Data]()
    static var response: HTTPURLResponse?
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let error = URLProtocolMock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let url = request.url, let data = URLProtocolMock.testURLs[url] {
            client?.urlProtocol(self,
                                didReceive: URLProtocolMock.response ?? HTTPURLResponse(),
                                cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
    }
}
