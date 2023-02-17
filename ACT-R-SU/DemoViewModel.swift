//
//  DemoViewModel.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 28/12/22.
//

import SwiftUI

class DemoViewModel: ObservableObject {
    
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
    
    private var startTime = Date()
    private var timer: Timer?
    
    func choose(action: String) {
        if currentModel != .timeModel {
            if model.waitingForAction {
                model.choose(playerAction: action)
            } else {
                return
            }
        }
        /// We have to do this as part of the ViewModel, which is ackward, but timers do not work very well in structs
        /// The reason is that the timer passes a message to an object, so a reference to an object is needed which is not
        /// possible in structs.
        ///
        switch feedback {
        case "Start": // user just pressed the start button
            startTime = Date() // record the start time
            model.feedback = "Stop" // Wait until user presses stop
            
            //
        case "Stop": // user just ended the interval
            let elapsedTime = Double(Date().timeIntervalSince(startTime))
            print("\(elapsedTime) has passed")
            model.model.run(maxTime: elapsedTime)
            let chunk = model.model.generateNewChunk()
            chunk.setSlot(slot: "isa", value: "waiting-for-stop")
            model.model.buffers["action"] = chunk
            model.model.run()
            model.update()
            model.feedback = "Reproduce"
        case "Reproduce":
            let modelStartTime = model.model.time
            model.model.run()
            model.update()
            let modelRunTime = model.model.time - modelStartTime
            model.feedback = "Waiting..."
            timer = Timer.scheduledTimer(withTimeInterval: modelRunTime, repeats: false, block: {_ in self.model.feedback = "Done"})
        case "Done":
            model.reset()
        default:
            break
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
            model = PDModelTime()
            model.loadModel(filename: "time")
            model.run()
        }
        model.update()
    }
}
