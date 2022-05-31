//
//  TimeManager.swift
//  testing
//
//  Created by Batyr Zhangabylov on 11/28/21.
//  TimerManager to control the timer

import Foundation
import SwiftUI

class TimerManager: ObservableObject {
    // Set the initial timer mode
    @Published var timerMode: TimerMode = .initial
    
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerLength")
    // Object instance of a timer
    var timer = Timer()
    // Setting the timer length
    func setTimerLength(minutes: Int) {
        let defaults = UserDefaults.standard
        defaults.set(minutes, forKey: "timerLength")
        secondsLeft = minutes
    }
    // Running timer
    func start() {
        timerMode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.secondsLeft == 0 {
                self.reset()
            }
            self.secondsLeft -= 1
        })
    }
    // Resetting the timer
    func reset() {
        self.timerMode = .initial
        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerLength")
        timer.invalidate()
    }
    // Paused timer
    func pause() {
        self.timerMode = .paused
        timer.invalidate()
    }
}

