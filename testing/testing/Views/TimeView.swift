//
//  TimeView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 11/28/21.
//  TimeView used for the rest timer

import SwiftUI

struct TimeView: View {
        @ObservedObject var timerManager = TimerManager()
        
        @State var selectedPickerIndex = 0
        
        let availableMinutes = Array(1...59)
        
        var body: some View {
            
        NavigationView {
            VStack {
                Text(secondsToMinutesAndSeconds(seconds: timerManager.secondsLeft))
                    .font(.system(size: 50))
                    .padding(.top, 80)
                Image(systemName: timerManager.timerMode == .running ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .onTapGesture(perform: {
                        if self.timerManager.timerMode == .initial {
                            self.timerManager.setTimerLength(minutes: self.availableMinutes[self.selectedPickerIndex]*60)
                        }
                        self.timerManager.timerMode == .running ? self.timerManager.pause() : self.timerManager.start()
                    })
                if timerManager.timerMode == .paused {
                    Image(systemName: "gobackward")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.top, 40)
                    .onTapGesture(perform: {
                        self.timerManager.reset()
                    })
                }
                if timerManager.timerMode == .initial {
                    Picker(selection: $selectedPickerIndex, label: Text("")) {
                        ForEach(0 ..< availableMinutes.count) {
                            Text("\(self.availableMinutes[$0]) min")
                        }
                    }
                    .labelsHidden()
                }
                Spacer()
            }
            .navigationBarTitle("Rest Timer")
        }
    }
}

