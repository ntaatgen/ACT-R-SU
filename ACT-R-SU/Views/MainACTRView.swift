//
//  MainACTRView.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

/// Main model view: shows five tabs that have their own views
struct MainACTRView: View {
    @ObservedObject var prisonerGame: DemoViewModel
    var body: some View {
        TabView {
            HomeView(model: prisonerGame)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            ModelView(model: prisonerGame)
                .tabItem{
                    Label("Model", systemImage: "doc")
                }
            TraceView(model: prisonerGame)
                .tabItem{
                    Label("Trace", systemImage: "eye")
                }
            DMView(model: prisonerGame)
                .tabItem{
                    Label("DM", systemImage: "memorychip")
                }
            ModelInteractionView(model: prisonerGame)
                .tabItem {
                    Label(prisonerGame.currentModel == .countModel || prisonerGame.currentModel == .timeModel ? "Start" : "Dilemma", systemImage: "person.fill.questionmark")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = DemoViewModel()
        return MainACTRView(prisonerGame: model)
    }
}
