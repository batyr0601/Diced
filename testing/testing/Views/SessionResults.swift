//
//  SessionResults.swift
//  testing
//
//  Created by Batyr Zhangabylov on 11/27/21.
//  SessionResults view to display the results of the session after it has been completed

import SwiftUI

struct SessionResults: View {
    @ObservedObject var db : Database
    var workout: Workout
    var hours: Int
    var minutes: Int
    var seconds: Int
    var numberOfReps: [[Int]]
    var weightsUsed: [[Int]]
    
    var body: some View {
        VStack {
            Text("\(workout.workoutName)").font(.title2)
            Text("COMPLETE").font(.title)
            Spacer()

            HStack {
                Image(systemName: "clock").resizable().foregroundColor(.blue).font(.title).frame(width: 32.0, height: 32.0)
                Text("\(hours):\(minutes):\(seconds)")
                    .padding(10)
                    .font(.title)
            }
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis").resizable().foregroundColor(.blue).font(.title).frame(width: 32.0, height: 32.0)
                Text("\(self.totalReps()) Reps")
                    .padding(10)
                    .font(.title)
            }
            HStack {
                Image(systemName: "chevron.up").resizable().foregroundColor(.blue).font(.title).frame(width: 32.0, height: 20.0)
                Text("\(self.totalWeight()) lbs")
                    .padding(10)
                    .font(.title)
            }
            Spacer()
        }
    }
    
    func totalReps() -> Int {
        var totalReps : Int = 0
        for exercise in self.numberOfReps {
            for reps in exercise {
                totalReps = totalReps + reps
            }
        }
        return totalReps
    }
    
    func totalWeight() -> Int {
        var totalWeight : Int = 0
        for exercise in self.weightsUsed {
            for weight in exercise {
                totalWeight = totalWeight + weight
            }
        }
        return totalWeight
    }
}

//struct SessionResults_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionResults()
//    }
//}
