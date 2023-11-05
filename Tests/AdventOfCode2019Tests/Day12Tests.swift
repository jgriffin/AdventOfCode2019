//
// Created by John Griffin on 12/30/21
//

import Algorithms
import EulerTools
import Parsing
import XCTest

final class Day12Tests: XCTestCase {
    func testUntilRepeatExample() throws {
        let ss = try SolarSystem(Self.moonsP.parse(Self.example))
        let repeatsAt = ss.findRepeatsAt()
        XCTAssertEqual(repeatsAt, 2772)
    }

    func testUntilRepeatExample2() throws {
        let ss = try SolarSystem(Self.moonsP.parse(Self.example2))
        let repeatsAt = ss.findRepeatsAt()
        XCTAssertEqual(repeatsAt, 4_686_774_924)
    }

    func testStepUntilRepeatInput() throws {
        let ss = try SolarSystem(Self.moonsP.parse(Self.input))
        let repeatsAt = ss.findRepeatsAt()
        XCTAssertEqual(repeatsAt, 496_734_501_382_552)
    }

    // MARK: - part1

    func testTotalEnergy10Example() throws {
        var ss = try SolarSystem(Self.moonsP.parse(Self.example))
        (1 ... 10).forEach { _ in
            ss.takeStep()
        }
        XCTAssertEqual(ss.totalEnergy, 179)
    }

    func testTotalEnergy100Example() throws {
        var ss = try SolarSystem(Self.moonsP.parse(Self.example2))
        (1 ... 100).forEach { _ in
            ss.takeStep()
        }
        XCTAssertEqual(ss.totalEnergy, 1940)
    }

    func testTotalEnergy100Input() throws {
        var ss = try SolarSystem(Self.moonsP.parse(Self.input))
        (1 ... 1000).forEach { _ in
            ss.takeStep()
        }
        XCTAssertEqual(ss.totalEnergy, 6678)
    }
}

extension Day12Tests {
    struct Moon: Hashable, CustomStringConvertible {
        let p: Index3
        let v: Index3

        var potentialEnergy: Int { abs(p.x) + abs(p.y) + abs(p.z) }
        var kineticEnergy: Int { abs(v.x) + abs(v.y) + abs(v.z) }
        var totalEnergy: Int { potentialEnergy * kineticEnergy }

        var description: String { "p:\(p) v:\(v)" }
    }

    struct SolarSystem: Hashable, CustomStringConvertible {
        var moons: [Moon]

        init(_ positions: [Index3]) {
            moons = positions.map { p in
                Moon(p: p, v: .zero)
            }
        }

        mutating func takeStep() {
            let g = calculateGravity()
            moons = moons.map { m in
                let newV = m.v + g[m]!
                let newP = m.p + newV
                return Moon(p: newP, v: newV)
            }
        }

        func calculateGravity() -> [Moon: Index3] {
            product(moons, moons)
                .reduce(into: [Moon: Index3]()) { result, moons in
                    let (on, from) = (moons.0, moons.1)
                    let g = Index3(g(on.p.x, from.p.x), g(on.p.y, from.p.y), g(on.p.z, from.p.z))
                    result[on, default: .zero] += g
                }
        }

        func g(_ on: Int, _ from: Int) -> Int {
            if on == from { return 0 }
            return on < from ? +1 : -1
        }

        var totalEnergy: Int { moons.map(\.totalEnergy).reduce(0,+) }

        func pvXYZ() -> (x: PV, y: PV, z: PV) {
            (x: PV(p: .init(moons.map { Int16($0.p.x) }),
                   v: .init(moons.map { Int16($0.v.x) })),
             y: PV(p: .init(moons.map { Int16($0.p.y) }),
                   v: .init(moons.map { Int16($0.v.y) })),
             z: PV(p: .init(moons.map { Int16($0.p.z) }),
                   v: .init(moons.map { Int16($0.v.z) })))
        }

        func findRepeatsAt() -> Int {
            let pv = pvXYZ()
            let repeats = (x: pv.x.findRepeatsAtAndFirstOccurrence(),
                           y: pv.y.findRepeatsAtAndFirstOccurrence(),
                           z: pv.z.findRepeatsAtAndFirstOccurrence())
            let r = (x: repeats.x.repeatsAt,
                     y: repeats.y.repeatsAt,
                     z: repeats.z.repeatsAt)

            let gcdYZ = (r.y * r.z) / GCD(r.y, r.z)
            let gcdX_YZ = (r.x * gcdYZ) / GCD(r.x, gcdYZ)
            return gcdX_YZ
        }

        var description: String {
            moons.map(\.description).joined(separator: "\n")
        }
    }

    struct PV: Hashable, CustomStringConvertible {
        let p: SIMD4<Int16>
        let v: SIMD4<Int16>

        var description: String { "p: \(p.x),\(p.y),\(p.z),\(p.w)  v: \(v.x),\(v.y),\(v.z),\(v.w)" }

        func step() -> PV {
            let v = v &+ g(p)
            let p = p &+ v
            return PV(p: p, v: v)
        }

        func g(_ p: SIMD4<Int16>) -> SIMD4<Int16> {
            let x = (p &- SIMD4(repeating: p.x)).clamped(lowerBound: minusOne, upperBound: plusOne)
            let y = (p &- SIMD4(repeating: p.y)).clamped(lowerBound: minusOne, upperBound: plusOne)
            let z = (p &- SIMD4(repeating: p.z)).clamped(lowerBound: minusOne, upperBound: plusOne)
            let w = (p &- SIMD4(repeating: p.w)).clamped(lowerBound: minusOne, upperBound: plusOne)

            return SIMD4(
                x.indices.reduce(into: 0) { r, i in r += x[i] },
                y.indices.reduce(into: 0) { r, i in r += y[i] },
                z.indices.reduce(into: 0) { r, i in r += z[i] },
                w.indices.reduce(into: 0) { r, i in r += w[i] }
            )
        }

        func findRepeatsAtAndFirstOccurrence() -> (repeatsAt: Int, firstAt: Int, pv: PV) {
            let (repeatsAt, value) = findRepeatsAt()
            let firstAt = findIndexOfFirstOccurrence(value)
            return (repeatsAt: repeatsAt, firstAt: firstAt, pv: value)
        }

        func findRepeatsAt() -> (at: Int, value: PV) {
            var i = 0
            var visited = Set<PV>()
            var pv = self
            while true {
                visited.insert(pv)

                i += 1
                pv = pv.step()
                if visited.contains(pv) {
                    break
                }
            }

            return (i, pv)
        }

        func findIndexOfFirstOccurrence(_ target: PV) -> Int {
            var pv = self
            var i = 0
            while pv != target {
                i += 1
                pv = pv.step()
            }
            return i
        }

        let minusOne = SIMD4<Int16>(-1, -1, -1, -1)
        let plusOne = SIMD4<Int16>(1, 1, 1, 1)
    }
}

extension Day12Tests {
    static let input = resourceURL(filename: "Day12Input.txt")!.readContents()!

    static var example: String {
        """
        <x=-1, y=0, z=2>
        <x=2, y=-10, z=-7>
        <x=4, y=-8, z=8>
        <x=3, y=5, z=-1>
        """
    }

    static var example2: String {
        """
        <x=-8, y=-10, z=0>
        <x=5, y=5, z=10>
        <x=2, y=-7, z=3>
        <x=9, y=-8, z=-3>
        """
    }

    // MARK: - parser

    static let index3P = Parse(Index3.init) {
        "<x="
        Int.parser()
        ", y="
        Int.parser()
        ", z="
        Int.parser()
        ">"
    }

    static let moonsP = Parse {
        Many { index3P } separator: { "\n" }
        Skip {
            Prefix(while: { $0.isWhitespace })
            End()
        }
    }

    func testParseExample() throws {
        let moons = try Self.moonsP.parse(Self.example)
        XCTAssertEqual(moons.count, 4)
    }

    func testParseInput() throws {
        let moons = try Self.moonsP.parse(Self.input)
        XCTAssertEqual(moons.count, 4)
    }
}
