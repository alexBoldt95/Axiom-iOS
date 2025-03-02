//
//  Errors.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/16/25.
//

import Foundation

enum GuesserError: Error, Equatable {
    case WordsDifferentLengths(targetLength: Int, guessLength: Int)
    case GuessLengthNotMatchExpected(targetLength: Int, guessLength: Int)
    case GuessNotInWordList(guess: String)
    case GuessAlreadyExists
    case GuessHasInvalidChars(guess: String, invalidCharString: String)
}
