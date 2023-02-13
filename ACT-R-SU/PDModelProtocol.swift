//
//  PDModelProtocol.swift
//  ACT-R-SU
//
//  Created by Niels Taatgen on 1/17/23.
//

import Foundation

/// We use a protocol to be able to switch between different models. A protocol specifies what variables and functions a struct
/// needs to implement. In addition, we specify the update function because it is the same for all models.
protocol PDModelProtocol {
    var traceText: String { get set }
    var model: Model {get set }
    var modelText: String { get set }
    var dmContent: [PublicChunk] { get set }
    var waitingForAction: Bool { get set }
    var feedback: String { get set }
    var modelreward: Int { get set }
    var playerreward: Int { get set }
    var modelScore: Int { get set }
    var playerScore: Int { get set }
    func loadModel(filename: String)
    mutating func run()
    mutating func reset()
    func modifyLastAction(slot: String, value: String) -> Bool
    mutating func choose(playerAction: String)
    mutating func update()
}

extension PDModelProtocol {
    /// Update the representation of the model in the struct. If the struct changes,
    /// the View is automatically updated, but this does not work for classes.
    mutating func update() {
        self.traceText = model.trace
        self.modelText = model.modelText
        dmContent = []
        var count = 0
        for (_,chunk) in model.dm.chunks {
            var slots: [(slot: String,val: String)] = []
            for slot in chunk.printOrder {
                if let val = chunk.slotvals[slot] {
                    slots.append((slot:slot, val:val.description))
                }
            }
            dmContent.append(PublicChunk(name: chunk.name, slots: slots, activation: chunk.activation(),id: count))
            count += 1
        }
        dmContent.sort { $0.activation > $1.activation }
        waitingForAction = true
    }
}
