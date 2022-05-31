//
//  SessionView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 11/18/21.
//  SessionView to keep track of a running workout session

import SwiftUI

@available(iOS 15.0, *)
struct SessionView: View {
    @ObservedObject var db : Database
    var workout: Workout
    // 2D Arrays used to store reps and weights done in a session
    @State var numberOfReps: [[Int]] = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
    @State var weightsUsed: [[Int]] = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
    
    // Confirmation to cancel or complete
    @State private var cancelConfirmationShown = false
    @State private var completeConfirmationShown = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
   // Session Duration
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    var startTime = Date()
    
    @State var showTimerView = false

    @State var sessionComplete: Bool = false

    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        if sessionComplete {
            SessionResults(db: self.db, workout: self.workout, hours: self.hours, minutes: self.minutes, seconds: self.seconds, numberOfReps: self.numberOfReps, weightsUsed: self.weightsUsed)
                .animation(.spring())
                .transition(.slide)
        } else {
        ScrollView {
            ForEach(db.getWorkoutComposition(workout: workout)) { composition in
                Text("\(db.findExercise(exerciseID: composition.exerciseID).exerciseName)").font(.title2)
                    .padding()
                HStack {
                    Spacer()
                    Text("Set")
                    Spacer()
                    Text("Previous")
                    Spacer()
                    Text("+lbs")
                    Spacer()
                    Text("Reps")
                    Spacer()
                }
                ForEach((1...composition.numberOfSets), id: \.self) {setNumber in
                    HStack {
                        Spacer()
                        Text("\(setNumber)")
                            .padding()
                        Spacer()

                        // Get the last result for this Exercise & Set
                        let previousStats = db.getPreviousResult(composition: composition, setNumber: setNumber)
                        Text("\(String(previousStats.weightUsed)) x \(String(previousStats.repetitions))")
                            .padding(.leading, 20)
                        Spacer()
                        Spacer()
                        TextField("0", value: $weightsUsed[composition.exerciseOrder-1][setNumber-1], formatter: formatter)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50, height: nil)
                                    .multilineTextAlignment(.center)
                        Spacer()
                        TextField("0", value: $numberOfReps[composition.exerciseOrder-1][setNumber-1], formatter: formatter)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .frame(width: 50, height: nil)
                                    .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle(workout.workoutName)
        .navigationBarItems(trailing:
                Button(action: {
                    completeConfirmationShown = true
                }) {
                    Image(systemName: "checkmark.rectangle")
                        .font(Font.system(.title))
                })
                .confirmationDialog(
                    "Are you done with the workout?",
                    isPresented: $completeConfirmationShown,
                    titleVisibility: .visible
                ) {
                    Button("Yes") {
                        // Calculating duration of the session by finding the difference between the end and the start of the session
                        let endTime = Date.now
                        let diffs = Calendar.current.dateComponents([.hour, .minute, .second], from: startTime, to: endTime)

                        self.hours = diffs.hour!
                        self.minutes = diffs.minute!
                        self.seconds = diffs.second!
                        
                        // Adding A Session
                        let sessionID = db.sessionList.count + 1
                        let duration = seconds + minutes*60 + hours*60*60
                        let date = getDate()
                        
                        let newSession = Session(workoutID: workout.workoutID, timeStarted: date, duration: duration, sessionID: sessionID)
                        db.addNewSession(session: newSession)
                        db.sessionList.append(newSession)
                        
                        // Adding A Session History
                        for composition in db.getWorkoutComposition(workout: workout) {
                            for setNumber in 1...composition.numberOfSets {
                                let sessionHistoryID = db.sessionHistoryList.count + 1
                                
                                let newSessionHistory = SessionHistory(exerciseID: Int(db.findExercise(exerciseID: composition.exerciseID).exerciseID), sessionID: sessionID, setNumber: setNumber, weightUsed: Double(weightsUsed[composition.exerciseOrder-1][setNumber-1]), repetitions: numberOfReps[composition.exerciseOrder-1][setNumber-1], historyID: sessionHistoryID)
                                db.addNewSessionHistory(sessionHistory: newSessionHistory)
                                db.sessionHistoryList.append(newSessionHistory)
                            }
                        }
                        
                        withAnimation {
                            self.sessionComplete = true
                        }
                    }.animation(.none)
                }
        .navigationBarItems(trailing:
                Button(
                    role:.destructive,
                    action: { cancelConfirmationShown = true}
                ) {
                    Image(systemName: "xmark.rectangle")
                        .font(Font.system(.title))
                }
                .confirmationDialog(
                    "Are you sure you want to cancel the workout?",
                    isPresented: $cancelConfirmationShown,
                    titleVisibility: .visible
                ) {
                    Button("Yes", role:.destructive) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                })
        .navigationBarItems(trailing:
                Button(action: {
                    self.showTimerView.toggle()
                }) {
                    Image(systemName: "timer.square")
                        .font(Font.system(.title))
                })
        .sheet(isPresented: $showTimerView) {
                TimeView()
            }
        }
    }
    
    func getDate() -> String{
        // Date
        let timeStarted = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        dateFormatter.locale = Locale(identifier: "en_US")
        let work = dateFormatter.string(from:timeStarted)

        return work
    }
}
