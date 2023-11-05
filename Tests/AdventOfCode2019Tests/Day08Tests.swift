//
// Created by John Griffin on 12/29/21
//

import AdventOfCode2019
import Algorithms
import Parsing
import XCTest

final class Day08Tests: XCTestCase {
    func testRenderInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        let layers = input.chunks(ofCount: 25 * 6).map { layer in layer.asArray }

        let render = layers.first!.indices.map { i in
            layers.map { $0[i] }.first { p in p != 2 }!
        }
        let render2d = render.chunks(ofCount: 25).map { $0.map { $0 == 1 ? "*" : " " }.joined() }.joined(separator: "\n")
        print(render2d)
    }

    func testInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        let layers = input.chunks(ofCount: 25 * 6)
            .map { layer in layer.asArray }

        let counts = layers.map { layer in
            Dictionary(grouping: layer, by: { $0 })
        }
        let maxZeroCounts = counts.max { lhs, rhs in
            lhs[0]?.count ?? 0 > rhs[0]?.count ?? 0
        }!

        let onesByTwos = maxZeroCounts[1]!.count * maxZeroCounts[2]!.count
        XCTAssertEqual(onesByTwos, 1848)
    }

    typealias Layer = [[Int]]
}

extension Day08Tests {
    static let input = resourceURL(filename: "Day08Input.txt")!.readContents()!
    static let example = "123456789012"

    // MARK: - parser

    static let inputParser = Parse(input: Substring.self) {
        $0.chunks(ofCount: 1).map { Int($0)! }
    } with: {
        Prefix(while: \.isNumber)
        Skip { Optionally { "\n" }}
    }

    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertNotNil(input)
    }

    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(input.count, 15000)
    }
}
