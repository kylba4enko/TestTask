//
//  FormattServiceTests.swift
//  TransactionsTestTaskTests
//
//  Created by Maxim Kulbachenko on 30.07.2025.
//

import Testing
import Foundation
@testable import TransactionsTestTask

struct FormattServiceTests {

    struct FormattCurrencyTests {
        
        @Test(arguments: [
            (1.23456789, Currency.btc, "₿  1.2346"),
            (0.0, Currency.btc, "₿  0.0000"),
            (-5.6789, Currency.btc, "₿  -5.6789"),
            (0.00001234, Currency.btc, "₿  0.0000")
        ])
        func btcCurrencyFormatting(value: Double, currency: Currency, expected: String) throws {
            let result = FormattService.formattCurrency(value, currency: currency)
            #expect(result == expected)
        }
        
        @Test(arguments: [
            (1234.567, Currency.usd, "1 234,57 US$"),
            (0.0, Currency.usd, "0,00 US$"),
            (-99.99, Currency.usd, "-99,99 US$")
        ])
        func usdCurrencyFormatting(value: Double, currency: Currency, expected: String) throws {
            let result = FormattService.formattCurrency(value, currency: currency)
            #expect(result == expected)
        }
    }

    struct FormattTimeTests {
        
        @Test func formattTime_Noon() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 12, minute: 0))!
            let result = FormattService.formattTime(date)
            #expect(result == "12:00")
        }
        
        @Test func formattTime_BeforeMidnight() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 23, minute: 59))!
            let result = FormattService.formattTime(date)
            #expect(result == "23:59")
        }
        
        @Test func formattTime_EarlyMorning() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 1, minute: 1))!
            let result = FormattService.formattTime(date)
            #expect(result == "01:01")
        }
    }
    
    struct FormattDayTests {
        
        private func expectedDateString(for date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        @Test func formattDay_NewYear() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
            let result = FormattService.formattDay(date)
            let expected = expectedDateString(for: date)
            #expect(result == expected)
        }
        
        @Test func formattDay_ChristmasEve() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2024, month: 12, day: 24))!
            let result = FormattService.formattDay(date)
            let expected = expectedDateString(for: date)
            #expect(result == expected)
        }
        
        @Test func formattDay_LeapYearDay() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 2024, month: 2, day: 29))!
            let result = FormattService.formattDay(date)
            let expected = expectedDateString(for: date)
            #expect(result == expected)
        }
        
        @Test func formattDay_DistantPastDate() throws {
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: DateComponents(year: 1900, month: 6, day: 15))!
            let result = FormattService.formattDay(date)
            let expected = expectedDateString(for: date)
            #expect(result == expected)
        }
    }
}
