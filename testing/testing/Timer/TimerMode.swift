//
//  TimerMode.swift
//  testing
//
//  Created by Batyr Zhangabylov on 3/10/22.
//  Extension of Timer Manager

import Foundation
// Case options as TimerMode can either be running, paused, or initial
enum TimerMode {
    case running
    case paused
    case initial
}

// Function to convert from seconds to minutes and seconds
func secondsToMinutesAndSeconds(seconds: Int) -> String {
    let minutes = "\((seconds % 3600) / 60)"
    let seconds = "\((seconds % 3600) % 60)"
    let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
    let secondStamp = seconds.count > 1 ? seconds : "0" + seconds

    return "\(minuteStamp) : \(secondStamp)"
}

