//
//  ContentView.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/8/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showGame: Bool = false
    @State private var isGameFinished: Bool = false
    @State private var startGameButtonText: String = "Start Game"
    var body: some View {
        VStack{
            if !showGame {
                Text("AXIOM")
                    .font(.system(size: 48, design: .default))
                    .foregroundColor(.white)
                    .fontDesign(.rounded)
                    .fontDesign(.monospaced)
                Button("\(startGameButtonText)"){
                    newGame()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.top)
            }
            
            if showGame {
                let GuesserLogic: Guesser = Guesser()
                let secretWord = GuesserLogic.GetRandomSecretWord()
                GameView(started: true, secretWordList: Array(repeating: secretWord, count: 6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
    }
    
    func newGame() {
        self.showGame = true
    }
}

#Preview {
    ContentView()
}
