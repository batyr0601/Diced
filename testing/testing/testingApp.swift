//
//  testingApp.swift
//  testing
//
//  Created by Batyr Zhangabylov on 9/3/21.
//  App file that starts when the app opens

import SwiftUI


@available(iOS 15.0, *)
@main
struct testingApp: App {
    var db = Database()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                DashboardView(db: self.db).tabItem {
                    Image("dashboard")
                    Text("Dashboard")
                }

                WorkoutsView(db: self.db).tabItem {
                    Image("workouts")
                    Text("Your Workouts")
                }

                ExercisesView(db: self.db).tabItem {
                    Image("exercises")
                    Text("Exercises")
                }
            }
            .accentColor(.white)
        }
    }
}
