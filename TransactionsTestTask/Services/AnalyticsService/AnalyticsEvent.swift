//
//  AnalyticsEvent.swift
//  TransactionsTestTask
//
//

import Foundation

struct AnalyticsEvent: Hashable {
    let name: String
    let parameters: [String: String]
    let date: Date = .now
}
