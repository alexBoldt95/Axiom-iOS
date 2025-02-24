//
//  Errors.swift
//  Axiom-iOS
//
//  Created by Alexander Boldt on 2/16/25.
//

import Foundation

enum GuesserError: Error, Equatable {
    case WordsDifferentLengths(targetLength: Int, guessLength: Int)
}
