//
//  GameView.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/9/25.
//

import SwiftUI

struct GameView: View {
    @State var secretWordList: [String]
    @State private var currentGuess = ""
    @State private var guesses: [String] = []
    @State var gameFinished: Bool = false
    @State var message: String = "placeholder message"
    @State var turn: Int = 1
    @State var showMessage: Bool = false

    var GuesserLogic: Guesser = Guesser()
    var turnLimit: Int
    
    init(secretWordList: [String]) {
        self.secretWordList = secretWordList
        self.turnLimit = secretWordList.count
    }
    
    var body: some View {
        VStack {
            LetterGrid(secretWordList: secretWordList, guessList: guesses)
            HStack{
                TextField("GUESS", text: $currentGuess, prompt: Text("GUESS"))
                    .onSubmit {
                        handleTurn(currentGuess, turn - 1)
                        currentGuess = ""
                    }
                    .disabled(gameFinished)
                    .disableAutocorrection(true)
                    .autocapitalization(.allCharacters)
                    .foregroundColor(.black)
                    .fontDesign(.monospaced)
                    .fontDesign(.rounded)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Text("\(message)")
                .opacity(showMessage ? 1 : 0)
                .font(.largeTitle)
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
    }
    
    func handleTurn(_ guessWord: String, _ turnIndex: Int) {
        clearMessage()
        do {
            try GuesserLogic.ValidateGuess(secretWordList[turnIndex], guessWord)
        } catch GuesserError.GuessLengthNotMatchExpected(let expectedLength, let guessLength) {
            setAndShowMessage("Your guess (\(guessLength)) must be \(expectedLength) characters long.")
            return
        } catch {
            setAndShowMessage(String(describing: error))
            return
        }
        
        guesses.append(guessWord)
        let rowStateForCurrentGuess = getRowState(secretWord: secretWordList[turnIndex], guessWord: guessWord)
        
        let win = GuesserLogic.AllCorrect(rowStateForCurrentGuess)
        if win {
            gameFinished = true
            setAndShowMessage("😎")
        }
        
        turn+=1
        if turn > turnLimit {
            gameFinished = true
            setAndShowMessage("🤣")
        }
    }
    
    func clearMessage() {
        self.showMessage = false
        self.message = ""
        // what's this?
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            self.showMessage = false
        //        }
    }
    
    func setAndShowMessage(_ message: String) {
        self.showMessage = true
        self.message = message
    }
    
    
    func getRowState(secretWord: String, guessWord: String) -> LetterRowState {
        let guesser = Guesser()
        var result = LetterRowState()
        do {
            result = try guesser.GetLetterStates(secretWord, guessWord)
        } catch {
            message = String(describing: error)
        }
        return result
    }
}

#Preview {
    GameView(secretWordList: Array(repeating: "AXIOM", count: 6))
}
