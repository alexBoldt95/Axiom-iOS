//
//  LetterRow.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterRow: View {
    let theWord: String
    private let rowLength: Int = 5
    var body: some View {
        HStack {
            ForEach(0..<theWord.count, id: \.description) { index in
                let letterIndex = theWord.index(theWord.startIndex, offsetBy: index)
                let thisLetter = String(theWord[letterIndex])
                LetterBox(theLetter: thisLetter)
            }
            // TODO fill empties from the word directly...
            ForEach(theWord.count..<rowLength, id: \.description) { _ in
                LetterBox(theLetter: "")
            }
        }.padding()
    }
}

#Preview {
    let previewWord = "AXIOM"
    LetterRow(theWord: previewWord)
}
