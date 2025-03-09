//
//  Guesser.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/16/25.
//

import Foundation

let specialPassWord = "KUZYA"

public enum GameMode: Equatable {
    case Word
    case Phrase
}

struct GuessResult {
    var letterStates: LetterRowState
    var missingChars: Set<Character>
    
    init() {
        self.letterStates = LetterRowState()
        self.missingChars = Set<Character>()
    }
    
    init(letterStates: LetterRowState, missingChars: Set<Character>) {
        self.letterStates = letterStates
        self.missingChars = missingChars
    }
}

struct ValidateGuessParams {
    var mode: GameMode
    var rawTarget: String
    var rawGuess: String
    var guessList: [String]
    var invalidCharSet: Set<Character>
}

class Guesser {
    private var SecretWordSet: Set<String> = []
    init() {
        self.SecretWordSet = Set(EnglishSecretWords)
    }
    
    func GetLetterStates(_ rawTarget: String, _ rawGuess: String) throws -> GuessResult {
        let target = trimAndNormalize(rawTarget)
        let guess = trimAndNormalize(rawGuess)
        var missingCharSet: Set<Character> = []
        
        if guess.count == 0 {
            return GuessResult()
        }
        
        if target.count != guess.count {
            throw GuesserError.WordsDifferentLengths(targetLength: target.count, guessLength: guess.count)
        }
        
        // create an array of repeating Empty state, length same as the word length
        var ret: [LetterBoxState] = Array(repeating: LetterBoxState.Empty, count: target.count)
        
        // break the target down into an array of single strings for easy comparison, and a dictionary of counts
        // break the guess down into a string array
        // iterate over the guess array
        // if guess[i] == target[i] -> .Correct
        // if guess[i] != target[i] && the number of times that letter has already been found if less than or equal to total count in the target
        // -> .Position
        // else -> .Incorrect
        
        var targetCounts = getLetterCounts(target)
        let rawTargetCounts = getLetterCounts(target)
        var targetArray = getCharArray(target)
        var guessArray = getCharArray(guess)
        var seenDict: [Character: Int] = [:]
        
        
        // first loop through remove/mark exact matches
        for (i, guessChar) in guessArray.enumerated() {
            if guessChar == targetArray[i] {
                ret[i] = LetterBoxState.Correct
                guessArray[i] = " "
                targetArray[i] = " "
                
                targetCounts[guessChar, default: 0]  -= 1
            }
        }
        
        // then mark the out of positions and incorrects by simply counting
        for (i, guessChar) in guessArray.enumerated() {
            // how many counts of the guess letter are in the target word
            let guessHits = targetCounts[guessChar] ?? 0
            // if this letter has more instances in the guess than in the target, AND its guess position is greater than its target count
            let seenCount = seenDict[guessChar] ?? 0
            let overLimitForPosition = seenCount >= guessHits
            
            // exact matches already covered above
            if guessChar == targetArray[i] {
                continue
            } else if guessHits > 0 && !overLimitForPosition {
                ret[i] = LetterBoxState.Position
            } else {
                ret[i] = LetterBoxState.Incorrect
                // a character can be incorrect due to counts but can still exist in the target word
                // only characters that do not exist at all in the target should be adding to the missing char set
                if rawTargetCounts[guessChar, default: 0] == 0 {
                    missingCharSet.insert(guessChar)
                }
            }
            seenDict[guessChar, default: 0] += 1
        }
        
        return GuessResult(letterStates: LetterRowState(ret), missingChars: missingCharSet)
    }
    
    func GetRandomSecretWord() -> String {
        let secretWordList = EnglishSecretWords
        let randomIndex = Int.random(in: 0..<secretWordList.count)
        return secretWordList[randomIndex].uppercased()
    }
    
    func AllCorrect(_ rowState: LetterRowState) -> Bool {
        for letterState in rowState.states {
            if letterState != .Correct {
                return false
            }
        }
        return true
    }
    
    func trimAndNormalize(_ input: String) -> String {
        return input.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getLetterCounts(_ input: String) -> [Character: Int] {
        var counts: [Character: Int] = [:]
        for char in input {
            counts[char, default: 0] += 1
        }
        return counts
    }
    
    func getCharArray(_ input: String) -> [Character] {
        return Array(input)
    }
    
    func ValidateGuess(_ validateParams: ValidateGuessParams) throws -> String {
        let target = trimAndNormalize(validateParams.rawTarget)
        let guess = trimAndNormalize(validateParams.rawGuess)
        
        if target.count != guess.count {
            throw GuesserError.GuessLengthNotMatchExpected(targetLength: target.count, guessLength: guess.count)
        }
        
        if validateParams.mode == .Word {
            // not a feature in the inspired game
            //                    setAndShowMessage("Cannot use characters that are missing: \"\(invalidString)\"")
            //                    return
//            let invalidCharsInGuess: Set<Character> = validateParams.invalidCharSet.intersection(Set(guess))
//            if !invalidCharsInGuess.isEmpty {
//                let invalidArray = Array(invalidCharsInGuess)
//                let sortedInvalidChars = invalidArray.sorted()
//                let sortedInvalidStrings = sortedInvalidChars.map(String.init)
//                let joinedString = sortedInvalidStrings.joined(separator: ", ")
//                throw GuesserError.GuessHasInvalidChars(guess: guess, invalidCharString: joinedString)
//            }
            
            // set is in lowercase
            if !self.SecretWordSet.contains(guess.lowercased()) {
                throw GuesserError.GuessNotInWordList(guess: guess)
            }
        }
        
        let guessSet = Set(validateParams.guessList)
        if guessSet.contains(guess) {
            throw GuesserError.GuessAlreadyExists
        }
        
        return guess
    }
    
    func IsSpecialPassword(_ arg: String) -> Bool {
        return trimAndNormalize(arg) == specialPassWord
    }
}

