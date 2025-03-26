//
//  Storage.swift
//  LocalNotificationPoC
//
//  Created by Vladislav Simovic on 26.3.25..
//

import Foundation

protocol Storage {
    func allReminders() -> [Reminder]
    func addReminder(_ reminder: Reminder)
    func removeReminder(at index: Int)
    func removeAllReminders()
    func isExisting(reminder: Reminder) -> Bool
}

final class StorageAdapter: Storage {
    private let defaults = UserDefaults.standard
    private let key = "Reminders"
    
    func allReminders() -> [Reminder] {
        guard let data = defaults.data(forKey: key),
              let reminders = try? JSONDecoder().decode([Reminder].self, from: data) else {
            return []
        }
        return reminders
    }
    
    func addReminder(_ reminder: Reminder) {
        var reminders = allReminders()
        guard !reminders.contains(reminder) else { return }
        reminders.append(reminder)
        save(reminders)
    }
    
    func removeReminder(at index: Int) {
        var reminders = allReminders()
        reminders.remove(at: index)
        save(reminders)
    }
    
    private func save(_ reminders: [Reminder]) {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: key)
        }
    }
    
    func removeAllReminders() {
        save([])
    }
    
    func isExisting(reminder: Reminder) -> Bool {
        allReminders().contains(reminder)
    }
}
