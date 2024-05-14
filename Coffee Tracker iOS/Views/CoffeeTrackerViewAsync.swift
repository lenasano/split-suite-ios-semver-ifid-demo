/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view where users can add drinks or view the current amount of caffeine they have drunk.
*/

import SwiftUI

// The Coffee Tracker app's main view.
struct CoffeeTrackerViewAsync: View {
    
    @EnvironmentObject var coffeeData: CoffeeDataAsync
    
    @State var showDrinkList = false
    
    // Lay out the view's body.
    var body: some View {
        VStack {
            
            // Display the current amount of caffeine in the user's body.
            Text(coffeeData.currentMGCaffeineString + " mg")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(colorForCaffeineDose())
            Text("Current Caffeine Dose")
                .font(.footnote)
            
            // Display how much the user has drunk today,
            // using the equivalent number of 8 oz. cups of coffee.
            Text(coffeeData.totalCupsTodayString + " cups")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(colorForDailyDrinkCount())
            Text("Equivalent Drinks Today")
                .font(.footnote)
            
            // Display a button that lets the user record new drinks.
            Button(action: { self.showDrinkList.toggle() }) {
                Image("add-coffee")
                    .renderingMode(.template)
                    .foregroundColor(Color(red: 0.3, green: 1.0, blue: 1.0)) // .teal
            }.padding()
        }
        .sheet(isPresented: $showDrinkList) {
            DrinkListViewAsync().environmentObject(self.coffeeData)
        }
    }
    
    // MARK: - Private Methods
    // Calculate the color based on the amount of caffeine currently in the user's body.
    private func colorForCaffeineDose() -> Color {
        // Get the current amount of caffeine in the system.
        let currentDose = coffeeData.currentMGCaffeine
        
        if #available(iOS 15, *) {
            return Color(uiColor: coffeeData.color(forCaffeineDose: currentDose))
        } else {
            return Color(coffeeData.color(forCaffeineDose: currentDose))
        }
    }
    
    // Calculate the color based on the number of drinks consumed today.
    private func colorForDailyDrinkCount() -> Color {
        // Get the number of cups drank today
        let cups = coffeeData.totalCupsToday
        
        if #available(iOS 15, *) {
            return Color(uiColor: coffeeData.color(forTotalCups: cups))
        } else {
            return Color(coffeeData.color(forTotalCups: cups))
        }
    }
}

// Configure a preview of the coffee tracker view.
#Preview {
    CoffeeTrackerViewAsync()
        .environmentObject(CoffeeDataAsync.shared)
}
