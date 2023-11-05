//
// Created by John Griffin on 1/3/22
//

import Parsing
import XCTest

final class Day14Tests: XCTestCase {
    func testFuelPerTrillionInput() throws {
        let reactions = try Self.inputP.parse(Self.input)
        let (fuel, _) = maxFuel(ore: 1_000_000_000_000, reactions: reactions)
        XCTAssertEqual(fuel, 2_144_702)
    }

    func testFuelPerTrillionExamples() throws {
        let tests: [(example: String, check: Int)] = [
            (Self.example13312, 82_892_753),
            (Self.example180697, 5_586_022),
            (Self.example2210736, 460_664),
        ]

        try tests.forEach { test in
            let reactions = try Self.inputP.parse(test.example)
            let (fuel, _) = maxFuel(ore: 1_000_000_000_000, reactions: reactions)
            XCTAssertEqual(fuel, test.check)
        }
    }

    func testFuelCostInput() throws {
        let reactions = try Self.inputP.parse(Self.input)
        let inv = integerFuelCost(reactions)
        XCTAssertEqual(inv["ORE"]!, 857_266)
    }

    func testFuelCostExamples() throws {
        let tests: [(example: String, check: Int)] = [
            (Self.example165, 165),
            (Self.example13312, 13312),
            (Self.example180697, 180_697),
            (Self.example2210736, 2_210_736),
        ]

        try tests.forEach { test in
            let reactions = try Self.inputP.parse(test.example)
            let inv = integerFuelCost(reactions)
            XCTAssertEqual(inv["ORE"]!, test.check)
        }
    }

    typealias Ingredient = String
    typealias Amount = (c: Int, ingredient: Ingredient)
    typealias Reaction = (consumes: [Amount], produces: Amount)
    typealias Inventory = [Ingredient: Int]

    func isOre(_ i: Ingredient) -> Bool { i == "ORE" }
    func isAmountOfOre(_ a: Amount) -> Bool { isOre(a.ingredient) }

    func maxFuel(ore: Int, reactions: [Reaction]) -> (fuel: Int, Inventory) {
        let averageFuelCost = averageOreCost(of: "FUEL", reactions)
        // print("averageFuelCost:", averageFuelCost)

        let maxFuelAmount = ore / Int(averageFuelCost)
        var fuelAmount = maxFuelAmount
        while true {
            let fuelAmountCost = integerCost(inv: ["FUEL": fuelAmount], reactions)
            guard fuelAmountCost["ORE"]! > ore else {
                return (fuelAmount, fuelAmountCost)
            }
            fuelAmount -= 1
        }
    }

    func averageOreCost(of ingredient: Ingredient, _ reactions: [Reaction]) -> Float {
        guard ingredient != "ORE" else { return Float(1) }
        let reaction = reactions.first(where: { $0.produces.ingredient == ingredient })!
        let consumedCost = reaction.consumes.reduce(Float(0)) { result, amount in
            result + Float(amount.c) * averageOreCost(of: amount.ingredient, reactions)
        }
        return consumedCost / Float(reaction.produces.c)
    }

    func integerFuelCost(
        _ reactions: [Reaction],
        consumeOre: Bool = true
    ) -> (Inventory) {
        integerCost(inv: ["FUEL": 1], reactions, consumeOre: consumeOre)
    }

    func integerCost(
        inv: Inventory,
        _ reactions: [Reaction],
        consumeOre: Bool = true
    ) -> (Inventory) {
        var inv = inv

        func nextNeeded() -> (amount: Amount, reaction: Reaction)? {
            for (ingredient, c) in inv {
                guard c > 0, !isOre(ingredient) else { continue }
                let reaction = reactions.first(where: { $0.produces.ingredient == ingredient })!

                guard consumeOre || !reaction.consumes.contains(where: isAmountOfOre) else { continue }

                return (Amount(c, ingredient), reaction)
            }

            return nil
        }

        while let needed = nextNeeded() {
            let times = max(1, needed.amount.c / needed.reaction.produces.c)

            needed.reaction.consumes.forEach { amount in
                inv[amount.ingredient, default: 0] += amount.c * times
            }
            inv[needed.reaction.produces.ingredient]! -= needed.reaction.produces.c * times
        }

        return inv
    }
}

extension Day14Tests {
    static let input = resourceURL(filename: "Day14Input.txt")!.readContents()!

    static var example165: String {
        """
        9 ORE => 2 A
        8 ORE => 3 B
        7 ORE => 5 C
        3 A, 4 B => 1 AB
        5 B, 7 C => 1 BC
        4 C, 1 A => 1 CA
        2 AB, 3 BC, 4 CA => 1 FUEL
        """
    }

    static var example13312: String {
        """
        157 ORE => 5 NZVS
        165 ORE => 6 DCFZ
        44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
        12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
        179 ORE => 7 PSHF
        177 ORE => 5 HKGWZ
        7 DCFZ, 7 PSHF => 2 XJWVT
        165 ORE => 2 GPVTF
        3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
        """
    }

    static var example180697: String {
        """
        2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
        17 NVRVD, 3 JNWZP => 8 VPVL
        53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
        22 VJHF, 37 MNCFX => 5 FWMGM
        139 ORE => 4 NVRVD
        144 ORE => 7 JNWZP
        5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
        5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
        145 ORE => 6 MNCFX
        1 NVRVD => 8 CXFTF
        1 VJHF, 6 MNCFX => 4 RFSQX
        176 ORE => 6 VJHF
        """
    }

    static var example2210736: String {
        """
        171 ORE => 8 CNZTR
        7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
        114 ORE => 4 BHXH
        14 VRPVC => 6 BMBT
        6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
        6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
        15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
        13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
        5 BMBT => 4 WPTQ
        189 ORE => 9 KTJDG
        1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
        12 VRPVC, 27 CNZTR => 2 XDBXC
        15 KTJDG, 12 BHXH => 5 XCVML
        3 BHXH, 2 VRPVC => 7 MZWV
        121 ORE => 7 VRPVC
        7 XCVML => 6 RJRHP
        5 BHXH, 4 VRPVC => 5 LTCX
        """
    }

    // MARK: - parser

    static let amountP = Parse(input: Substring.self) { Amount($0, $1) } with: {
        Int.parser()
        " "
        Prefix(while: \.isLetter).map(String.init)
    }

    //    Int.parser().skip(" ").take(Prefix(while: \.isLetter)).map { Amount($0, String($1)) }
    static let reactionP = Parse { Reaction($0, $1) } with: {
        Many { amountP } separator: { ", " }
        " => "
        amountP
    }

    static let reactionsP = Many { reactionP } separator: { "\n" }
    static let inputP = Parse {
        reactionsP
        Skip { Many { "\n" }}
    }

    func testParseExample() throws {
        let reactions = try Self.inputP.parse(Self.example165)
        XCTAssertEqual(reactions.count, 7)
    }

    func testParseInput() throws {
        let reactions = try Self.inputP.parse(Self.input)
        XCTAssertEqual(reactions.count, 60)
        XCTAssert(reactions.last!.produces == (1, "NLPB"))
    }
}
