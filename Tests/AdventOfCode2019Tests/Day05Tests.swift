//
// Created by John Griffin on 11/5/23
//

import AdventOfCode2019
import XCTest

final class Day05Tests: XCTestCase {
    func testExample() throws {
        let program: [Int] = [1002, 4, 3, 4, 33]
        let computer = try IntcodeComputer.run(program: program)
        XCTAssertEqual(computer.result, 1002)
    }

    static let input = resourceURL(filename: "Day05Input.txt")!.readContents()!

    func testInputPart1() throws {
        let program: [Int] = try IntcodeComputer.programParser.parse(Self.input)
        var input = [1].makeIterator()

        let computer = try IntcodeComputer.run(
            program: program,
            input: { input.next()! }
        )

        XCTAssertTrue(computer.output.dropLast().allSatisfy { $0 == 0 })
        let diagnosticCode = computer.output.last
        XCTAssertEqual(diagnosticCode, 7692125)
    }

    func testInputPart2Input() throws {
        let program: [Int] = try IntcodeComputer.programParser.parse(Self.input)
        var input = [5].makeIterator()

        let computer = try IntcodeComputer.run(
            program: program,
            input: { input.next()! }
        )

        XCTAssertTrue(computer.output.dropLast().allSatisfy { $0 == 0 })
        let diagnosticCode = computer.output.last
        XCTAssertEqual(diagnosticCode, 14340395)
    }
}
