//
//  BitcoinRate.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 29.07.2025.
//

struct BitcoinRate: Decodable {
    let bitcoin: Price
    
    struct Price: Decodable {
        let usd: Double
    }
}
