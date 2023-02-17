//
//  ModelView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

/// Show the model's text and a Button to reset the model
struct ModelView: View {
    @ObservedObject var model: DemoViewModel

    var body: some View {
        VStack {
            Text("Model text")
                .font(.title)
            ScrollView {
                Text(model.modelText == "" ? "There is no model text" : model.modelText).font(Font.system(.body))
            }.padding()
            Button("Reset model") {
                model.reset()
            }
            .buttonStyle(.bordered)
        } .padding()
    }
}

//struct ModelView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelView()
//    }
//}
