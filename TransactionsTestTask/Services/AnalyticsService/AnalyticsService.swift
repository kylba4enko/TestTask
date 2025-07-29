//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

/// Analytics Service is used for events logging
/// The list of reasonable events is up to you
/// It should be possible not only to track events but to get it from the service
/// The minimal needed filters are: event name and date range
/// The service should be covered by unit tests
protocol AnalyticsService: AnyObject {
    
    func track(event: AnalyticsEvent)
    func fetchEvents(name: String, startDate: Date, endDate: Date) -> [AnalyticsEvent]
}

final class AnalyticsServiceImpl: AnalyticsService {
    
    private var events: Set<AnalyticsEvent> = []
    
    func track(event: AnalyticsEvent) {
        events.insert(event)
    }
    
    func fetchEvents(name: String, startDate: Date, endDate: Date) -> [AnalyticsEvent] {
        events.filter { event in
            event.name == name &&
            event.date >= startDate &&
            event.date <= endDate
        }.sorted { $0.date < $1.date }
    }
}
