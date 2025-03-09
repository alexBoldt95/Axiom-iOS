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
    var fontDesign: Font.Design = .rounded
    
    init(theWord: String, length: Int, letterStates: LetterRowState, fontDesign: Font.Design = .rounded) {
        self.theWord = theWord
        self.length = length
        self.letterStates = LetterRowState(letterStates, length)
        self.fontDesign = fontDesign
    }
    var body: some View {
        HStack {
            Spacer()
//                .border(.orange)
            ForEach(0..<theWord.count, id: \.description) { index in
                let letterIndex = theWord.index(theWord.startIndex, offsetBy: index)
                let thisLetter = String(theWord[letterIndex])
                LetterBox(theLetter: thisLetter, theState: letterStates.stateAtIndex(index), fontDesign: self.fontDesign)
            }
//            .border(.orange)
            // TODO fill empties from the word directly...
            ForEach(theWord.count..<length, id: \.description) { _ in
                LetterBox(theLetter: "", theState: LetterBoxState.Empty, fontDesign: self.fontDesign)
            }
            Spacer()
//                .border(.orange)
        }
        .padding(.horizontal)
    }
}

#Preview {
    let guessWord = "AX"
    LetterRow(theWord: guessWord, length: 2, letterStates: LetterRowState([.Correct, .Incorrect]), fontDesign: Font.Design.serif)
}
