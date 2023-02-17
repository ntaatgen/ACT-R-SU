//
//  ModelInteractionView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 1/25/23.
//

import SwiftUI

struct ModelInteractionView: View {
    @ObservedObject var model: DemoViewModel
    var body: some View {
        if model.currentModel == .countModel {
            StartButtonView(model: model)
        } else if model.currentModel == .timeModel{
            TimeButtonView(model: model)
        } else {
            PrisonerView(model: model)
        }
    }
}

//struct ModelInteractionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelInteractionView()
//    }
//}
