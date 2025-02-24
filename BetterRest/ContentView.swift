//
//  ContentView.swift
//  BetterRest
//
//  Created by Kiran Shrestha on 2/21/25.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    private let sleepAmountChoices = Array(stride(from: 4, through: 12, by: 0.25))
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?"){
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep"){
//                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    Picker("\(sleepAmount.formatted()) hours", selection: $sleepAmount, content: { 
                        ForEach(sleepAmountChoices, id: \.self) { num in
                            Text("\(num.formatted())")
                        }
                    })
                }


                
                Section("Daily coffee intake") {
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...6, step: 1)
                }
                
                Section() {
                    Text("Recommended Sleep Time is \(calculateBedtime())")
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() -> String{
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(input: .init(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            return "There was an problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}
