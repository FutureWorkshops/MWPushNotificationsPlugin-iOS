//
//  RRule.swift
//  MWPushNotificationsPlugin
//
//  Created by Pedro Sebastião on 08/09/2022.
//

import Foundation
import UserNotifications

struct RRule: Codable {
    
    enum CodingKeys: String, CodingKey {
        case freq = "FREQ"
        case interval = "INTERVAL"
        case bySetPos = "BYSETPOS"
        case byYearDay = "BYYEARDAY"
        case byMonth = "BYMONTH"
        case byWeekNo = "BYWEEKNO"
        case byMonthDay = "BYMONTHDAY"
        case byDay = "BYDAY"
        case byHour = "BYHOUR"
        case byMinute = "BYMINUTE"
        case bySecond = "BYSECOND"
        case count = "COUNT"
        case until = "UNTIL"
    }
    
    enum Frequency: String, Codable {
        case yearly = "YEARLY"
        case monthly = "MONTHLY"
        case weekly = "WEEKLY"
        case daily = "DAILY"
        case hourly = "HOURLY"
        case minutely = "MINUTELY"
        case secondly = "SECONDLY"
        
        func incrementDateComponents(increment: Int = 1) -> DateComponents {
            let components: DateComponents
            switch self {
            case .yearly:
                components = DateComponents(year: increment)
            case .monthly:
                components = DateComponents(month: increment)
            case .weekly:
                components = DateComponents(weekOfYear: increment)
            case .daily:
                components = DateComponents(day: increment)
            case .hourly:
                components = DateComponents(hour: increment)
            case .minutely:
                components = DateComponents(minute: increment)
            case .secondly:
                components = DateComponents(second: increment)
            }
            return components
        }
    }
    
    enum Weekday: String, Codable {
        case monday = "MO"
        case tuesday = "TU"
        case wednesday = "WE"
        case thursday = "TH"
        case friday = "FR"
        case saturday = "SA"
        case sunday = "SU"
        
        func integerValue(in calendar: Calendar = .current) -> Int {
            var value: Int
            switch self {
            case .sunday: value = 1
            case .monday: value = 2
            case .tuesday: value = 3
            case .wednesday: value = 4
            case .thursday: value = 5
            case .friday: value = 6
            case .saturday: value = 7
            }
            return value
        }
    }
    
    struct Day: Codable, LosslessStringConvertible {
        
        let position: Int?
        let weekday: Weekday
        
        init(position: Int? = nil, weekday: Weekday) {
            self.position = position
            self.weekday = weekday
        }
        
        var description: String {
            if let position = self.position {
                return "\(String(position))\(self.weekday.rawValue)"
            } else {
                return "\(self.weekday.rawValue)"
            }
        }
        
        init?(_ description: String) {
            let weekdayString = String(description.suffix(2))
            guard let weekday = Weekday(rawValue: weekdayString) else {
                return nil
            }
            self.weekday = weekday
            if description.count > 2 {
                let positionString = description.dropLast(2)
                let position = Int(positionString)
                self.position = position
            } else {
                self.position = nil
            }
        }
        
    }
    
    let freq: Frequency
    let interval: Int?
    let bySetPos: Int?
    let byYearDay: [Int]? // day within a year
    let byMonth: [Int]?
    let byWeekNo: [Int]? // week number within a year
    let byMonthDay: [Int]? // day within a month
    let byDay: [Day]? // weekday
    let byHour: [Int]?
    let byMinute: [Int]?
    let bySecond: [Int]?
    let count: Int?
    let until: Date?
    
    init?(rrule: String) {
        let rule = rrule
            .split(separator: ";")
            .map { (str: Substring) -> (key: String, value: String) in
                let arr = str.split(separator: "=")
                let key = String(arr[0])
                let value = String(arr[1])
                return (key: key, value: value)
            }
            .compactMap({ (key: String, value: String) in
                guard let codingKey = CodingKeys(rawValue: key) else {
                    // discard unknown keys
                    return nil
                }
                return (key: codingKey, value: value)
            })
            .reduce(into: [:]) { (partialResult: inout [CodingKeys: String], item: (key: CodingKeys, value: String)) in
                partialResult[item.key] = item.value
            }
        
        guard let freqString = rule[.freq],
              let freq = Frequency(rawValue: freqString) else {
            return nil
        }
        self.freq = freq
        
        self.interval = Self.process(string: rule[.interval])
        
        self.bySetPos = Self.process(string: rule[.bySetPos])
        self.byYearDay = Self.process(string: rule[.byYearDay])
        self.byMonth = Self.process(string: rule[.byMonth])
        self.byWeekNo = Self.process(string: rule[.byWeekNo])
        self.byMonthDay = Self.process(string: rule[.byMonthDay])
        self.byDay = Self.process(string: rule[.byDay])
        self.byHour = Self.process(string: rule[.byHour])
        self.byMinute = Self.process(string: rule[.byMinute])
        self.bySecond = Self.process(string: rule[.bySecond])
        
        self.count = Self.process(string: rule[.count])
        self.until = Self.process(string: rule[.until])
    }
    
    private static func process<T: LosslessStringConvertible>(string: String?) -> [T]? {
        guard let string = string else {
            return nil
        }
        return string.array()
    }
    
    private static func process<T: LosslessStringConvertible>(string: String?) -> T? {
        guard let string = string else {
            return nil
        }
        return T(string)
    }
    
    func dateComponents() -> [DateComponents] {
        var result: [DateComponents] = []
        
        if let byWeekNo = self.byWeekNo,
           byWeekNo.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byWeekNo
                        .map { weekNo in
                            var dateComponents = dateComponents
                            dateComponents.weekOfYear = weekNo
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let byMonth = self.byMonth,
           byMonth.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byMonth
                        .map { month in
                            var dateComponents = dateComponents
                            dateComponents.month = month
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let byMonthDay = self.byMonthDay,
           byMonthDay.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byMonthDay
                        .map { monthDay in
                            var dateComponents = dateComponents
                            dateComponents.day = monthDay
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let byDay = self.byDay ,
           byDay.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byDay
                        .map { day in
                            var dateComponents = dateComponents
                            dateComponents.weekday = day.weekday.integerValue()
                            dateComponents.weekdayOrdinal = day.position ?? self.bySetPos
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let byHour = self.byHour,
           byHour.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byHour
                        .map { hour in
                            var dateComponents = dateComponents
                            dateComponents.hour = hour
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let byMinute = self.byMinute,
           byMinute.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return byMinute
                        .map { minute in
                            var dateComponents = dateComponents
                            dateComponents.minute = minute
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        if let bySecond = self.bySecond,
           bySecond.count > 0 {
            if result.count == 0 { result = [DateComponents()] }
            let resultComponentsNested: [[DateComponents]] = result
                .map({ dateComponents in
                    return bySecond
                        .map { second in
                            var dateComponents = dateComponents
                            dateComponents.second = second
                            return dateComponents
                        }
                })
            
            let resultComponents: [DateComponents] = resultComponentsNested
                .reduce(into: [], { partialResult, item in
                    partialResult += item
                })
            
            result = resultComponents
        }
        
        return result
    }
    
    func notificationTriggers() -> [UNCalendarNotificationTrigger] {
//        let dateComponents = self.dateComponents()
//        return dateComponents
//            .map { dateComponents in
//                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//            }
        let calendar: Calendar = .current
        return self.allDates(starting: Date(), calendar: calendar)
            .map({ date in
                return calendar.dateComponents([.timeZone, .year, .month, .day, .hour, .minute, .second], from: date)
            })
            .map { dateComponents in
                return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            }
    }
}

private extension String {
    func array<T: LosslessStringConvertible>(separator: Character = ",") -> [T] {
        return self
            .split(separator: separator)
            .compactMap { substring in
                let string = String(substring)
                return T(string)
            }
    }
}

extension Date: LosslessStringConvertible {
    public init?(_ description: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZZZZZ"
        guard let date = formatter.date(from: description) else {
            return nil
        }
        self.init(timeInterval: 0, since: date)
    }
}

extension RRule {
    func alignedDates(starting startingDate: Date, calendar: Calendar = .current) -> [Date] {
        let referenceComponents = calendar.dateComponents(in: calendar.timeZone, from: startingDate)
        var aligned: [DateComponents]
        
        var dates: [Date] = self.dateComponents()
            .compactMap { components in
                var components = components
                
                switch self.freq {
                case .secondly:
                    components.second = referenceComponents.second
                    fallthrough
                case .minutely:
                    components.minute = referenceComponents.minute
                    fallthrough
                case .hourly:
                    components.hour = referenceComponents.hour
                    fallthrough
                case .daily:
                    components.day = referenceComponents.day
                    fallthrough
                case .monthly:
                    components.month = referenceComponents.month
                    fallthrough
                case .yearly:
                    components.year = referenceComponents.year
                case .weekly:
                    components.weekOfYear
                    components.year = referenceComponents.year
                    
                }
                return calendar.date(from: components)
            }
        
        // if there is no component specified, use the `startingDate` as the recurrence base
        if dates.isEmpty {
            dates = [startingDate]
        }
        
        let incrementComponent: DateComponents = self.freq.incrementDateComponents()
        
        let alignedDates: [Date] = dates
            .map { date in
                var newDate: Date = date
                while newDate <= startingDate {
                    newDate = calendar.date(byAdding: incrementComponent, to: newDate)!
                }
                return newDate
            }
            .sorted {
                $0 < $1
            }
        
        return alignedDates
    }
    
    func allDates(starting startingDate: Date, calendar: Calendar = .current) -> [Date] {
        
        let increment = self.freq.incrementDateComponents(increment: self.interval ?? 1)
        let count: Int = self.count ?? 64 // max number of scheduled notifications is 64
        let untilDate: Date = self.until ?? .distantFuture
        
        var alignedDates = self.alignedDates(starting: startingDate, calendar: calendar)
        
        var dates: [Date] = alignedDates
            .filter { date in
                date < untilDate
            }
        dates = Array(dates.prefix(64))
        
        while dates.count < count,
              let lastDate = dates.last,
              lastDate < untilDate {
            alignedDates = alignedDates
                .map({ date in
                    return calendar.date(byAdding: increment, to: date)!
                })
            dates += alignedDates
        }
        
        dates = dates
            .filter({ date in
                date < untilDate
            })
        dates = Array(dates.prefix(64))
        
        return dates
    }
    
}
