//
//  Axiom_iOSTests.swift
//  Axiom-iOSTests
//
//  Created by Alexander Boldt on 2/8/25.
//

import Testing
@testable import Axiom_iOS

struct Axiom_iOSTests {
    
    @Suite("Guesser tests") struct GuesserTests {
        @Test func differentLength() async throws {
            let guesser = Guesser()
            #expect(throws: GuesserError.WordsDifferentLengths(targetLength: 26, guessLength: 25)) {
                try guesser.GetLetterStates("abcdefghijklmnopqrstuvwxyz", "abcdefghijklmnopqrstuvwxy")
            }
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
            
        }
        
        @Test("All of the letters are guessed correctly") func allCorrect() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AXIOM", "axiom")
            let expected: [LetterBoxState] = [.Correct, .Correct, .Correct, .Correct, .Correct]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("All incorrect") func allIncorrect() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AXIOM", "BCDEF")
            let expected: [LetterBoxState] = [.Incorrect, .Incorrect, .Incorrect, .Incorrect, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("All of the letters are out of position") func allOutOfPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AXIOM", "XIOMA")
            let expected: [LetterBoxState] = [.Position, .Position, .Position, .Position, .Position]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("One letter out of position and one is wrong") func outOfPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AAAAB", "BAAAC")
            let expected: [LetterBoxState] = [.Position, .Correct, .Correct, .Correct, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("Two letters are switched in position") func switchPositions() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AAAAB", "BAAAA")
            let expected: [LetterBoxState] = [.Position, .Correct, .Correct, .Correct, .Position]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("Over limit on corrects") func overCorrects() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("BBAAA", "BBBBB")
            let expected: [LetterBoxState] = [.Correct, .Correct, .Incorrect, .Incorrect, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("Over limit on positions") func overPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("BBAAA", "XXBBB")
            let expected: [LetterBoxState] = [.Incorrect, .Incorrect, .Position, .Position, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("Incorrect Letter before Correct, should be Incorrect") func incorrectBeforeCorrect() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("XB", "BB")
            let expected: [LetterBoxState] = [.Incorrect, .Correct]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
        
        @Test("Game Simulation") func gameSim() async throws {
            let guesser = Guesser()
            var result = try guesser.GetLetterStates("AXIOM", "FAIRY")
            var expected: [LetterBoxState] = [.Incorrect, .Position, .Correct, .Incorrect, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
            
            result = try guesser.GetLetterStates("AXIOM", "ALIKE")
            expected = [.Correct, .Incorrect, .Correct, .Incorrect, .Incorrect]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
            
            result = try guesser.GetLetterStates("AXIOM", "AXIOM")
            expected = [.Correct, .Correct, .Correct, .Correct, .Correct]
            for (i, res) in result.enumerated() {
                #expect(res == expected[i])
            }
        }
    }
}
