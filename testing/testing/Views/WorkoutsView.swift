//
//  WorkoutsView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 9/6/21.
//  WorkoutsView to display the workouts in the database.

import SwiftUI

@available(iOS 15.0, *)
struct WorkoutsView: View {
    @ObservedObject var db : Database
    @State var showSheetView = false

    var body: some View {
        NavigationView {
            List(db.workoutList.indices, id: \.self) { i in
                NavigationLink(destination: WorkoutDetailView(workout: db.workoutList[i], db: self.db)) {
                    WorkoutView(workout: db.workoutList[i])
                        .navigationBarTitle("Workouts")
                        .navigationBarItems(trailing:
                                Button(action: {
                                    self.showSheetView.toggle()
                                }) {
                                    Image(systemName: "plus.square.fill")
                                        .font(Font.system(.title))
                                }
                            )
                        }.sheet(isPresented: $showSheetView) {
                            NewWorkoutView(showSheetView: self.$showSheetView, db: self.db)
                        }
                }
        }
    }
}

struct WorkoutView: View {
   var workout: Workout
   var body: some View {
       HStack {
           VStack(alignment: .leading) {
               Text(workout.workoutName)
           }
           Spacer()
       }
   }
}
                
@available(iOS 15.0, *)
struct WorkoutDetailView: View {
    // Workout and Database that are passed onto the view
    var workout: Workout
    @ObservedObject var db : Database
    
    var body: some View {
        VStack {
            // Displays the name of the workout object
            Text(workout.workoutName).font(.title)
            Spacer()
            
            // Pulls the composition of the workout object using a complex query
            ForEach(db.getWorkoutComposition(workout: workout)) { composition in
               Text("\(composition.exerciseOrder). \(composition.numberOfSets)x \(db.findExercise(exerciseID: composition.exerciseID).exerciseName)").font(.title2)

            }
            Spacer()
            
            // Button to start a session
            NavigationLink(destination: SessionView(db:self.db, workout:self.workout)) {
               Text("Start a Session")
            }
            Spacer()
        }
    }
}
                
struct NewWorkoutView: View {
    // Boolean that keeps the View open whilst true
    @Binding var showSheetView: Bool
    @ObservedObject var db : Database
    // Boolean that displays ChooseExerciseView if true
    @State var showExerciseChoice: Bool = false
    // Arrays to store chosen exercises and their sets
    @State var chosenExercises: [Exercise] = []
    @State var setsPerExercise: [Int] = []
    // Array to store workout name
    @State var workoutName: String = ""

    var body: some View {
       NavigationView {
           ScrollView {
               Spacer()
               TextField("Name" , text: $workoutName)
                   .padding()
               Spacer()
               HStack{
                    // Button to add a new exercise
                    Button(action: {
                        
                        if (chosenExercises.count < 15) {
                            // Sets showExerciseChoice to true so the ChooseExerciseView can open
                            self.showExerciseChoice = true
                        }
                        
                        // Notify if there are too many exercises
                        else {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                    print("All set!")
                                } else if let error = error {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            let notification = UNMutableNotificationContent()
                            notification.title = "Unavailable"
                            notification.subtitle = "Too many exercises"
                            notification.sound = UNNotificationSound.default

                            // Notification sent 2 seconds later
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

                            // Random Identifier
                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)

                            // Sending the notification request
                            UNUserNotificationCenter.current().add(request)
                        }
                    }) {
                      Text("Add a New Exercise")
                      Image(systemName: "plus.square")
                    }
                   // "isActive: self.$showExerciseChoice" ensures the View only appears when the variable $showExerciseChoice is true
                   NavigationLink(destination: ChooseExerciseView(db: self.db, showExerciseChoice: self.$showExerciseChoice, chosenExercises: self.$chosenExercises, setsPerExercise: self.$setsPerExercise), isActive: self.$showExerciseChoice) { EmptyView() }
                  .navigationBarTitle("New Workout")
              }
               Spacer()
               // Loop through chosen exercises
               ForEach(chosenExercises, id: \.id) { exercise in
                   VStack {
                       Text(exercise.exerciseName.capitalized)
                       // Find the index of the exercise in the setsPerExercise Array
                       ForEach((1...setsPerExercise[db.findIndex(array: chosenExercises, exercise: exercise)]), id: \.self) {
                           // Displays the number of sets for the exercise
                           Text("\($0)…")
                        }
                       // Add a set
                       Button("Add a Set"){
                           // If there are under 10 sets
                           if (setsPerExercise[db.findIndex(array: chosenExercises, exercise: exercise)] < 10) {
                               setsPerExercise[db.findIndex(array: chosenExercises, exercise: exercise)] += 1
                           }
                           
                           // Notify if there are too many sets
                           else {
                               UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                   if success {
                                       print("All set!")
                                   } else if let error = error {
                                       print(error.localizedDescription)
                                   }
                               }
                               
                               let notification = UNMutableNotificationContent()
                               notification.title = "Unavailable"
                               notification.subtitle = "Too many sets"
                               notification.sound = UNNotificationSound.default

                               // Notification sent 2 seconds later
                               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

                               // Random Identifier
                               let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)

                               // Sending the notification request
                               UNUserNotificationCenter.current().add(request)
                           }
                       }
                   }
                   Spacer(minLength: 300)
                }
           }
           .navigationBarTitle(Text("New Workout"), displayMode: .inline)
              .navigationBarItems(trailing: Button(action: {
                  // Gets a Unique ID for the workout
                  let workoutID = db.workoutList.count + 1
                  
                  // Create a new instance of the object
                  let newWorkout = Workout(workoutID: workoutID, workoutName: workoutName)

                  // Adding the workout to the database
                  db.addNewWorkout(workout: newWorkout)

                  // Adding the workout to the array of workouts
                  db.workoutList.append(newWorkout)
                  
                  // Adding its composition to the database
                  for i in 0..<chosenExercises.count {
                      // Gets a Unique ID for the workout composition
                      let workoutCompositionID = db.workoutCompositionList.count + 1
                      
                      // Creating a workout composition object and adding it to the database and the array of workout compositions
                      let newWorkoutComposition = WorkoutComposition(workoutID: workoutID, exerciseID: Int(chosenExercises[i].exerciseID),  numberOfSets: setsPerExercise[i], exerciseOrder: i+1, workoutCompositionID: workoutCompositionID)
                      db.addNewWorkoutComposition(workoutComposition: newWorkoutComposition)
                      db.workoutCompositionList.append(newWorkoutComposition)
                  }
                  
                  // Dismisses the sheet view
                  self.showSheetView = false
              }) {
                  Text("Done").bold()
              }.disabled(workoutName.isEmpty || chosenExercises.isEmpty))
       }
    }
}

struct ChooseExerciseView: View {
    @ObservedObject var db : Database
    @Binding var showExerciseChoice: Bool
    @Binding var chosenExercises: [Exercise]
    @Binding var setsPerExercise: [Int]

    var body: some View {
        NavigationView {
            List(db.exerciseList.indices, id: \.self) { i in
                HStack {
                    ExerciseView(exercise: db.exerciseList[i])

                    Button(action: {
                        self.chosenExercises.append(db.exerciseList[i])
                        self.setsPerExercise.append(1)
                        self.showExerciseChoice = false
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .navigationTitle("Choose an Exercise")
            }
        }
    }
}
