//
//  Guesser.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/16/25.
//

import Foundation

class Guesser {
    private var SecretWordSet: Set<String> = []
    init() {
        self.SecretWordSet = Set(SecretWords)
    }
    
    func GetLetterStates(_ rawTarget: String, _ rawGuess: String) throws -> LetterRowState {
        
        let target = trimAndNormalize(rawTarget)
        let guess = trimAndNormalize(rawGuess)
        
        if guess.count == 0 {
            return LetterRowState()
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
            }
            seenDict[guessChar, default: 0] += 1
        }
        
        return LetterRowState(ret)
    }
    
    func GetRandomSecretWord() -> String {
        let randomIndex = Int.random(in: 0..<SecretWords.count)
        return SecretWords[randomIndex].uppercased()
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
    
    func ValidateGuess(_ rawTarget: String, _ rawGuess: String) throws {
        let target = trimAndNormalize(rawTarget)
        let guess = trimAndNormalize(rawGuess)
        
        if target.count != guess.count {
            throw GuesserError.GuessLengthNotMatchExpected(targetLength: target.count, guessLength: guess.count)
        }
        
        // set is in lowercase
        if !self.SecretWordSet.contains(guess.lowercased()) {
            throw GuesserError.GuessNotInWordList(guess: guess)
        }
    }
    
}

