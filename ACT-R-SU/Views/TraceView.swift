//
//  TraceView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

struct TraceView: View {
    @ObservedObject var model: DemoViewModel
    
    var body: some View {
        
        VStack {
            Text("Trace").font(Font.system(.headline))
            ScrollView {
                Text(model.traceText).padding()
            }
            Spacer()
        }.padding()
    }
    
}

//struct TraceView_Previews: PreviewProvider {
//    static var previews: some View {
//        TraceView()
//    }
//}
