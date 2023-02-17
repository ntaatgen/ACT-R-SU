//
//  StartButtonView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 1/25/23.
//

import SwiftUI

struct StartButtonView: View {
    @ObservedObject var model: DemoViewModel
    var body: some View {
        Button("Start the model") {
            model.run()
        }
    }
}

//struct StartButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartButtonView()
//    }
//}
