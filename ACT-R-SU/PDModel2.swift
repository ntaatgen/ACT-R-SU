//
//  PDModel.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 16/1/23.
//

import Foundation

/// This is the second version of the PDModel, in which we do not load an ACT-R file.
/// Instead, the run function implements the model. In this version we stay very close
/// to the architecture: the code inspects the contents of the ACT-R buffers, and based
/// on that decides what to do.
/// The advantage is that is closer to regular programming, but it does require some
/// knowledge about the implementation of ACT-R, and which functions to call.
/// Because we stay close to ACT-R, the code can look cluncky.
///
struct PDModel2: PDModelProtocol {
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = false
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    /// Amount of points the model gets
    var modelreward = 0
    /// Amount of points the player gets
    var playerreward = 0
    /// Model's total score
    var modelScore = 0
    /// Player's total score
    var playerScore = 0
    /// The ACT-R model
    internal var model = Model()
    
    /// Here we do not actually load in anything: we just reset the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    func loadModel(filename: String) {
        model.reset()
    }
    
    
    /// Run the model until done, or until it puts something in the action buffer,
    /// which means it waits for a response
    mutating func run() {
        if model.buffers["goal"] == nil {
            let chunk = Chunk(s: model.generateName(string: "goal"), m: model)
            chunk.setSlot(slot: "isa", value: "goal")
            chunk.setSlot(slot: "state", value: "start")
            model.buffers["goal"] = chunk
        }
        let goal = model.buffers["goal"]!
        var done = false
        while !done {
            switch (goal.slotvals["state"]!.description) {
            case "start":
                // In the first trial we randomly pick someting
                if actrNoise(noise: 1.0) > 0 {
                    goal.setSlot(slot: "model", value: "defect")
                } else {
                    goal.setSlot(slot: "model", value: "coop")
                }
                goal.setSlot(slot: "state", value: "decided")
                model.time += 0.05
                model.addToTrace(string: "Starting with a random pick")
            case "decided":
                // Once we have decided upon an action, make an action chunk and wait for the human player
                let action = Chunk(s: "action", m: model)
                action.setSlot(slot: "isa", value: "decision")
                action.setSlot(slot: "model", value: goal.slotvals["model"]!.description)
                goal.setSlot(slot: "state", value: "wait")
                model.time += 0.05
                model.buffers["action"] = action
                done = true
                model.addToTrace(string: "Waiting for player choice")
                model.waitingForAction = true
            case "wait":
                // The human player has decided and the scores have been calculated
                // If there is a current trials and a previous trial, we remember what the player and I did
                // the last time and what the player subsequently did.
                // In addition we  store the current choice in the imaginal buffer for use in the next
                // trial.
                let action = model.buffers["action"]!
                if let imaginal = model.buffers["imaginal"] {
                    imaginal.setSlot(slot: "next-move", value: action.slotvals["player"]!)
                    model.dm.addToDM(imaginal)
                    model.addToTrace(string: "Adding experience to memory \(imaginal)")
                }
                let newImaginal = Chunk(s: model.generateName(string: "instance"), m: model)
                newImaginal.setSlot(slot: "isa", value: "sequence")
                newImaginal.setSlot(slot: "model", value: action.slotvals["model"]! )
                newImaginal.setSlot(slot: "player", value: action.slotvals["player"]!)
                model.buffers["imaginal"] = newImaginal
                model.time += 0.05 + model.imaginalActionTime
                model.addToTrace(string: "Remembering decisions")
                goal.setSlot(slot: "state", value: "go")
                goal.slotvals["player"] = nil
                goal.slotvals["model"] = nil
                model.time += 0.05
                model.addToTrace(string: "Resetting goal")
            case "go":
                // If it is not the first trial, we try to recall a previous experience
                // based on the last trial, and if that succeeds, we do the same as we
                // expect the player to do.
                let imaginal = model.buffers["imaginal"]!
                let retrieval = Chunk(s: "retrieval", m: model)
                retrieval.setSlot(slot: "isa", value: "sequence")
                retrieval.setSlot(slot: "model", value: imaginal.slotvals["model"]!)
                retrieval.setSlot(slot: "player", value: imaginal.slotvals["player"]!)
                let (latency, result) = model.dm.retrieve(chunk: retrieval)
                model.time += 0.05 + latency
                if let retrievedChunk = result {
                    goal.setSlot(slot: "model", value: retrievedChunk.slotvals["next-move"]!)
                    model.addToTrace(string: "Retrieving \(retrievedChunk)")
                } else { // retrieval failure
                    if actrNoise(noise: 1.0) > 0 {
                        goal.setSlot(slot: "model", value: "defect")
                    } else {
                        goal.setSlot(slot: "model", value: "coop")
                    }
                }
                goal.setSlot(slot: "state", value: "decided")
                model.time += 0.05
            default: done = true
            }
            update()
        }
    }
    
    /// Reset the model and the game
    mutating func reset() {
        model.reset()
        modelScore = 0
        playerScore = 0
        feedback = ""
        run()
    }
    
    /// Modify a slot in the action buffer.
    /// Not used in this version.
    /// - Parameters:
    ///   - slot: the slot to be modified
    ///   - value: the new value
    /// - Returns: whether successful
    func modifyLastAction(slot: String, value: String) -> Bool {
        if model.waitingForAction {
            model.modifyLastAction(slot: slot, value: value)
            return true
        } else {
            return false
        }
    }
        
    /// Function that is executed whenever the player makes a choice. At that point
    /// the model has already made a choice, so the score can then be calculated,
    /// and can be shown in the display. The function also modifies the action chunk
    /// to reflect the outcome, and reruns the model for the next decision
    /// - Parameter playerAction: "coop" or "defect"
    mutating func choose(playerAction: String) {
        let modelAction = model.lastAction(slot: "model")!
        switch (playerAction == "coop", modelAction) {
        case (true,"coop"):
             modelreward = 1
             playerreward = 1
//            newImage = UIImage(named: "Cooperate.jpg")!
        case (true,"defect"):
             modelreward = 10
             playerreward = -10
//             newImage = UIImage(named: "Defect.jpg")!
        case (false,"coop"):
             modelreward = -10
             playerreward = 10
//             newImage = UIImage(named: "Cooperate.jpg")!
        case (false,"defect"):
             modelreward = -1
             playerreward = -1
//             newImage = UIImage(named: "Defect.jpg")!
        default:  modelreward = 0
         playerreward = 0
        }
        modelScore += modelreward
        playerScore += playerreward
        feedback = "The model chooses \(modelAction)\nYou get \(playerreward) and I get \(modelreward)\n"
        feedback += "Model score is \(modelScore) and the player's score is \(playerScore)\n"
        model.modifyLastAction(slot: "player", value: playerAction)
        model.modifyLastAction(slot: "payoffA", value: String(modelreward))
        model.modifyLastAction(slot: "payoffB", value: String(playerreward))
        run()
        update()
    }

}
