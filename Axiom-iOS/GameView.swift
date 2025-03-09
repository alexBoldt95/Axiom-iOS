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
    var SpecialDesign: Bool?
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
    @State var SpecialDesign: Bool
    @State var fontDesign: Font.Design
    @State var backgroundColor: Color
    @FocusState var guessFieldIsFocused: Bool
    var GuesserLogic: Guesser = Guesser()
    @State var turnLimit: Int
    @State var winMessage = "🔥🔥🔥"
    @State var loseMessage = "🤣 the word was"
    
    init(gameParams: GameParams) {
        self.secretWordList = gameParams.SecretWordList
        self.turnLimit = gameParams.SecretWordList.count
        self.showGrid = gameParams.Started
        self.Mode = gameParams.Mode
        let inSpecialDesign = gameParams.SpecialDesign ?? false
        self.SpecialDesign = inSpecialDesign
        let gameDesign = GameView.getDesign(inSpecialDesign)
        self.fontDesign = gameDesign.fontDesign
        self.backgroundColor = gameDesign.backgroundColor
    }
    
    var body: some View {
        VStack {
            if showGrid {
                VStack {
                    LetterGrid(secretWordList: self.secretWordList, guessList: self.guessList, fontDesign: self.fontDesign)
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
                            .fontDesign(self.fontDesign)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.backgroundColor)
        .tint(.white)
    }
        
    
    func newGame() {
        if self.Mode == .Phrase {
            newPhraseGame()
        } else {
            newWordGame()
        }
    }
    
    func newWordGame() {
        self.setDesign(false)
        self.Mode = .Word
        self.showGrid = true
        self.gameFinished = false
        self.guessList.removeAll()
        self.turn = 1
        clearMessage()
        
        let secretWord = GuesserLogic.GetRandomSecretWord()
        secretWordList = Array(repeating: secretWord, count: turnLimit)
    }
    
    func newPhraseGame() {
        self.setDesign(false)
        self.Mode = .Phrase
        self.showGrid = true
        self.gameFinished = false
        self.guessList.removeAll()
        self.turn = 1
        self.turnLimit = secretWordList.count
        clearMessage()
        
        // do not create new phrases for now...
    }
    
    func newSpecialGame() {
        newPhraseGame()
        self.setDesign(true)
        self.SpecialDesign = true
        self.secretWordList = ["will", "you", "marry", "me?"]
        self.turnLimit = secretWordList.count
        self.winMessage = "❤️❤️❤️"
    }
    
    private static func getDesign(_ isSpecialDesign: Bool) -> (fontDesign: Font.Design, backgroundColor: Color) {
        if isSpecialDesign {
            return (.serif, .specialBackground)
        }
        return (.rounded, .appBackground)
    }
    
    func setDesign(_ isSpecialDesign: Bool) {
        let design = GameView.getDesign(isSpecialDesign)
        self.fontDesign = design.fontDesign
        self.backgroundColor = design.backgroundColor
    }
    
    func handleTurn(_ guessWord: String, _ turnIndex: Int) {
        clearMessage()
        if GuesserLogic.IsSpecialPassword(guessWord) {
            newSpecialGame()
            return
        }
        var cleanGuessWord: String = ""
        do {
            let validateGuessParams = ValidateGuessParams(mode: self.Mode,
                                                          rawTarget: secretWordList[turnIndex],
                                                          rawGuess: guessWord,
                                                          guessList: self.guessList,
                                                          invalidCharSet: self.missingCharSet)
            cleanGuessWord =  try GuesserLogic.ValidateGuess(validateGuessParams)
        } catch GuesserError.GuessLengthNotMatchExpected(let expectedLength, let guessLength) {
            setAndShowMessage("Your guess length (\(guessLength)) must be \(expectedLength) characters long.")
            return
        } catch GuesserError.GuessNotInWordList(_) {
            setAndShowMessage("Not in word list")
            return
        } catch GuesserError.GuessAlreadyExists {
            setAndShowMessage("Already guessed")
            return
        } catch {
            setAndShowMessage(String(describing: error))
            return
        }
        
        // in Phrase Mode, each line is an individual word
        // and must be correct before advancing
        if self.Mode == .Phrase {
            phraseModeTurn(cleanGuessWord, turnIndex)
        } else {
            wordModeTurn(cleanGuessWord, turnIndex)
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
            setAndShowMessage(self.winMessage)
            newGameButtonText = "Play Again?"
            return
        }
        
        turn+=1
        // loss
        if turn > turnLimit {
            gameFinished = true
            setAndShowMessage(loseMessage + " '\(secretWordList[0])'")
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
                setAndShowMessage(self.winMessage)
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

struct SpecialMode_Preview: View {
    var body: some View {
        let secretPhrase = ["will", "you", "marry", "me?"]
        let gameParams = GameParams(Mode: .Phrase, Started: true, SecretWordList: secretPhrase, SpecialDesign: true)
        GameView(gameParams: gameParams)
    }
}

#Preview {
    //    Debug_Preview()
        WordMode_Preview()
    //    PhraseMode_Preiew()
//    SpecialMode_Preview()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.app)
//        .tint(.white)
}
