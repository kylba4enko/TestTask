//
//  AnalyticsServiceTests.swift
//  TransactionsTestTaskTests
//
//  Created by Maxim Kulbachenko on 30.07.2025.
//

import Testing
import Foundation
@testable import TransactionsTestTask

struct AnalyticsServiceTests {
    
    struct TrackEventTests {
        
        let service = AnalyticsServiceImpl()
        
        let calendar = Calendar.current
        let now = Date()
        lazy var startDate = calendar.date(byAdding: .minute, value: -1, to: now)!
        lazy var endDate = calendar.date(byAdding: .minute, value: 1, to: now)!
        
        @Test mutating func trackSingleEvent() throws {
            let event = AnalyticsEvent(name: "user_login", parameters: ["user_id": "123"])
            
            service.track(event: event)
            
            let fetchedEvents = service.fetchEvents(name: "user_login", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 1)
            #expect(fetchedEvents.first?.name == "user_login")
            #expect(fetchedEvents.first?.parameters["user_id"] == "123")
        }
        
        @Test mutating func trackMultipleEvents() throws {
            let event1 = AnalyticsEvent(name: "button_click", parameters: ["button": "save"])
            let event2 = AnalyticsEvent(name: "button_click", parameters: ["button": "cancel"])
            
            service.track(event: event1)
            service.track(event: event2)
            
            let fetchedEvents = service.fetchEvents(name: "button_click", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 2)
        }
        
        @Test mutating func trackEventWithEmptyParameters() throws {
            let event = AnalyticsEvent(name: "app_start", parameters: [:])
            
            service.track(event: event)
            
            let fetchedEvents = service.fetchEvents(name: "app_start", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 1)
            #expect(fetchedEvents.first?.parameters.isEmpty == true)
        }
        
        @Test mutating func trackEventWithEmptyName() throws {
            let event = AnalyticsEvent(name: "", parameters: ["key": "value"])
            
            service.track(event: event)
            
            let fetchedEvents = service.fetchEvents(name: "", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 1)
            #expect(fetchedEvents.first?.name == "")
        }
        
        @Test mutating func trackDuplicateEvents() throws {
            let event1 = AnalyticsEvent(name: "duplicate", parameters: ["key": "value"])
            let event2 = AnalyticsEvent(name: "duplicate", parameters: ["key": "value"])
            
            service.track(event: event1)
            service.track(event: event2)
            
            let fetchedEvents = service.fetchEvents(name: "duplicate", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count >= 1)
        }
    }
    
    struct FetchEventsTests {
        
        let service = AnalyticsServiceImpl()
        
        let calendar = Calendar.current
        let now = Date()
        lazy var startDate = calendar.date(byAdding: .minute, value: -1, to: now)!
        lazy var endDate = calendar.date(byAdding: .minute, value: 1, to: now)!
        
        @Test mutating func fetchEventsWithExactMatch() throws {
            let event = AnalyticsEvent(name: "purchase", parameters: ["amount": "100"])
            
            service.track(event: event)
            
            let fetchedEvents = service.fetchEvents(name: "purchase", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 1)
            #expect(fetchedEvents.first?.name == "purchase")
            #expect(fetchedEvents.first?.parameters["amount"] == "100")
        }
        
        @Test mutating func fetchEventsWithNoMatches() throws {
            let event = AnalyticsEvent(name: "login", parameters: [:])
            
            service.track(event: event)
        
            let fetchedEvents = service.fetchEvents(name: "logout", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.isEmpty)
        }
        
        @Test func fetchEventsOutsideDateRange() throws {
            let event = AnalyticsEvent(name: "test_event", parameters: [:])
            
            service.track(event: event)
            
            let startDate = calendar.date(byAdding: .hour, value: 1, to: now)!
            let endDate = calendar.date(byAdding: .hour, value: 2, to: now)!
            
            let fetchedEvents = service.fetchEvents(name: "test_event", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.isEmpty)
        }
        
        @Test mutating func fetchEventsWithWrongName() throws {
            let event = AnalyticsEvent(name: "correct_name", parameters: ["key": "value"])
            
            service.track(event: event)
            
            let fetchedEvents = service.fetchEvents(name: "wrong_name", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.isEmpty)
        }
        
        @Test mutating func fetchMultipleEventsWithSameName() throws {
            let event1 = AnalyticsEvent(name: "page_view", parameters: ["page": "home"])
            let event2 = AnalyticsEvent(name: "page_view", parameters: ["page": "about"])
            let event3 = AnalyticsEvent(name: "page_view", parameters: ["page": "contact"])
            
            service.track(event: event1)
            service.track(event: event2)
            service.track(event: event3)
            
            let fetchedEvents = service.fetchEvents(name: "page_view", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 3)
            
            let pages = fetchedEvents.map { $0.parameters["page"] ?? "" }
            #expect(pages.contains("home"))
            #expect(pages.contains("about"))
            #expect(pages.contains("contact"))
        }
        
        @Test mutating func fetchEventsReturnsSortedResults() throws {
            let event1 = AnalyticsEvent(name: "test", parameters: ["order": "1"])
            service.track(event: event1)
            
            Thread.sleep(forTimeInterval: 0.001)
            
            let event2 = AnalyticsEvent(name: "test", parameters: ["order": "2"])
            service.track(event: event2)
            
            Thread.sleep(forTimeInterval: 0.001)
            
            let event3 = AnalyticsEvent(name: "test", parameters: ["order": "3"])
            service.track(event: event3)
            
            let fetchedEvents = service.fetchEvents(name: "test", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.count == 3)
            
            for i in 0..<fetchedEvents.count-1 {
                #expect(fetchedEvents[i].date <= fetchedEvents[i+1].date)
            }
        }
        
        @Test func fetchEventsWithInvalidDateRange() throws {
            let event = AnalyticsEvent(name: "test", parameters: [:])
            
            service.track(event: event)
        
            let startDate = calendar.date(byAdding: .hour, value: 1, to: now)!
            let endDate = calendar.date(byAdding: .hour, value: -1, to: now)!
  
            let fetchedEvents = service.fetchEvents(name: "test", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.isEmpty)
        }
    }
    
    struct EdgeCaseTests {
        
        let service = AnalyticsServiceImpl()
        
        @Test func emptyService() throws {
            let calendar = Calendar.current
            let now = Date()
            let startDate = calendar.date(byAdding: .minute, value: -1, to: now)!
            let endDate = calendar.date(byAdding: .minute, value: 1, to: now)!
            
            let fetchedEvents = service.fetchEvents(name: "any_name", startDate: startDate, endDate: endDate)
            
            #expect(fetchedEvents.isEmpty)
        }
    }
}
