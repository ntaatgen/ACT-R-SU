//
//  PDModel3.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 16/1/23.
//

import Foundation

/// This is the third version of the PDModel. Like in the second version, we also do not load an ACT-R
/// file. Also, we do not simulate productions rules, or use the module buffers if we do not strictly need
/// them. In fact, we only use declarative memory, which is the main ACT-R component that drives this
/// particular model. You can also see that the time keeping is only approximate, because we no longer
/// stick to the production cycle.
/// The advantage is that the run function is shorter and easier to read.
///
struct PDModel3: PDModelProtocol {
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true 
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
        model.waitingForAction = true
    }
    
    /// Enum to represent the choices. It is always good to use enums for internal representation, because
    /// they can help you with preventing bugs. (e.g., if you use strings it is easy to make a typo)
    enum Choice: CustomStringConvertible {
        case cooperate
        case defect
        var description: String {
            switch self {
            case .cooperate:
                return "coop"
            case .defect:
                return "defect"
            }
        }
    }
    
    /// These represent the current and previous choice by the player and the model. They are optionals
    /// because they don't have values right away
    private var lastModel: Choice?
    private var lastPlayer: Choice?
    private var currentModel: Choice?
    private var currentPlayer: Choice?
    
    /// Run the model until it has made a decision,
    /// which means it waits for a response
    /// At the start of the call, currentModel and currentPlayer contain the choices of the last round (unless this is the first round),
    /// and lastModel and lastPlayer the choice from the round before that (unless this is the first or second round)
    mutating func run() {
        if currentModel == nil {
            currentModel = actrNoise(noise: 1.0) > 0 ? .cooperate : .defect
            model.time += 1.0
            model.addToTrace(string: "First decision: random pick")
        } else if lastModel == nil {
            lastModel = currentModel
            lastPlayer = currentPlayer
            currentModel = lastPlayer // tit for tat
            model.time += 1.0
            model.addToTrace(string: "Second decision: tit for tat")
        } else {
            lastModel = currentModel
            lastPlayer = currentPlayer
            let query = Chunk(s: "query", m: model)
            query.setSlot(slot: "model", value: lastModel!.description)
            query.setSlot(slot: "player", value: lastPlayer!.description)
            let (latency, chunk) = model.dm.retrieve(chunk: query)
            if let newPlayer = chunk?.slotvals["new-player"]?.description {
                currentModel = newPlayer == "coop" ? .cooperate : .defect
                model.addToTrace(string: "Retrieving \(chunk!)")
            } else {
                currentModel = lastPlayer
                model.addToTrace(string: "Failed retrieval, tit for tat instead")
            }
            model.time += 1.0 + latency
        }
            update()
        waitingForAction = true
    }
    
    /// Reset the model and the game
    mutating func reset() {
        model.reset()
        model.waitingForAction = true
        modelScore = 0
        playerScore = 0
        feedback = ""
        lastModel = nil
        lastPlayer = nil
        currentModel = nil
        currentPlayer = nil
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
    /// and can be shown in the display. The function also adds a chunk to memory that
    /// reflects the experience.
    /// - Parameter playerAction: "coop" or "defect"
    mutating func choose(playerAction: String) {
       guard currentModel != nil else { return }
        model.addToTrace(string: "Player chooses \(playerAction)")
        currentPlayer = playerAction == "coop" ? Choice.cooperate : Choice.defect
        switch (currentPlayer!, currentModel!) {
        case (.cooperate,.cooperate):
             modelreward = 1
             playerreward = 1
        case (.cooperate,.defect):
             modelreward = 10
             playerreward = -10
        case (.defect,.cooperate):
             modelreward = -10
             playerreward = 10
        case (.defect,.defect):
             modelreward = -1
             playerreward = -1
        }
        modelScore += modelreward
        playerScore += playerreward
        feedback = "The model chooses \(currentModel!)\nYou get \(playerreward) and I get \(modelreward)\n"
        feedback += "Model score is \(modelScore) and the player's score is \(playerScore)\n"
        if (lastModel != nil && lastPlayer != nil) {
            let newExperience = model.generateNewChunk(string: "instance")
            newExperience.setSlot(slot: "model", value: lastModel!.description)
            newExperience.setSlot(slot: "player", value: lastPlayer!.description)
            newExperience.setSlot(slot: "new-player", value: playerAction)
            model.dm.addToDM(newExperience)
        }
        model.time += 1.0
        run()
        update()
    }

}
