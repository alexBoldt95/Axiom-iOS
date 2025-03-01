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
    @State var message: String = "debug message"
    @State var turn: Int = 1
    @State var showMessage: Bool = false
    @State var showGrid: Bool
    @State var newGameButtonText: String = "New Game"
    @FocusState var guessFieldIsFocused: Bool
    
    var GuesserLogic: Guesser = Guesser()
    var turnLimit: Int
    
    init(started: Bool, secretWordList: [String]) {
        self.secretWordList = secretWordList
        self.turnLimit = secretWordList.count
        self.showGrid = started
    }
    
    var body: some View {
        VStack {
            if showGrid {
                VStack {
                    LetterGrid(secretWordList: secretWordList, guessList: guesses)
                    HStack{
                        TextField("GUESS", text: $currentGuess, prompt: Text("GUESS"))
                            .focused($guessFieldIsFocused) // Bind focus state
                            .onSubmit {
                                handleTurn(currentGuess, turn - 1)
                                currentGuess = ""
                                guessFieldIsFocused = true
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
            }
            if !showGrid || gameFinished {
                Button("\(newGameButtonText)"){
                    newGame()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding(.top)
            }
        }
    }
    
    func newGame() {
        self.showGrid = true
        self.gameFinished = false
        self.guesses.removeAll()
        self.turn = 1
        clearMessage()
        
        let secretWord = GuesserLogic.GetRandomSecretWord()
        secretWordList = Array(repeating: secretWord, count: turnLimit)
    }
    
    func handleTurn(_ guessWord: String, _ turnIndex: Int) {
        clearMessage()
        do {
            try GuesserLogic.ValidateGuess(secretWordList[turnIndex], guessWord)
        } catch GuesserError.GuessLengthNotMatchExpected(let expectedLength, let guessLength) {
            setAndShowMessage("Your guess (\(guessLength)) must be \(expectedLength) characters long.")
            return
        } catch GuesserError.GuessNotInWordList(_) {
            setAndShowMessage("Not in word list")
            return
        } catch {
            setAndShowMessage(String(describing: error))
            return
        }
        
        guesses.append(guessWord)
        let rowStateForCurrentGuess = getRowState(secretWord: secretWordList[turnIndex], guessWord: guessWord)
        
        // win
        let win = GuesserLogic.AllCorrect(rowStateForCurrentGuess)
        if win {
            gameFinished = true
            setAndShowMessage("🔥🔥🔥")
            newGameButtonText = "Play Again?"
            return
        }
        
        turn+=1
        // loss
        if turn > turnLimit {
            gameFinished = true
            setAndShowMessage("🤣 the word was '\(secretWordList[0])'")
            newGameButtonText = "Try Again?"
            return
        }
    }
    
    func clearMessage() {
        self.showMessage = false
        self.message = ""
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

struct GameView_Preview: View {
    var body: some View {
        let GuesserLogic: Guesser = Guesser()
        let secretWord = GuesserLogic.GetRandomSecretWord()
        GameView(started: true, secretWordList: Array(repeating: secretWord, count: 6))
    }
}

#Preview {
    GameView_Preview()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
}
