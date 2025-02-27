//
//  TimerViewModel.swift
//  Due
//
//  Created by Rafi on 2025-02-27.
//

import AppKit
import Combine
import SwiftUI
import UserNotifications

class TimerViewModel: ObservableObject {
    @Published var hours: Int = 0
    @Published var minutes: Int = 30 // Default 30 minutes
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var alwaysOnTop: Bool = true
    
    private var timer: AnyCancellable?
    private var totalSeconds: Int = 0
    private var endDate: Date?
    
    func startTimer() {
        if hours == 0 && minutes == 0 && seconds == 0 {
            return
        }
        
        isRunning = true
        totalSeconds = hours * 3600 + minutes * 60 + seconds
        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func resetTimer() {
        stopTimer()
        hours = 0
        minutes = 30 // Reset to default 30 minutes
        seconds = 0
    }
    
    func updateTimer() {
        guard let endDate = endDate else { return }
        
        let remaining = Int(endDate.timeIntervalSince(Date()))
        
        if remaining <= 0 {
            stopTimer()
            hours = 0
            minutes = 0
            seconds = 0
            notifyTimerComplete()
            return
        }
        
        hours = remaining / 3600
        minutes = (remaining % 3600) / 60
        seconds = remaining % 60
    }
    
    func toggleAlwaysOnTop() {
        alwaysOnTop.toggle()
        
        if let window = NSApplication.shared.windows.first {
            window.level = alwaysOnTop ? .floating : .normal
        }
    }
    
    private func notifyTimerComplete() {
        // Play a sound when timer completes
        NSSound(named: "Glass")?.play()
        
        // Create and deliver notification using UserNotifications framework
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Your countdown timer has finished."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
