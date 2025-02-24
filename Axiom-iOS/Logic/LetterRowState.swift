//
//  LetterRowState.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/22/25.
//


struct LetterRowState: Equatable {
    let states : [LetterBoxState]
    
    init() {
        self.states = []
    }
    
    init(_ states : [LetterBoxState]) {
        self.states = states
    }
    
    // fill out empties when a certain length is required
    init(_ obj : LetterRowState,_ desiredLength : Int) {
        var newStates = obj.states
        
        for _ in newStates.count..<desiredLength {
            newStates.append(.Empty)
        }
        
        self.states = newStates
    }
    
    func stateAtIndex (_ index : Int)-> LetterBoxState {
        return states[index]
    }
    
    static func allError(_ desiredLength : Int) -> LetterRowState {
        return LetterRowState(Array(repeating: LetterBoxState.Error, count: desiredLength))
    }
}



