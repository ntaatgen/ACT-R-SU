//
//  ACT_R_SUApp.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

@main
struct ACT_R_SUApp: App {
    let game = DemoViewModel()
    var body: some Scene {
        WindowGroup {
            MainACTRView(prisonerGame: game)
        }
    }
}
