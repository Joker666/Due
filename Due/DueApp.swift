//
//  DueApp.swift
//  Due
//
//  Created by Rafi on 2025-02-27.
//

import SwiftUI
import Combine
import AppKit
import UserNotifications

struct WindowSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

@main
struct FloatingTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var windowSize: CGSize = CGSize(width: 250, height: 150)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(GeometryReader { geometry in
                    Color.clear.preference(key: WindowSizeKey.self, value: geometry.size)
                })
                .onPreferenceChange(WindowSizeKey.self) { newSize in
                    if let window = NSApplication.shared.windows.first {
                        window.setContentSize(newSize)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        
        // Make the app's window float on top of others
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
            
            // Remove standard window buttons (minimize, maximize)
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            
            // Make window movable by dragging anywhere
            window.isMovableByWindowBackground = true
            
            // Make window semi-transparent
            window.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        }
    }
}
