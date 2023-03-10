//
//  DMView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

/// Show the contents of declarative memory. The list shows the chunk names with their activation (ChunkView)
/// If you click on a link, you get the detailed view (ChunkDetailView, in a separate file)
struct DMView: View {
    @ObservedObject var model: DemoViewModel
    
    var body: some View {
        NavigationView {
            List(model.dmContent) {
                chunk in
                NavigationLink {
                    ChunkDetailView(chunk: chunk)
                } label: {
                    ChunkView(chunk: chunk)
                }
            }.navigationTitle("DM Contents")
        }
        
    }
}

struct ChunkView: View {
    var chunk: PublicChunk
    var body: some View {
        HStack {
            Text(chunk.name)
            Text("Activation = \(chunk.activation)").font(.caption2)
            Spacer()
        }
    }
}

//struct DMView_Previews: PreviewProvider {
//    static var previews: some View {
//        DMView()
//    }
//}
