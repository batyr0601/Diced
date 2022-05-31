// Database file initiating the database and its methods

import SwiftUI
import Foundation
import SQLite3

var database : OpaquePointer?

//MARK: Data Structures

//  Structure for an exercise
struct Exercise : Identifiable {
    var id = UUID()
    var exerciseID : Int64
    var exerciseName : String
    var muscleGroup : String
    var exerciseType : String
    var description : String
}
//  Structure for a workout
struct Workout : Identifiable {
    var id = UUID()
    var workoutID : Int
    var workoutName : String
}
//  Structure for a workout composition
struct WorkoutComposition : Identifiable {
    var id = UUID()
    var workoutID : Int
    var exerciseID : Int
    var numberOfSets : Int
    var exerciseOrder : Int
    var workoutCompositionID : Int
}
//  Structure for a session
struct Session : Identifiable {
    var id = UUID()
    var workoutID : Int
    var timeStarted : String
    var duration : Int
    var sessionID : Int
}
//  Structure for a session history
struct SessionHistory : Identifiable {
    var id = UUID()
    var exerciseID : Int
    var sessionID : Int
    var setNumber : Int
    var weightUsed : Double
    var repetitions : Int
    var historyID : Int
}
class Database : ObservableObject {
    
    // Arrays used to store objects
    @Published var exerciseList = [Exercise]()
    @Published var workoutList = [Workout]()
    @Published var workoutCompositionList = [WorkoutComposition]()
    @Published var sessionList = [Session]()
    @Published var sessionHistoryList = [SessionHistory]()

    var statement : OpaquePointer?
    
    //MARK: Database Initiation
    init() {
        // “databaseURL” is a variable of type URL which will contain the location of the database.
        let databaseURL: URL = {
            // “applicationSupport” will be set to the location of the Documents directory in the user’s files.
            let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            // “bundleID” is a unique identifier for the specific application within the system.
            let bundleID = Bundle.main.bundleIdentifier ?? "Batyr.testing"
            // “bundleID” is appended to the “applicationSupport” and stored in “subDirectory”.
            let subDirectory = applicationSupport.appendingPathComponent(bundleID, isDirectory: true)
            // The database file name is appended to “subDirectory” to get the “destination” of the file.
            let destination = subDirectory.appendingPathComponent("databaseChanged.db")
            print (destination)
            if !FileManager.default.fileExists(atPath: destination.path) {
                
                let source = Bundle.main.url(forResource: "databaseChanged", withExtension: "db")!
                do {
                    try FileManager.default.createDirectory(at: subDirectory, withIntermediateDirectories: true, attributes: nil)
                    try FileManager.default.copyItem(at: source, to: destination)
                } catch {
                    print("could not copy file")
                    return source
                }
            }
                print(destination)
                return destination
        }()
        
        if sqlite3_open(String(databaseURL.path), &database) != SQLITE_OK {
            
            print("Error has occurred")
            sqlite3_close(database)
            
        } else {
            
            //MARK: Exercise Table
            let exerciseTable = "SELECT * FROM exercises;"
            
            if sqlite3_prepare_v2(database, exerciseTable, -1, &statement, nil) == SQLITE_OK {
                    
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let exerciseName = String(cString: sqlite3_column_text(statement,0))
                    let muscleGroup = String(cString: sqlite3_column_text(statement,1))
                    let exerciseType = String(cString: sqlite3_column_text(statement,2))
                    let description = String(cString: sqlite3_column_text(statement,3))
                    let exerciseID = sqlite3_column_int(statement, 4)
                    
                    exerciseList.append(Exercise(exerciseID: Int64(Int(exerciseID)), exerciseName: exerciseName, muscleGroup: muscleGroup, exerciseType: exerciseType, description: description))
                }
            
            } else {
                print("Unable to open 'Exercise' table")
                sqlite3_close(database)
            }
            
            //MARK: Workouts Table
            let workoutsTable = "SELECT * FROM workouts;"
            
            if sqlite3_prepare_v2(database, workoutsTable, -1, &statement, nil) == SQLITE_OK {
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let workoutName = String(cString: sqlite3_column_text(statement,0))
                    let workoutID = sqlite3_column_int(statement, 1)
                    
                    workoutList.append(Workout(workoutID: Int(workoutID), workoutName: workoutName))
                }
                
            } else {
                print("Unable to open 'Workouts' table")
                sqlite3_close(database)
            }
                        
            //MARK: Workout Composition Table
            let workoutCompositionTable = "SELECT * FROM workoutComposition;"

            if sqlite3_prepare(database, workoutCompositionTable, -1, &statement, nil) == SQLITE_OK {

                while sqlite3_step(statement) == SQLITE_ROW {
//                    print("AYO YOU WORKING 99")

                    let workoutID = sqlite3_column_int(statement, 0)
                    let exerciseID = sqlite3_column_int(statement, 1)
                    let numberOfSets = sqlite3_column_int(statement, 2)
                    let exerciseOrder = sqlite3_column_int(statement, 3)
                    let workoutCompositionID = sqlite3_column_int(statement, 4)

                    workoutCompositionList.append(WorkoutComposition(workoutID: Int(workoutID), exerciseID: Int(exerciseID), numberOfSets: Int(numberOfSets), exerciseOrder: Int(exerciseOrder), workoutCompositionID: Int(workoutCompositionID)))
                }

            } else {
                print("Unable to open 'Workout Composition' table")
                sqlite3_close(database)
            }
            
            //MARK: Sessions Table
            let sessionTable = "SELECT * FROM sessions;"
            
            if sqlite3_prepare_v2(database, sessionTable, -1, &statement, nil) == SQLITE_OK {
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let workoutID = sqlite3_column_int(statement, 0)
                    let timeStarted = String(cString: sqlite3_column_text(statement,1))
                    let duration = sqlite3_column_int(statement, 2)
                    let sessionID = sqlite3_column_int(statement, 3)
                    
                    sessionList.append(Session(workoutID: Int(workoutID), timeStarted: timeStarted, duration: Int(duration), sessionID: Int(sessionID)))
//                    print("ADDED")
                }
                
            } else {
                print("Unable to open 'Workouts' table")
                sqlite3_close(database)
            }
            
            //MARK: Session History Table
            let sessionHistoryTable = "SELECT * FROM sessionHistory;"
            
            if sqlite3_prepare_v2(database, sessionHistoryTable, -1, &statement, nil) == SQLITE_OK {
                
                while sqlite3_step(statement) == SQLITE_ROW {
                    let exerciseID = sqlite3_column_int(statement, 0)
                    let sessionID = sqlite3_column_int(statement, 1)
                    let setNumber = sqlite3_column_int(statement, 2)
                    let weightUsed = sqlite3_column_double(statement, 3)
                    let repetitions = sqlite3_column_int(statement, 4)
                    let historyID = sqlite3_column_int(statement, 5)
                    
                    sessionHistoryList.append(SessionHistory(exerciseID: Int(exerciseID), sessionID: Int(sessionID), setNumber: Int(setNumber), weightUsed: weightUsed, repetitions: Int(repetitions), historyID: Int(historyID)))
//                    print("ADDED SESSION HISTORY")
                }
                
            } else {
                print("Unable to open 'Workouts' table")
                sqlite3_close(database)
            }
        }
    }
    //MARK: Get Workout Composition
    func getWorkoutComposition(workout: Workout) -> Array<WorkoutComposition> {
        let workoutCompositionTable = "SELECT * FROM exercises INNER JOIN workoutComposition ON workoutComposition.exerciseID = exercises.exerciseID INNER JOIN workouts ON workouts.workoutID = workoutComposition.workoutID WHERE workouts.workoutID = \(workout.workoutID)"
        
        var workoutCompositionArray = [WorkoutComposition]()

        if sqlite3_prepare(database, workoutCompositionTable, -1, &statement, nil) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {
                
                let workoutID = sqlite3_column_int(statement, 5)
                let exerciseID = sqlite3_column_int(statement, 4)
                let numberOfSets = sqlite3_column_int(statement, 7)
                let exerciseOrder = sqlite3_column_int(statement, 8)
                let workoutCompositionID = sqlite3_column_int(statement, 9)
                
                workoutCompositionArray.append(WorkoutComposition(workoutID: Int(workoutID), exerciseID: Int(exerciseID), numberOfSets: Int(numberOfSets), exerciseOrder: Int(exerciseOrder), workoutCompositionID: Int(workoutCompositionID)))
            }
            
        } else {
            print("Unable to look up workout composition")
            sqlite3_close(database)
        }
        return workoutCompositionArray;
    }
    
    //MARK: Add New Exercise
    func addNewExercise(exercise: Exercise) {
        var statement : OpaquePointer?
        let insertRow = "INSERT INTO exercises (exerciseName, muscleGroup, exerciseType, description, exerciseID) VALUES (?, ?, ?, ?, ?);"
        
        print("EXERCISE ID \(exercise.exerciseID)")
        print("EXERCISE NAME \(exercise.exerciseName)")
        print("EXERCISE MUSCLE GROUP \(exercise.muscleGroup)")
        print("EXERCISE TYPE \(exercise.exerciseType)")
        print("EXERCISE DECRIPTION \(exercise.description)")
        if sqlite3_prepare(database, insertRow, -1, &statement, nil) == SQLITE_OK {
            let exerciseName: NSString = NSString(string: exercise.exerciseName)
            let muscleGroup: NSString = NSString(string: exercise.muscleGroup)
            let exerciseType: NSString = NSString(string: exercise.exerciseType)
            let description: NSString = NSString(string: exercise.description)
            let exerciseID: Int64 = Int64(exercise.exerciseID)
            
            sqlite3_bind_text(statement, 1, exerciseName.utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, muscleGroup.utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, exerciseType.utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, description.utf8String, -1, nil)
            sqlite3_bind_int64(statement, 5, exerciseID)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("success")
            } else {
                print("Could not add an exercise.")
            }

        } else {
            print("Unable to execute the statement.")
        }
        sqlite3_finalize(statement)
    }
    
    //MARK: Find Index
    func findIndex(array: Array<Exercise>, exercise: Exercise) -> Int {
        var currentIndex = 0
        
        for ex in array {
            if (ex.exerciseName == exercise.exerciseName) {
                print("Found \(exercise) for index \(currentIndex)")
                return currentIndex
            }
            currentIndex += 1
        }
        return -1
    }
    
    //MARK: Find Exercise
    func findExercise(exerciseID: Int) -> Exercise {
        for ex in exerciseList {
            if (exerciseID == ex.exerciseID) {
                return ex
            }
        }
        return Exercise(exerciseID: 0, exerciseName: "", muscleGroup: "", exerciseType: "", description: "")
    }
    
    //MARK: Add New Workout
    func addNewWorkout(workout: Workout) {
        var statement : OpaquePointer?
        let insertRow = "INSERT INTO workouts (workoutName, workoutID) VALUES (?, ?);"
        
        print("WORKOUT ID \(workout.workoutID)")
        print("WORKOUT NAME \(workout.workoutName)")
        
        if sqlite3_prepare(database, insertRow, -1, &statement, nil) == SQLITE_OK {

            let workoutName: NSString = NSString(string: workout.workoutName)
            let workoutID: Int64 = Int64(workout.workoutID)
            
            sqlite3_bind_text(statement, 1, workoutName.utf8String, -1, nil)
            sqlite3_bind_int64(statement, 2, workoutID)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("success")
            } else {
                print("Could not add a workout.")
            }

        } else {
            print("Unable to execute the statement.")
        }
        sqlite3_finalize(statement)
    }
    
    //MARK: Add New Workout Composition
    func addNewWorkoutComposition(workoutComposition: WorkoutComposition) {
        var statement : OpaquePointer?
        let insertRow = "INSERT INTO workoutComposition(workoutID, exerciseID, numberOfSets, exerciseOrder, workoutCompositionID) VALUES (?, ?, ?, ?, ?);"
        
        print("WORKOUT ID \(workoutComposition.workoutID)")
        print("EXERCISE ID \(workoutComposition.exerciseID)")
        print("NUMBER OF SETS \(workoutComposition.numberOfSets)")
        print("EXERCISE ORDER \(workoutComposition.exerciseOrder)")
        print("WORKOUT COMPOSITION ID \(workoutComposition.workoutCompositionID)")
        
        if sqlite3_prepare(database, insertRow, -1, &statement, nil) == SQLITE_OK {
            print("assigning variables")
            let workoutID: Int64 = Int64(workoutComposition.workoutID)
            let exerciseID: Int64 = Int64(workoutComposition.exerciseID)
            let numberOfSets: Int64 = Int64(workoutComposition.numberOfSets)
            let exerciseOrder: Int64 = Int64(workoutComposition.exerciseOrder)
            let workoutCompositionID: Int64 = Int64(workoutComposition.workoutCompositionID)
            print("binding shall begin")

            sqlite3_bind_int64(statement, 1, workoutID)
            print("binding successful")
            sqlite3_bind_int64(statement, 2, exerciseID)
            print("binding successful")

            sqlite3_bind_int64(statement, 3, numberOfSets)
            print("binding successful")

            sqlite3_bind_int64(statement, 4, exerciseOrder)
            print("binding successful")

            sqlite3_bind_int64(statement, 5, workoutCompositionID)
            print("binding successful")

            if sqlite3_step(statement) == SQLITE_DONE {
                print("success")
            } else {
                print("Could not add a composition.")
            }

        } else {
            print("Unable to execute the statement.")
        }
        sqlite3_finalize(statement)
    }
    
    //MARK: Add New Session
    func addNewSession(session: Session) {
        var statement : OpaquePointer?
        let insertRow = "INSERT INTO sessions(workoutID, timeStarted, duration, sessionID) VALUES (?, ?, ?,?);"
        // INSERT INTO sessions(workoutID, timeStarted, duration, sessionID) VALUES (1, "23", 33,1);
        print("WORKOUT ID \(session.workoutID)")
        print("TIME STARTED \(session.timeStarted)")
        print("DURATION \(session.duration)")
        print("SESSION ID \(session.sessionID)")
        
        if sqlite3_prepare(database, insertRow, -1, &statement, nil) == SQLITE_OK {

            let workoutID: Int64 = Int64(session.workoutID)
            let timeStarted: NSString = NSString(string: session.timeStarted)
            let duration: Int64 = Int64(session.duration)
            let sessionID: Int64 = Int64(session.sessionID)
            
            sqlite3_bind_int64(statement, 1, workoutID)
            sqlite3_bind_text(statement, 2, timeStarted.utf8String, -1, nil)
            sqlite3_bind_int64(statement, 3, duration)
            sqlite3_bind_int64(statement, 4, sessionID)

            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("success")
            } else {
                print("Could not add a session.")
            }

        } else {
            print("Unable to execute the statement.")
        }
        sqlite3_finalize(statement)
    }
    
    //MARK: Add New Session History
    func addNewSessionHistory(sessionHistory: SessionHistory) {
        var statement : OpaquePointer?
        let insertRow = "INSERT INTO sessionHistory(exerciseID, sessionID, setNumber, weightUsed, repetitions, historyID) VALUES (?,?,?,?,?,?);"
        // INSERT INTO sessionHistory(exerciseID, sessionID, setNumber, weightUsed, repetitions, historyID) VALUES (1,1,1,20,3,1);
        print("EXERCISE ID \(sessionHistory.exerciseID)")
        print("SESSION ID \(sessionHistory.sessionID)")
        print("SET NUMBER \(sessionHistory.setNumber)")
        print("WEIGHT USED \(sessionHistory.weightUsed)")
        print("REPETITIONS \(sessionHistory.repetitions)")
        print("HISTORY ID \(sessionHistory.historyID)")
        
        if sqlite3_prepare(database, insertRow, -1, &statement, nil) == SQLITE_OK {

            let exerciseID: Int64 = Int64(sessionHistory.exerciseID)
            let sessionID: Int64 = Int64(sessionHistory.sessionID)
            let setNumber: Int64 = Int64(sessionHistory.setNumber)
            let weightUsed: Double = Double(sessionHistory.weightUsed)
            let repetitions: Int64 = Int64(sessionHistory.repetitions)
            let historyID: Int64 = Int64(sessionHistory.historyID)
            
            sqlite3_bind_int64(statement, 1, exerciseID)
            sqlite3_bind_int64(statement, 2, sessionID)
            sqlite3_bind_int64(statement, 3, setNumber)
            sqlite3_bind_double(statement, 4, weightUsed)
            sqlite3_bind_int64(statement, 5, repetitions)
            sqlite3_bind_int64(statement, 6, historyID)

            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("success")
            } else {
                print("Could not add a session.")
            }

        } else {
            print("Unable to execute the statement.")
        }
        sqlite3_finalize(statement)
    }
    
    //MARK: Get the Info of the Old Session
    func getPreviousResult(composition: WorkoutComposition, setNumber: Int) -> SessionHistory {
        let previousResultQuery = "SELECT * FROM sessionHistory WHERE exerciseID = \(composition.exerciseID) AND setNumber = \(setNumber) ORDER BY historyID DESC LIMIT 1"
        // order by historyID and take the latest record

        var previousResult: SessionHistory

        if sqlite3_prepare(database, previousResultQuery, -1, &statement, nil) == SQLITE_OK {

            while sqlite3_step(statement) == SQLITE_ROW {
                
                let exerciseID = sqlite3_column_int(statement, 0)
                let sessionID = sqlite3_column_int(statement, 1)
                let setNumber = sqlite3_column_int(statement, 2)
                let weightUsed = sqlite3_column_double(statement, 3)
                let repetitions = sqlite3_column_int(statement, 4)
                let historyID = sqlite3_column_int(statement, 5)
                
                previousResult = SessionHistory(exerciseID: Int(exerciseID), sessionID: Int(sessionID), setNumber: Int(setNumber), weightUsed: weightUsed, repetitions: Int(repetitions), historyID: Int(historyID))
                return previousResult
            }
            
        } else {
            print("Unable to open 'Previous Result' table")
            sqlite3_close(database)
        }
//        print (previousResultArray[0])
//        return previousResultArray
        return SessionHistory(exerciseID: 0, sessionID: 0, setNumber: 0, weightUsed: 0, repetitions: 0, historyID: 0)

    }
    
    //MARK: Pull Data for Chart
    func getActivityForDay(date : String) -> Int {
        let activityForDayQuery = "SELECT SUM(duration) FROM sessions WHERE timeStarted LIKE '%\(date)%'"
        
        if sqlite3_prepare(database, activityForDayQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {

                let duration = sqlite3_column_int(statement, 0)
                return Int(duration)
            }
            
        } else {
            print("Unable to open 'Sessions' table")
            sqlite3_close(database)
        }
        return 0
    }
}
