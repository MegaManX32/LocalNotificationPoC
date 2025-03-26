//
//  Reminder.swift
//  LocalNotificationPoC
//
//  Created by Vladislav Simovic on 26.3.25..
//

struct Reminder: Hashable, Codable, Equatable {
    let day: Int
    let hour: Int
    let minute: Int
    
    init(day: Int, hour: Int, minute: Int) {
        self.day = day
        self.hour = hour
        self.minute = minute
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(hour)
        hasher.combine(minute)
    }
}

