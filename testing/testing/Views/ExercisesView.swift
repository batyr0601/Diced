//
//  ExercisesView.swift
//  testing
//  
//  Created by Batyr Zhangabylov on 9/6/21.
//  ExerciseView to display all the exercises in the database

import SwiftUI

//MARK: General Exercise List
struct ExercisesView: View {
    @ObservedObject var db : Database
    @State var showSheetView = false
    
    var body: some View {
        NavigationView {
            List(db.exerciseList.indices, id: \.self) { i in
                NavigationLink(destination: DetailView(exercise: db.exerciseList[i])) {
                    ExerciseView(exercise: db.exerciseList[i])
                        .navigationBarTitle("Exercises")
                        .navigationBarItems(trailing:
                                Button(action: {
                                    self.showSheetView.toggle()
                                }) {
                                    Image(systemName: "plus.square.fill")
                                        .font(Font.system(.title))
                                }
                            )
                        }.sheet(isPresented: $showSheetView) {
                            NewExerciseView(showSheetView: self.$showSheetView, db: self.db)
                        }
                }
        }
    }
}

//MARK: Each Exercise on the List
struct ExerciseView: View {
    var exercise: Exercise
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.exerciseName)
                Text(exercise.exerciseType).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Text(exercise.muscleGroup)
        }
    }
}

//MARK: Specific Exercise View
struct DetailView: View {
    var exercise: Exercise
    
    var body: some View {
        VStack {
            Text(exercise.exerciseName).font(.title)
            
            HStack {
                Text("\(exercise.exerciseType) - \( exercise.muscleGroup)")
            }
            
            Spacer()
            
            Text(exercise.description).font(.body)
            
            Spacer()

        }
    }
}

//MARK: Sheet View to Add a New Exercise
struct NewExerciseView: View {
    @Binding var showSheetView: Bool
    @ObservedObject var db : Database
    
    @State var exerciseName: String = ""
    @State var exerciseDescription: String = ""
    @State private var muscleGroupIndex = 0
    @State private var typeOfExerciseIndex = 0
    var muscleGroup = ["Chest", "Back", "Legs", "Arms"]
    var typeOfExercise = ["Bodyweight", "Weight", "Cardio"]
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                    TextField("Name" , text: $exerciseName)
                        .padding()
                }
                Section{
                    TextField("Description", text: $exerciseDescription)
                        .padding()
                }
                Section{
                    Picker(selection: $muscleGroupIndex, label: Text("Muscle Group")) {
                        ForEach(0 ..< muscleGroup.count){
                            Text(self.muscleGroup[$0]).tag($0)
                        }
                    }
                }
                Section{
                    Picker(selection: $typeOfExerciseIndex, label: Text("Type of Exercise")) {
                        ForEach(0 ..< typeOfExercise.count){
                            Text(self.typeOfExercise[$0]).tag($0)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("New Exercise"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                // Gets a Unique ID for the exercise
                let exerciseID = db.exerciseList.count + 1
                
                // Create a new instance of the object
                let newExercise = Exercise(exerciseID: Int64(exerciseID), exerciseName: exerciseName, muscleGroup: muscleGroup[muscleGroupIndex], exerciseType: typeOfExercise[typeOfExerciseIndex], description: exerciseDescription)
                
                // Adding the exercise to the database
                db.addNewExercise(exercise: newExercise)
                
                // Adding the exercise to the array of exercises
                db.exerciseList.append(newExercise)
                
                // Dismisses the sheet view
                self.showSheetView = false
                
            }) {
                Text("Save").bold()
            } .disabled(exerciseName.isEmpty)
            )
        }
    }
}
