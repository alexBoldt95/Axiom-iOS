//
//  LetterGrid.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct LetterGrid: View {
    private let numRows: Int
    let secretWordList: [String]
    var guessList: [String]
    private var guessStates: [LetterRowState]
    var fontDesign: Font.Design = .rounded
    
    init(secretWordList: [String], guessList: [String], fontDesign: Font.Design = .rounded) {
        self.secretWordList = secretWordList
        self.numRows = secretWordList.count
        self.fontDesign = fontDesign
        
        print("letter grid font degign: \(fontDesign)")

        
        var myGuessList = guessList
        // fill out rest with empties
        for _ in guessList.count..<numRows {
            myGuessList.append("")
        }
        
        self.guessList = myGuessList
        let guesser = Guesser()
        var myRowStates: [LetterRowState] = []
        // MUST INITIALIZE ALL PROPERTIES WITHIN INIT(), CANNOT FIND A WAY TO USE A HELPER FUNC...
        // TODO pull this logic up to caller and pass the RowStates into this view
        for i in 0..<numRows {
            do {
                let result = try guesser.GetLetterStates(secretWordList[i], myGuessList[i])
                myRowStates.append(result.letterStates)
            } catch {
                myRowStates.append(LetterRowState.allError(myGuessList[i].count))
            }
        }
        self.guessStates = myRowStates
    }
    
    
    var body: some View {
        VStack {
            ForEach(0..<numRows, id: \.description) { guessIndex in
                LetterRow(theWord: guessList[guessIndex], length: secretWordList[guessIndex].count, letterStates: guessStates[guessIndex], fontDesign: self.fontDesign)
            }
        }
    }
}

#Preview {
    LetterGrid(secretWordList:["testa", "testb", "testc", "abcde"], guessList: ["testa", "testa", "btest"], fontDesign: Font.Design.serif)
}
