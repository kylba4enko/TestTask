//
//  StringExtension.swift
//  TransactionsTestTask
//
//  Created by Maxim Kulbachenko on 29.07.2025.
//

extension Optional where Wrapped == String {
    
    var asDouble: Double? {
        guard let self else { 
            return nil 
        }
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(trimmed)
    }
}
