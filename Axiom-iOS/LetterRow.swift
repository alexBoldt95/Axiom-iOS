//
//  LetterRow.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterRow: View {
    var theWord: String
    var letterStates: LetterRowState
    private let rowLength: Int = 5
    
    init(theWord: String, letterStates: LetterRowState) {
        self.theWord = theWord
        self.letterStates = LetterRowState(letterStates, rowLength)
    }
    var body: some View {
        HStack {
            ForEach(0..<theWord.count, id: \.description) { index in
                let letterIndex = theWord.index(theWord.startIndex, offsetBy: index)
                let thisLetter = String(theWord[letterIndex])
                LetterBox(theLetter: thisLetter, theState: letterStates.stateAtIndex(index))
            }
            // TODO fill empties from the word directly...
            ForEach(theWord.count..<rowLength, id: \.description) { _ in
                LetterBox(theLetter: "", theState: LetterBoxState.Empty)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let guessWord = "AXIOm"
    LetterRow(theWord: guessWord, letterStates: LetterRowState([.Correct, .Incorrect, .Position, .Incorrect]))
}
