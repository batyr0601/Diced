//
//  HistoryView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 2/24/22.
//  History view to display all of the sessions completed by the user.

import SwiftUI

struct HistoryView: View {
    @ObservedObject var db : Database
    
    var body: some View {
        Spacer()
        ZStack {
            Rectangle()
                .frame(width: 350, height: 40, alignment: .center)
                .cornerRadius(8)
                .foregroundColor(Color("lightGray"))
                .shadow(radius: 10)

            Text("History Of Workouts")
                .foregroundColor(.black)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 5)
        }
        Spacer()
        ScrollView {
            Spacer()
            // double nested for loop
            ForEach(db.sessionList.reversed()) { session in
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.06))
                        .cornerRadius(2)
                        .shadow(radius: 10)
                    VStack {
                        Spacer()
                        Text("\(session.timeStarted)")
                    
                        // calculating the duration of the session
                        let hours : Int = session.duration/3600;
                        let minutes : Int = (session.duration - hours*3600)/60;
                        let seconds = session.duration - hours*3600 - minutes*60;
                        
                        HStack {
                            // Find the workout name by ID
                            ForEach(db.workoutList) { workout in
                                if workout.workoutID == session.workoutID {
                                    Text("\(workout.workoutName)")
                                        .fontWeight(.bold)
                                        .font(.title3)
                                }
                            }
                            
                            Text("\(hours):\(minutes):\(seconds)")
                                .font(.title3)
                        }
                        Spacer()
                    }

                }
                Divider()
                Spacer()

            }
        }
    }
}
//
//struct HistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryView()
//    }
//}
