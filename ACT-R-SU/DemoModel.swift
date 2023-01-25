//
//  DemoModel.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

class DemoModel: ObservableObject {
    
    @Published private var model: PDModelProtocol
    
    @Published var currentModel = ModelSelection.stevensStandard

    enum ModelSelection: Int, CaseIterable {
        case stevensStandard
        case stevensSwiftACTR
        case stevensSwiftFree
        case lebiereStandard
        case countModel
        case timeModel
        var modelDescription: String {
            ["Stevens model, standard ACT-R",
             "Stevens model, swift ACT-R style",
             "Stevens model, swift free style",
             "Lebiere model, standard ACT-R",
             "Count model",
             "Time estimation"][self.rawValue]
            }
        func nextModel() -> ModelSelection {
            return ModelSelection(rawValue: (self.rawValue + 1) % ModelSelection.allCases.count)!
        }
    }

    
    init() {
        model = PDModel1()
        model.loadModel(filename: "prisoner2")
        model.run()
        model.update()
    }
 
    var modelText: String {
        model.modelText
    }
    
    var traceText: String {
        model.traceText
    }
    
    func reset() {
        model.reset()
        model.update()
    }
    
    func run() {
        model.run()
        model.update()
    }
    
    var dmContent: [PublicChunk] {
        model.dmContent
    }
    
    var feedback: String { model.feedback }
    
    // MARK: - Intent(s)
    
    func choose(action: String) {
        if model.waitingForAction {
            model.choose(playerAction: action)
        }
    }
    
    func switchModel() {
        currentModel = currentModel.nextModel()
        switch (currentModel) {
        case .stevensStandard:
            model = PDModel1()
            model.loadModel(filename: "prisoner2")
            model.run()
        case .stevensSwiftACTR:
            model = PDModel2()
            model.run()
        case .stevensSwiftFree:
            model = PDModel3()
            model.run()
        case .lebiereStandard:
            model = PDModel1()
            model.loadModel(filename: "prisoner")
            model.run()
        case .countModel:
            model = PDModelGeneral()
            model.loadModel(filename: "count")
        case .timeModel:
            model = PDModelGeneral()
            model.loadModel(filename: "time")
        }
        model.update()
    }
}
