//
//  GameView.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/9/25.
//

import SwiftUI

struct GameView: View {
    @State var secretWord: String
    @State private var currentGuess = ""
     @State private var guesses: [String] = [] //needs to be Observable??
    var body: some View {
        VStack {
            LetterGrid(secretWord: secretWord, guessList: guesses)
            TextField("Guess", text: $currentGuess)
                .onSubmit {
                    guesses.append(currentGuess)
                    currentGuess = ""
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
    }
}

#Preview {
    GameView(secretWord: "AXIOM")
}
