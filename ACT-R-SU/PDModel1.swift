//
//  PDModel.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 16/1/23.
//

import Foundation

/// This struct serves a proxy for the model class
/// Because SwiftUI deals with structs, we need a struct that can serve as an
/// intermediate. The update function copies the relevant information out of the
/// Model object into the struct.
/// In addition, the struct implements the game logic by assigning points to choices,
/// by tracking the scores and by giving feedback.
///
/// This is the first of three versions
/// In this version, we load in a text file with an ACT-R model in the ACT-R syntax.
/// The advantage is that it guarentees the model adheres to ACT-R's constraints,
/// and that the modeling software takes care of timing, buffer updates, etc.
/// De disadvantage is that you need experience with the ACT-R syntax, and that
/// it is harder to debug the model.
///
struct PDModel1: PDModelProtocol {
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
    
    /// Function that loads in a text file that is interpreted as the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    func loadModel(filename: String) {
        model.loadModel(fileName: filename)
    }
    
    /// Run the model until done, or until it reaches a +action>
    mutating func run() {
        model.run()
    }
    
    /// Reset the model and the game
    mutating func reset() {
        model.reset()
        modelScore = 0
        playerScore = 0
        feedback = ""
        model.run()
    }
    
    /// Modify a slot in the action buffer
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
        case (true,"defect"):
             modelreward = 10
             playerreward = -10
        case (false,"coop"):
             modelreward = -10
             playerreward = 10
        case (false,"defect"):
             modelreward = -1
             playerreward = -1
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
        model.run()
        update()
    }

}


