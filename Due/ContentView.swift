//
//  ContentView.swift
//  Due
//
//  Created by Rafi on 2025-02-27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var opacity: Double = 0.8
    @Environment(\.dismiss) private var dismiss
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Timer Display
            HStack(spacing: 10) {
                TimePickerView(value: $viewModel.hours, label: "h", enabled: !viewModel.isRunning)
                Text(":")
                    .font(.title)
                    .foregroundColor(.white)
                TimePickerView(value: $viewModel.minutes, label: "m", range: 0...59, enabled: !viewModel.isRunning)
                Text(":")
                    .font(.title)
                    .foregroundColor(.white)
                TimePickerView(value: $viewModel.seconds, label: "s", range: 0...59, enabled: !viewModel.isRunning)
            }
            
            // Controls and Options wrapped in opacity animation
            VStack(spacing: 15) {
                // Controls
                HStack(spacing: 15) {
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.stopTimer()
                        } else {
                            viewModel.startTimer()
                        }
                    }) {
                        Text(viewModel.isRunning ? "Pause" : "Start")
                            .frame(width: 70)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        viewModel.resetTimer()
                    }) {
                        Text("Reset")
                            .frame(width: 70)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.hours == 0 && viewModel.minutes == 30 && viewModel.seconds == 0 && !viewModel.isRunning)
                }
                
                // Options
                HStack {
                    Toggle("Always on Top", isOn: $viewModel.alwaysOnTop)
                        .toggleStyle(.switch)
                        .foregroundColor(.white)
                        .onChange(of: viewModel.alwaysOnTop) { newValue, _ in
                            viewModel.toggleAlwaysOnTop()
                        }
                    
                    Slider(value: $opacity, in: 0.3...1.0, step: 0.1)
                        .frame(width: 80)
                        .onChange(of: opacity) { _, newValue in
                            if let window = NSApplication.shared.windows.first {
                                window.backgroundColor = NSColor.black.withAlphaComponent(newValue)
                            }
                        }
                }
                .font(.caption)
            }
            .opacity(viewModel.isRunning ? (isHovering ? 1 : 0) : 1)
            .frame(height: viewModel.isRunning ? (isHovering ? nil : 0) : nil)
            .clipped()
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isRunning)
        }
        .padding()
        .padding([.top], -25)
        .background(Color.black.opacity(0.01)) // Nearly invisible background for drag handling
        .frame(maxWidth: .infinity)
        .fixedSize()
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct TimePickerView: View {
    @Binding var value: Int
    let label: String
    var range: ClosedRange<Int> = 0...23
    var enabled: Bool = true
    
    var body: some View {
        VStack {
            Button(action: {
                if enabled && value < range.upperBound {
                    value += 1
                }
            }) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .disabled(!enabled)
            
            Text("\(value, specifier: "%02d")")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 40)
            
            Button(action: {
                if enabled && value > range.lowerBound {
                    value -= 1
                }
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            .disabled(!enabled)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 250, height: 150)
            .preferredColorScheme(.dark)
    }
}
#endif
