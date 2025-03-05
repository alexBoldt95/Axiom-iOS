//
//  GameView.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/9/25.
//

import SwiftUI

struct GameParams {
    var Mode: GameMode
    var Started : Bool
    var SecretWordList: [String]
}

struct GameView: View {
    @State var secretWordList: [String]
    @State private var currentGuess = ""
    @State private var guessList: [String] = []
    @State var gameFinished: Bool = false
    @State var message: String = "debug message"
    @State var turn: Int = 1
    @State var showMessage: Bool = false
    @State var showGrid: Bool
    @State var newGameButtonText: String = "New Game"
    @State var missingCharSet: Set<Character> = []
    @State var Mode: GameMode
    @FocusState var guessFieldIsFocused: Bool
    
    var GuesserLogic: Guesser = Guesser()
    var turnLimit: Int
    
    init(gameParams: GameParams) {
        self.secretWordList = gameParams.SecretWordList
        self.turnLimit = gameParams.SecretWordList.count
        self.showGrid = gameParams.Started
        self.Mode = gameParams.Mode
    }
    
    var body: some View {
        VStack {
            if showGrid {
                VStack {
                    LetterGrid(secretWordList: secretWordList, guessList: guessList)
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
                            .foregroundColor(.white)
                            .fontDesign(.monospaced)
                            .fontDesign(.rounded)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Text("\(message)")
                        .opacity(showMessage ? 1 : 0)
                        .font(.largeTitle)
                        .padding()
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
        if self.Mode == .Phrase {
            newPhraseGame()
        } else {
            newWordGame()
        }
    }
    
    func newWordGame() {
        self.showGrid = true
        self.gameFinished = false
        self.guessList.removeAll()
        self.turn = 1
        clearMessage()
        
        let secretWord = GuesserLogic.GetRandomSecretWord()
        secretWordList = Array(repeating: secretWord, count: turnLimit)
    }
    
    func newPhraseGame() {
        self.showGrid = true
        self.gameFinished = false
        self.guessList.removeAll()
        self.turn = 1
        clearMessage()
        
        // do not create new phrases for now...
    }
    
    func handleTurn(_ guessWord: String, _ turnIndex: Int) {
        clearMessage()
        do {
            let validateGuessParams = ValidateGuessParams(mode: self.Mode,
                                                          rawTarget: secretWordList[turnIndex],
                                                          rawGuess: guessWord,
                                                          guessList: self.guessList,
                                                          invalidCharSet: self.missingCharSet)
            try GuesserLogic.ValidateGuess(validateGuessParams)
        } catch GuesserError.GuessLengthNotMatchExpected(let expectedLength, let guessLength) {
            setAndShowMessage("Your guess length (\(guessLength)) must be \(expectedLength) characters long.")
            return
        } catch GuesserError.GuessNotInWordList(_) {
            setAndShowMessage("Not in word list")
            return
        } catch GuesserError.GuessHasInvalidChars(guess: _, invalidCharString: _) {
            // not a feature in the inspired game
            //                    setAndShowMessage("Cannot use characters that are missing: \"\(invalidString)\"")
            //                    return
        }
        catch GuesserError.GuessAlreadyExists {
            setAndShowMessage("Already guessed")
            return
        } catch {
            setAndShowMessage(String(describing: error))
            return
        }
        
        // in Phrase Mode, each line is an individual word
        // and must be correct before advancing
        if self.Mode == .Phrase {
            phraseModeTurn(guessWord, turnIndex)
        } else {
            wordModeTurn(guessWord, turnIndex)
        }
    }
    
    func wordModeTurn(_ guessWord: String, _ turnIndex: Int) {
        guessList.append(guessWord)
        let rowResultForCurrentGuess = getRowResult(secretWord: secretWordList[turnIndex], guessWord: guessWord)
        
        self.missingCharSet = self.missingCharSet.union(rowResultForCurrentGuess.missingChars)
        
        // win
        let win = GuesserLogic.AllCorrect(rowResultForCurrentGuess.letterStates)
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
    
    func phraseModeTurn(_ guessWord: String, _ turnIndex: Int) {
        // if the list is currently the same length as the turn, then replace the last element with the current guess
        // this is a player trying again
        // otherwise append
        if guessList.count == turn {
            guessList[turn-1] = guessWord
        } else {
            guessList.append(guessWord)
        }
        
        let rowResultForCurrentGuess = getRowResult(secretWord: secretWordList[turnIndex], guessWord: guessWord)
        
        let correct = GuesserLogic.AllCorrect(rowResultForCurrentGuess.letterStates)
        
        if correct {
            let win = turn >= turnLimit
            if win {
                gameFinished = true
                setAndShowMessage("🔥🔥🔥")
                newGameButtonText = "Play Again?"
                return
            }
            turn+=1
            return
        }
        
        // just try again
        setAndShowMessage("Try again!")
        return
    }
    
    func clearMessage() {
        self.showMessage = false
        self.message = ""
    }
    
    func setAndShowMessage(_ message: String) {
        self.showMessage = true
        self.message = message
    }
    
    
    func getRowResult(secretWord: String, guessWord: String) -> GuessResult {
        let guesser = Guesser()
        var result = GuessResult()
        do {
            result = try guesser.GetLetterStates(secretWord, guessWord)
        } catch {
            message = String(describing: error)
        }
        return result
    }
}

struct PhraseMode_Preiew: View {
    var body: some View {
        let secretPhrase = ["four", "two", "three", "one"]
        let gameParams = GameParams(Mode: .Phrase, Started: true, SecretWordList: secretPhrase)
        GameView(gameParams: gameParams)
    }
}

struct WordMode_Preview: View {
    var body: some View {
        let GuesserLogic: Guesser = Guesser()
                let secretWord = GuesserLogic.GetRandomSecretWord()
                let secretWordList = Array(repeating: secretWord, count: 6)
        let gameParams = GameParams(Mode: .Word, Started: true, SecretWordList: secretWordList)
        GameView(gameParams: gameParams)
    }
}

struct Debug_Preview: View {
    var body: some View {
                let secretWord = "AXIOM"
                let secretWordList = Array(repeating: secretWord, count: 6)
        let gameParams = GameParams(Mode: .Word, Started: true, SecretWordList: secretWordList)
        GameView(gameParams: gameParams)
    }
}

#Preview {
//    Debug_Preview()
//    WordMode_Preview()
    PhraseMode_Preiew()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .tint(.white)
}
