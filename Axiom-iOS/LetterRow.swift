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
    private let length: Int
    
    init(theWord: String, length: Int, letterStates: LetterRowState) {
        self.theWord = theWord
        self.length = length
        self.letterStates = LetterRowState(letterStates, length)
    }
    var body: some View {
        HStack {
            ForEach(0..<theWord.count, id: \.description) { index in
                let letterIndex = theWord.index(theWord.startIndex, offsetBy: index)
                let thisLetter = String(theWord[letterIndex])
                LetterBox(theLetter: thisLetter, theState: letterStates.stateAtIndex(index))
            }
            // TODO fill empties from the word directly...
            ForEach(theWord.count..<length, id: \.description) { _ in
                LetterBox(theLetter: "", theState: LetterBoxState.Empty)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let guessWord = "AXIO"
    LetterRow(theWord: guessWord, length: 5, letterStates: LetterRowState([.Correct, .Incorrect, .Position, .Incorrect]))
}
