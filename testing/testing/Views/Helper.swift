//
//  Helper.swift
//  testing
//
//  Created by Batyr Zhangabylov on 11/28/21.
//

import Foundation

enum TimerMode {
    case running
    case paused
    case initial
}

func secondsToMinutesAndSeconds(seconds: Int) -> String {
    let minutes = "\((seconds % 3600) / 60)"
    let seconds = "\((seconds % 3600) % 60)"
    let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
    let secondStamp = seconds.count > 1 ? seconds : "0" + seconds

    return "\(minuteStamp) : \(secondStamp)"
}
