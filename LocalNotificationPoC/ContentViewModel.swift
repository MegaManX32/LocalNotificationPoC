//
//  ContentViewModel.swift
//  LocalNotificationPoC
//
//  Created by Vladislav Simovic on 19.3.25..
//

import SwiftUI
import UserNotifications

final class ContentViewModel: ObservableObject {
    @Published var minutesInterval: String = ""
    @Published var scheduledNotifications = [Reminder]()
    @Published var minuteIndex: Int = 0
    @Published var hourIndex: Int = 0
    @Published var dayIndex: Int = 0
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func loadScheduledNotifications() {
        scheduledNotifications = storage.allReminders()
    }
    
    func removeAll() {
        storage.removeAllReminders()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        loadScheduledNotifications()
    }
    
    func remove(at index: Int) {
        storage.removeReminder(at: index)
        let notificationIds = [scheduledNotifications[index].hashValue.description]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIds)
        loadScheduledNotifications()
    }
    
    @MainActor func addNewNotification() async {
        do {
            let value = try await scheduleNotification()
            storage.addReminder(value)
            loadScheduledNotifications()
        } catch {
            print(error)
        }
    }
    
    private func scheduleNotification() async throws -> Reminder {
        let reminder = Reminder(day: dayIndex, hour: hourIndex, minute: minuteIndex)
        guard !storage.isExisting(reminder: reminder) else { throw NSError(domain: "Could not add reminder",
                                                                           code: 0,
                                                                           userInfo: nil) }
        
        let center = UNUserNotificationCenter.current()
        
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { throw NSError(domain: "Not granted authorization", code: 0, userInfo: nil) }
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Reminder"
        content.body = "This is your weekly reminder every \(daysOfWeek[dayIndex]), on \(hourIndex):\(minuteIndex)"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = dayIndex
        dateComponents.hour = hourIndex
        dateComponents.minute = minuteIndex
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminder.hashValue.description,
                                            content: content,
                                            trigger: trigger)
        try await center.add(request)
        
        return reminder
    }
    
    func description(for reminder: Reminder) -> String {
        let hour = reminder.hour < 10 ? "0\(reminder.hour)" : "\(reminder.hour)"
        let minute = reminder.minute < 10 ? "0\(reminder.minute)" : "\(reminder.minute)"
        return "Every \(daysOfWeek[reminder.day]), at \(hour)h:\(minute)m"
    }
}
