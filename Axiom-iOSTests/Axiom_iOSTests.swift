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
        func assertLengthAndCharsOfSet(_ set: Set<Character>, _ expectedLength: Int, _ expectedChars: Set<Character>) {
            #expect(set.count == expectedLength)
            #expect(set == expectedChars)
        }
        
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
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Correct, .Correct, .Correct, .Correct, .Correct]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("All incorrect") func allIncorrect() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AXIOM", "BCDEF")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Incorrect, .Incorrect, .Incorrect, .Incorrect, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            
            assertLengthAndCharsOfSet(result.missingChars, 5, ["B","C","D","E","F"])
        }
        
        @Test("All of the letters are out of position") func allOutOfPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AXIOM", "XIOMA")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Position, .Position, .Position, .Position, .Position]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("One letter out of position and one is wrong") func outOfPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AAAAB", "BAAAC")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Position, .Correct, .Correct, .Correct, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 1, ["C"])
        }
        
        @Test("Two letters are switched in position") func switchPositions() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("AAAAB", "BAAAA")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Position, .Correct, .Correct, .Correct, .Position]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("Over limit on corrects") func overCorrects() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("BBAAA", "BBBBB")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Correct, .Correct, .Incorrect, .Incorrect, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("Over limit on positions") func overPosition() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("BBAAA", "XXBBB")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Incorrect, .Incorrect, .Position, .Position, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 1, ["X"])
        }
        
        @Test("Incorrect Letter before Correct, should be Incorrect") func incorrectBeforeCorrect() async throws {
            let guesser = Guesser()
            let result = try guesser.GetLetterStates("XB", "BB")
            let states = result.letterStates.States()
            let expected: [LetterBoxState] = [.Incorrect, .Correct]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("Game Simulation") func gameSim() async throws {
            let guesser = Guesser()
            var result = try guesser.GetLetterStates("AXIOM", "FAIRY")
            var states = result.letterStates.States()
            
            var expected: [LetterBoxState] = [.Incorrect, .Position, .Correct, .Incorrect, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 3, ["F", "R", "Y"])
            
            result = try guesser.GetLetterStates("AXIOM", "ALIKE")
            states = result.letterStates.States()
            expected = [.Correct, .Incorrect, .Correct, .Incorrect, .Incorrect]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 3, ["L", "K", "E"])
            
            result = try guesser.GetLetterStates("AXIOM", "AXIOM")
            states = result.letterStates.States()
            expected = [.Correct, .Correct, .Correct, .Correct, .Correct]
            for (i, res) in states.enumerated() {
                #expect(res == expected[i])
            }
            assertLengthAndCharsOfSet(result.missingChars, 0, [])
        }
        
        @Test("Special Password") func IsSpecialPassword() async throws {
            let guesser = Guesser()
            let falseResult = guesser.IsSpecialPassword("abcde")
            #expect(!falseResult)
            let trueResult = guesser.IsSpecialPassword("kuzYA")
            #expect(trueResult)
        }
    }
}
