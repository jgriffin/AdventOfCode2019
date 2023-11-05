//
// Created by John Griffin on 12/31/21
//

import Algorithms
import EulerTools
import Parsing
import XCTest

final class Day23Tests: XCTestCase {
    let example = "389125467".map { $0.wholeNumberValue! }
    let input = "562893147".map { $0.wholeNumberValue! }

    func testTableMove1MillionExample() {
        let table = Table(example, upTo: 1_000_000)
        let result = (1 ... 10_000_000).reduce(into: table) { table, _ in
            table.move()
        }
        let twoCupsAfter1 = result.cupsAfter1Sequence().prefix(2).map(\.n)
        XCTAssertEqual(twoCupsAfter1, [934_001, 159_792])
        XCTAssertEqual(twoCupsAfter1.reduce(1,*), 149_245_887_792)
    }

    func testTableMove1MillionInput() {
        let table = Table(input, upTo: 1_000_000)
        let result = (1 ... 10_000_000).reduce(into: table) { table, _ in
            table.move()
        }
        let twoCupsAfter1 = result.cupsAfter1Sequence().prefix(2).map(\.n)
        XCTAssertEqual(twoCupsAfter1, [871_396, 150_509])
        XCTAssertEqual(twoCupsAfter1.reduce(1,*), 131_152_940_564)
    }

    func testTableMove100Example() {
        let table = Table(example)
        let result = (1 ... 100).reduce(into: table) { table, _ in
            table.move()
        }
        XCTAssertEqual(
            result.cupsAfter1Sequence().map(\.n).reduce(0) { r, n in r * 10 + n },
            67_384_529
        )
    }

    func testTableMove100Input() {
        let table = Table(input)
        let result = (1 ... 100).reduce(into: table) { table, _ in
            table.move()
        }
        XCTAssertEqual(
            result.cupsAfter1Sequence().map(\.n).reduce(0) { r, n in r * 10 + n },
            38_925_764
        )
    }

    func testTableMove10Example() {
        let table = Table(example)

        print(0, table.cupsString())
        let moves = (1 ... 10).reductions(into: table) { table, i in
            table.move()
            print(i, table.cupsString())
        }
        XCTAssertEqual(moves.last!.cupsString(), "(8) 3 7 4 1 9 2 6 5")
    }

    func testTableMoveExample() {
        var table = Table(example)
        XCTAssertEqual(table.cupsString(), "(3) 8 9 1 2 5 4 6 7")
        XCTAssertEqual(table.cupsByN[7]!.next.n, 3)

        table.move()
        XCTAssertEqual(table.cupsString(), "(2) 8 9 1 5 4 6 7 3")
    }
}

extension Day23Tests {
    struct Table {
        let cupCount: Int
        let cupsByN: [Int: Cup]
        let originalFirst: Cup
        var curr: Cup

        init(_ numbers: [Int], upTo: Int? = nil) {
            let numbers = upTo == nil ? numbers :
                numbers + (numbers.count + 1 ... upTo!)

            let cups = numbers.map { Cup(n: $0) }
            assert(cups.count == upTo ?? numbers.count)
            Self.linkCups(cups)

            cupCount = numbers.count
            cupsByN = cups.reduce(into: [Int: Cup]()) { result, cup in
                result[cup.n] = cup
            }
            originalFirst = cups.first!
            curr = cups.first!
        }

        mutating func move() {
            let pickedUp = cupsIterator(from: curr.next).prefix(3).asArray
            let d = destination(currentN: curr.n, pickedUpCups: pickedUp)
            let dCup = cupsByN[d]!

            curr.setNext(pickedUp.last!.next)
            pickedUp.last!.setNext(dCup.next)
            dCup.setNext(pickedUp.first!)

            curr = curr.next
        }

        func destination(currentN: Int, pickedUpCups: [Cup]) -> Int {
            let pickedUpNumbers = pickedUpCups.map(\.n)
            var d = currentN
            repeat {
                d = (d - 1)
                if d < 1 {
                    d = cupCount
                }
            } while pickedUpNumbers.contains(d)
            return d
        }

        static func linkCups(_ cups: [Cup]) {
            zip(cups, cups.dropFirst()).forEach { l, r in
                l.next = r
                r.prev = l
            }
            cups.last!.next = cups.first!
            cups.first!.prev = cups.last!
        }

        func cupsString(maxLength: Int = .max) -> String {
            cupsIterator(from: curr)
                .prefix(maxLength)
                .map { c in c === curr ? "(\(c.description))" : c.description }
                .joined(separator: " ")
        }

        func cupsAfter1Sequence() -> DropFirstSequence<AnyIterator<Cup>> {
            cupsIterator(from: cupsByN[1]!)
                .dropFirst()
        }

        func cupsIterator(from: Cup) -> AnyIterator<Cup> {
            var c: Cup? = from
            return AnyIterator {
                defer {
                    if c === from.prev {
                        c = nil
                    } else {
                        c = c?.next
                    }
                }
                return c
            }
        }
    }

    class Cup: CustomStringConvertible {
        let n: Int
        var next: Cup!
        var prev: Cup!

        init(n: Int) { self.n = n }

        func setNext(_ to: Cup) {
            next = to
            to.prev = self
        }

        var description: String { "\(n)" }
    }
}
