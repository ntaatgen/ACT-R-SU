//
//  HomeView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var model: DemoViewModel

    var body: some View {
        VStack {
            Image("ACT-R").padding()
            Text("Welcome to ACT-R!").padding()
            Text(model.currentModel.modelDescription)
            Button("Switch Model") {
                model.switchModel()
            }
            .buttonStyle(.bordered)
            .padding()

            
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
