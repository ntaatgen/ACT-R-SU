//
//  StartButtonView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 1/25/23.
//

import SwiftUI

struct TimeButtonView: View {
    @ObservedObject var model: DemoViewModel
    var body: some View {
        VStack {
            Button {
                model.choose(action: "button")
            } label: {
                Text(model.feedback)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

//struct StartButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartButtonView()
//    }
//}
