//
//  File.swift
//
//
//  Created by John Griffin on 12/30/19.
//

import Foundation
import XCTest

// You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.
//
// However, they do remember a few key facts about the password:
//
// It is a six-digit number.
// The value is within the range given in your puzzle input.
// Two adjacent digits are the same (like 22 in 122345).
// Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
// Other than the range rule, the following are true:
//
// 111111 meets these criteria (double 11, never decreases).
// 223450 does not meet these criteria (decreasing pair of digits 50).
// 123789 does not meet these criteria (no double).
// How many different passwords within the range given in your puzzle input meet these criteria?

final class Day04Tests: XCTestCase {
    func testExamples() {
        let tests: [(n: Int, check: Bool)] = [
            (n: 111_111, check: true),
            (n: 223_450, check: false),
            (n: 123_789, check: false),
        ]

        tests.forEach { test in
            let result = meetsRules(test.n)
            XCTAssertEqual(result, test.check)
        }
    }

    func testFindPasswordsInRange() {
        let passwords = (372_304 ... 847_060).filter(meetsRules)
        XCTAssertEqual(passwords.count, 475)
    }

    func testExamplesExcluding() {
        let tests: [(n: Int, check: Bool)] = [
            (n: 112_233, check: true),
            (n: 123_444, check: false),
            (n: 111_122, check: true),
        ]

        tests.forEach { test in
            let result = meetsRulesExcludingGroups(test.n)
            XCTAssertEqual(result, test.check)
        }
    }

    func testFindPasswordsInRangeExcludingRules() {
        let passwords = (372_304 ... 847_060).filter(meetsRulesExcludingGroups)
        XCTAssertEqual(passwords.count, 297)
    }

    func meetsRules(_ n: Int) -> Bool {
        let digits = digitsOf(n)
        guard zip(digits, digits.dropFirst()).allSatisfy({ $0 <= $1 }) else { return false }
        guard zip(digits, digits.dropFirst()).contains(where: { $0 == $1 }) else { return false }
        return true
    }

    func meetsRulesExcludingGroups(_ n: Int) -> Bool {
        let digits = digitsOf(n)
        guard zip(digits, digits.dropFirst()).allSatisfy({ $0 <= $1 }) else {
            return false
        }

        var hasAdjacent = false
        var adjacentGroup = (n: digits.first!, count: 1)

        for d in digits.dropFirst() {
            guard d == adjacentGroup.n else {
                if adjacentGroup.count == 2 {
                    hasAdjacent = true
                }

                adjacentGroup = (d, 1)
                continue
            }

            adjacentGroup.count += 1
        }

        if adjacentGroup.count == 2 {
            hasAdjacent = true
        }

        return hasAdjacent
    }

    func digitsOf(_ n: Int) -> [Int] {
        var result = [Int]()
        var n = n
        while n != 0 {
            result.append(n % 10)
            n = n / 10
        }
        return result.reversed()
    }
}
