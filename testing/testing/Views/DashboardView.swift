//
//  DashboardView.swift
//  testing
//
//  Created by Batyr Zhangabylov on 9/6/21.
//  DashboardView to display the dashboard with the recent activity chart, app name, icon, time, and a history button.

import SwiftUI
import SwiftUICharts

struct DashboardView: View {
    @ObservedObject var db : Database
    @State var progress: Int = 57
    
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    // Formatter used for the time displayed on dashboard
    var formatDateTime: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "hh:mm a"
        return format
    }
    // Formatter used to look up sessions in the database
    var formatDateDay: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "MMMM d, yyyy"
        return format
    }
    // Formatter used to display dates on the barchart
    var formatDateDayShort: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "MMM d"
        return format
    }
    
    @State var hour = ""
    @State var selected = 0
    var colors = [Color("firstColor"), Color("secondColor")]
    
    @State var showHistory = false

    var body: some View {
        
        let dateOfToday = formatDateDay.string(from: Date())
        let oneDayAgo = formatDateDay.string(from: addOrSubtractDay(day: -1))
        let twoDaysAgo = formatDateDay.string(from: addOrSubtractDay(day: -2))
        let threeDaysAgo = formatDateDay.string(from: addOrSubtractDay(day: -3))
        let fourDaysAgo = formatDateDay.string(from: addOrSubtractDay(day: -4))
        let fiveDaysAgo = formatDateDay.string(from: addOrSubtractDay(day: -5))
        let sixDaysAgo = formatDateDay.string(from: addOrSubtractDay(day: -6))
        
        let dateOfTodayS = formatDateDayShort.string(from: Date())
        let oneDayAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -1))
        let twoDaysAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -2))
        let threeDaysAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -3))
        let fourDaysAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -4))
        let fiveDaysAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -5))
        let sixDaysAgoS = formatDateDayShort.string(from: addOrSubtractDay(day: -6))

        let workout_Data = [
            Daily(id: 0, day: sixDaysAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: sixDaysAgo))),
            Daily(id: 1, day: fiveDaysAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: fiveDaysAgo))),
            Daily(id: 2, day: fourDaysAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: fourDaysAgo))),
            Daily(id: 3, day: threeDaysAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: threeDaysAgo))),
            Daily(id: 4, day: twoDaysAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: twoDaysAgo))),
            Daily(id: 5, day: oneDayAgoS, durationInSeconds: CGFloat(db.getActivityForDay(date: oneDayAgo))),
            Daily(id: 6, day: dateOfTodayS, durationInSeconds: CGFloat(db.getActivityForDay(date: dateOfToday)))
        ]

        NavigationView {
            VStack {
                Text("DICED")
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text("\(hour)")
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .onReceive(timer) { _ in
                        self.hour = formatDateTime.string(from: Date())
                    }
                Spacer()
                
                Image("ICONIMAGE-1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150, alignment: .center)
                Spacer()

                .navigationBarItems(leading: Text("Dashboard").font(Font.system(.title)).fontWeight(.bold))
                .navigationBarItems(trailing:
                        Button(action: {
                            self.showHistory.toggle()
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 150, height: 40, alignment: .center)
                                    .cornerRadius(15)
                                    .foregroundColor(Color("lightGray"))
                                    .shadow(radius: 10)
                                Text("HISTORY")
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 5)
                            }
                        }
                    )
                .sheet(isPresented: $showHistory) {
                    HistoryView(db: self.db)
                }
                
                Spacer()
                
                // Bar Chart
                VStack(alignment: .leading, spacing: 25) {
                    Text("Recent Activity (Min/Day)")
                        .font(.system(size:22))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 5) {
                        ForEach(workout_Data) {work in
                            // Bars
                            VStack {
                                VStack {
                                    Spacer(minLength: 0)
                                    if selected == work.id {
                                        Text(toMins(value: work.durationInSeconds))
                                            .foregroundColor(Color("firstColor"))
                                            .padding(.bottom,5)
                                    }
                                    RoundedShape()
                                        .fill(LinearGradient(gradient: .init(colors: selected == work.id ? colors : [Color.white.opacity(0.06)]), startPoint: .top, endPoint: .bottom))
                                        .frame(height: getHeight(value: work.durationInSeconds))
                                }
                                .frame(height:220)
                                .onTapGesture() {
                                    withAnimation(.easeOut){
                                        selected = work.id
                                    }
                                }
                                Text(work.day)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        
                    }
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .cornerRadius(10)
            .padding()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
    }
    
    // Calculating height of bars
    func getHeight(value: CGFloat)->CGFloat{
        // Getting height (86400 seconds in a day)
        let height = CGFloat(value/86400)*3000
        // Makes sure the bar is not too big
        if height < 220 {
            return height
        } else {
            return 220
        }
    }
    // Converting from seconds to minutes
    func toMins(value: CGFloat)->String {
        let minutes = value/60
        return String(format:"%.1f", minutes)
    }
    // Changing the date to get other dates for the graph
    func addOrSubtractDay(day:Int)->Date{
      return Calendar.current.date(byAdding: .day, value: day, to: Date())!
    }
}
// Shape of the barchart
struct RoundedShape : Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight],cornerRadii: CGSize(width: 5, height: 5))
        return Path(path.cgPath)
    }
}
// Structure for daily activity
struct Daily : Identifiable {
    var id : Int
    var day : String
    var durationInSeconds : CGFloat
}
