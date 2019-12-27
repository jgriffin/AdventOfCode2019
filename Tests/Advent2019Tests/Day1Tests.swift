//
//  Day1Tests.swift
//
//
//  Created by John Griffin on 12/27/19.
//

import Foundation

@testable import Advent2019
import XCTest

final class Day1Tests: XCTestCase {
    func fuelForMass(_ mass: Int) -> Int {
        mass / 3 - 2
    }

    func fuelForMassRecursive(_ mass: Int) -> Int {
        let fuel = fuelForMass(mass)
        guard fuel > 0 else { return 0 }
        
        return fuel + fuelForMassRecursive(fuel)
    }

    // --- Day 1: The Tyranny of the Rocket Equation ---
    //
    // Santa has become stranded at the edge of the Solar System while delivering presents to other planets! To accurately calculate his position in space, safely align his warp drive, and return to Earth in time to save Christmas, he needs you to bring him measurements from fifty stars.
    //
    // Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!
    //
    // The Elves quickly load you into a spacecraft and prepare to launch.
    //
    // At the first Go / No Go poll, every Elf is Go until the Fuel Counter-Upper. They haven't determined the amount of fuel required yet.
    //
    // Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
    //
    // For example:
    //
    // For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
    // For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
    // For a mass of 1969, the fuel required is 654.
    // For a mass of 100756, the fuel required is 33583.
    // The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.
    //
    // What is the sum of the fuel requirements for all of the modules on your spacecraft?

    func testPart1Examples() {
        let tests: [(mass: Int, check: Int)] = [
            (12, 2),
            (14, 2),
            (1969, 654),
            (100756, 33583)
        ]
        tests.forEach { test in
            XCTAssertEqual(fuelForMass(test.mass), test.check)
        }
    }

    func testPart1() {
        let input = puzzleInput().split(separator: "\n").map { Int($0)! }
        let result = input.map { fuelForMass($0) }.reduce(0, +)
        XCTAssertEqual(result, 3331849)
    }

    //
    //    During the second Go / No Go poll, the Elf in charge of the Rocket Equation Double-Checker stops the launch sequence. Apparently, you forgot to include additional fuel for the fuel you just added.
    //
    //    Fuel itself requires fuel just like a module - take its mass, divide by three, round down, and subtract 2. However, that fuel also requires fuel, and that fuel requires fuel, and so on. Any mass that would require negative fuel should instead be treated as if it requires zero fuel; the remaining mass, if any, is instead handled by wishing really hard, which has no mass and is outside the scope of this calculation.
    //
    //    So, for each module mass, calculate its fuel and add it to the total. Then, treat the fuel amount you just calculated as the input mass and repeat the process, continuing until a fuel requirement is zero or negative. For example:
    //
    //    A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
    //    At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
    //    The fuel required by a module of mass 100756 and its fuel is: 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
    //    What is the sum of the fuel requirements for all of the modules on your spacecraft when also taking into account the mass of the added fuel? (Calculate the fuel requirements for each module separately, then add them all up at the end.)
    func testPart2Examples() {
        let tests: [(mass: Int, check: Int)] = [
            (14, 2),
            (1969, 966),
            (100756, 50346)
        ]
        tests.forEach { test in
            XCTAssertEqual(fuelForMassRecursive(test.mass), test.check)
        }
    }

    func testPart2() {
        let input = puzzleInput().split(separator: "\n").map { Int($0)! }
        let result = input.map { fuelForMassRecursive($0) }.reduce(0, +)
        XCTAssertEqual(result, 4994898)
    }

    private func puzzleInput() -> String {
        return """
        66690
        86239
        75191
        140364
        95979
        106923
        95229
        123571
        84764
        89444
        98107
        89062
        109369
        146067
        124760
        76900
        139198
        111441
        74046
        84920
        54397
        143807
        121654
        93863
        73909
        104121
        58485
        119084
        126227
        142078
        79820
        132617
        108430
        98032
        107434
        127307
        105619
        57741
        53468
        63301
        137970
        136780
        80897
        133205
        79159
        89124
        94477
        56714
        143704
        122097
        117335
        108246
        75507
        101459
        101162
        146197
        121884
        66217
        57074
        142903
        140951
        64883
        124556
        67382
        142407
        121778
        57933
        94599
        87426
        143758
        64043
        65678
        90137
        61090
        77315
        102383
        146607
        139290
        85394
        149787
        125611
        106405
        91561
        135739
        54845
        68782
        111175
        61011
        125658
        70751
        85607
        75458
        75419
        124311
        66022
        122784
        129018
        54901
        73788
        108240
        """
    }
}
