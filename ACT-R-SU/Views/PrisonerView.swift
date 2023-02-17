//
//  PrisonerView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

struct PrisonerView: View {
    @ObservedObject var model: DemoViewModel

    var body: some View {
        VStack() {
            
            Text("What do you want?")
                .font(.title)
                .padding()

            Button(action: {
                model.choose(action: "coop")
            }) {
                Image("Cooperate")
            }
            Text("Cooperate")
            Button(action: {
                model.choose(action: "defect")
            }) {
                Image("Defect")
            }
            Text("Defect")

            Text(model.feedback)
                .padding()
            Spacer()
        }
    }
}

//struct PrisonerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrisonerView()
//    }
//}
