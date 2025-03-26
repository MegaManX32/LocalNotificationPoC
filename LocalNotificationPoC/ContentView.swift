//
//  ContentView.swift
//  LocalNotificationPoC
//
//  Created by Vladislav Simovic on 18.3.25..
//

import SwiftUI
    
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel(storage: StorageAdapter())
    
    var body: some View {
        VStack {
            HStack {
                Text("Minute: ")
                Stepper("\(viewModel.minuteIndex)", value: $viewModel.minuteIndex, in: 0...60, step: 1)
            }
            
            HStack {
                Text("Hour: ")
                Stepper("\(viewModel.hourIndex)", value: $viewModel.hourIndex, in: 0...24, step: 1)
            }
            
            HStack {
                Text("Day: ")
                Stepper("\(viewModel.daysOfWeek[viewModel.dayIndex])",
                        value: $viewModel.dayIndex,
                        in: 0...viewModel.daysOfWeek.count - 1,
                        step: 1)
            }
            .padding(.bottom, 30)
            
            Button {
                Task {
                    await viewModel.addNewNotification()
                }
            } label: {
                Text("Schedule")
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.scheduledNotifications.enumerated().map { $0 }, id: \.element) { (index, reminder) in
                        HStack(spacing: 0) {
                            Text(viewModel.description(for: reminder))
                            
                            Button {
                                viewModel.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 20, height: 20)
                            }

                        }
                        .padding([.top, .bottom], 4)
                    }
                }
            }
        }
        .padding()
        .onAppear() {
            viewModel.loadScheduledNotifications()
        }
    }
}

#Preview {
    ContentView()
}
