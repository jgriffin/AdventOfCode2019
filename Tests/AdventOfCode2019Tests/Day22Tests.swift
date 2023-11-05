//
// Created by John Griffin on 12/31/21
//

import AdventOfCode2019
import Parsing
import XCTest

final class Day22Tests: XCTestCase {
    func testPlayToWinnerRecursiveInput() throws {
        let state = try Self.gameStateP.parse(Self.input)
        let score = GameState.playToWinnerRecursive(state)
        XCTAssertTrue(score.p1 > score.p2)
        XCTAssertEqual(max(score.p1, score.p2), 36515)
    }

    func testPlayToWinnerRecursiveExample() throws {
        let state = try Self.gameStateP.parse(Self.example)
        let score = GameState.playToWinnerRecursive(state)
        XCTAssertTrue(score.p1 < score.p2)
        XCTAssertEqual(max(score.p1, score.p2), 291)
    }

    func testPlayToWinnerInput() throws {
        var state = try Self.gameStateP.parse(Self.input)
        let score = state.playToWinner()
        XCTAssertTrue(score.p1 > score.p2)
        XCTAssertEqual(max(score.p1, score.p2), 32824)
    }

    func testPlayToWinnerExample() throws {
        var state = try Self.gameStateP.parse(Self.example)
        let score = state.playToWinner()
        XCTAssertTrue(score.p1 < score.p2)
        XCTAssertEqual(max(score.p1, score.p2), 306)
    }
}

extension Day22Tests {
    struct GameState: Hashable, CustomStringConvertible {
        var p1Cards: [Int]
        var p2Cards: [Int]

        typealias Score = (p1: Int, p2: Int)
        typealias PlayToWinner = (GameState) -> Score

        static let playToWinnerRecursive: PlayToWinner = memoizeRecursive { state, recurse in
            var copy = state
            return copy.playToWinner(recurse)
        }

        mutating func playToWinner(_ recurse: PlayToWinner) -> Score {
            var prev = Set<GameState>()

            while !p1Cards.isEmpty, !p2Cards.isEmpty {
                if prev.contains(self) {
                    return (1, 0)
                }
                prev.insert(self)

                playHandRecusive(recurse)
            }

            return winningScore
        }

        mutating func playHandRecusive(_ recurse: PlayToWinner) {
            let c1 = p1Cards.removeFirst()
            let c2 = p2Cards.removeFirst()

            guard p1Cards.count >= c1, p2Cards.count >= c2 else {
                if c1 > c2 {
                    p1Cards.append(contentsOf: [c1, c2])
                } else {
                    p2Cards.append(contentsOf: [c2, c1])
                }
                return
            }

            let subGame = GameState(p1Cards: p1Cards.prefix(c1).asArray,
                                    p2Cards: p2Cards.prefix(c2).asArray)
            let score = recurse(subGame)
            if score.p1 > score.p2 {
                p1Cards.append(contentsOf: [c1, c2])
            } else {
                p2Cards.append(contentsOf: [c2, c1])
            }
        }

        mutating func playToWinner() -> (p1: Int, p2: Int) {
            while !p1Cards.isEmpty, !p2Cards.isEmpty {
                playHand()
            }
            return winningScore
        }

        mutating func playHand() {
            let c1 = p1Cards.removeFirst()
            let c2 = p2Cards.removeFirst()

            if c1 > c2 {
                p1Cards.append(contentsOf: [c1, c2])
            } else {
                p2Cards.append(contentsOf: [c2, c1])
            }
        }

        var winningScore: (p1: Int, p2: Int) {
            (p1: score(p1Cards), p2: score(p2Cards))
        }

        func score(_ cards: [Int]) -> Int {
            zip(1..., cards.reversed()).reduce(0) { result, ic in result + ic.0 * ic.1 }
        }

        var description: String {
            p1Cards.map { "\($0)" }.joined(separator: ",") + "  -  " +
                p2Cards.map { "\($0)" }.joined(separator: ",")
        }
    }
}

extension Day22Tests {
    static let input = resourceURL(filename: "Day22Input.txt")!.readContents()!

    static var example: String {
        """
        Player 1:
        9
        2
        6
        3
        1

        Player 2:
        5
        8
        4
        7
        10
        """
    }

    // MARK: - parser

//    static let playerNameP = OneOf {
//        "Player 1:\n"
//        "Player 2:\n"
//    }
//
//    static let playerP = Parse {
//        Skip { playerNameP }
//        Many {
//            Int.parser()
//        } separator: {
//            "\n"
//        }
//    }

    static let gameStateP = Parse(GameState.init) {
        "Player 1:\n"
        Many { Int.parser() } separator: { "\n" }
        "\n\n"
        "Player 2:\n"
        Many { Int.parser() } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() throws {
        let state = try Self.gameStateP.parse(Self.example)
        XCTAssertEqual(state.p1Cards.count, 5)
        XCTAssertEqual(state.p2Cards.count, 5)
    }

    func testParseInput() throws {
        let state = try Self.gameStateP.parse(Self.input)
        XCTAssertEqual(state.p1Cards.count, 25)
        XCTAssertEqual(state.p2Cards.count, 25)
    }
}
