//
//  ContentView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 9/6/21.
//  Content View is the first view to be opened in the application. Contains the tabview.

import SwiftUI

@available(iOS 15.0, *)
struct ContentView: View {
    @ObservedObject var db : Database

    var body: some View {
        TabView {
            DashboardView(db: self.db).tabItem {
                Image("dashboard")
                Text("work please")
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
    }
}
