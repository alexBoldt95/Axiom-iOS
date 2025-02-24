//
//  LetterGrid.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterGrid: View {
    private let numRows: Int = 6
    private let numCols: Int = 5
    let secretWord: String
    var guessList: [String]
    private var guessStates: [LetterRowState]
    
    init(secretWord: String = "axiom", guessList: [String] = []) {
        self.secretWord = secretWord
        
        var myGuessList = guessList
        // fill out rest with empties
        for _ in guessList.count..<numRows {
            myGuessList.append("")
        }
        
        self.guessList = myGuessList
        let guesser = Guesser()
        var myRowStates: [LetterRowState] = []
        // MUST INITIALIZE ALL PROPERTIES WITHIN INIT(), CANNOT FIND A WAY TO USE A HELPER FUNC...
        for i in 0..<numRows {
            do {
                let result = try guesser.GetLetterStates(secretWord, myGuessList[i])
                myRowStates.append(result)
            } catch {
                myRowStates.append(LetterRowState.allError(numCols))
            }
        }
        self.guessStates = myRowStates
    }
    
    
    var body: some View {
        VStack {
            ForEach(0..<numRows, id: \.description) { guessIndex in
                LetterRow(theWord: guessList[guessIndex], letterStates: guessStates[guessIndex])
            }
        }
    }
}

#Preview {
    LetterGrid(secretWord:"axiom", guessList: ["testa", "xioma", "fairy"])
}
