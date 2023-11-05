//
// Created by John Griffin on 12/28/21
//

import Parsing
import XCTest

final class Day06Tests: XCTestCase {
    func testOrbitalTransfersExample() throws {
        let u = try Self.universeP.parse(Self.transferExample)
        var youPath: [Obj]?
        var sanPath: [Obj]?

        dfs(u["COM"]!) { o, path in
            switch o.name {
            case "YOU": youPath = path
            case "SAN": sanPath = path
            default: break
            }
        }

        guard let youPath,
              let sanPath else { fatalError() }
        let common = zip(youPath, sanPath).prefix { y, s in y.name == s.name }
        let transits = youPath.count + sanPath.count - 2 * common.count
        XCTAssertEqual(transits, 4)
    }

    func testOrbitalTransfersInput() throws {
        let u = try Self.universeP.parse(Self.input)
        var youPath: [Obj]?
        var sanPath: [Obj]?

        dfs(u["COM"]!) { o, path in
            switch o.name {
            case "YOU": youPath = path
            case "SAN": sanPath = path
            default: break
            }
        }

        guard let youPath,
              let sanPath else { fatalError() }
        let common = zip(youPath, sanPath).prefix { y, s in y.name == s.name }
        let transits = youPath.count + sanPath.count - 2 * common.count
        XCTAssertEqual(transits, 379)
    }

    func testCountExample() throws {
        let u = try Self.universeP.parse(Self.example)

        var direct = 0
        var indirect = 0
        dfs(u["COM"]!) { _, path in
            guard !path.isEmpty else { return }
            direct += 1
            indirect += path.count - 1
        }

        XCTAssertEqual(direct + indirect, 42)
    }

    func testCountInput() throws {
        let u = try Self.universeP.parse(Self.input)

        var direct = 0
        var indirect = 0
        dfs(u["COM"]!) { _, path in
            guard !path.isEmpty else { return }
            direct += 1
            indirect += path.count - 1
        }

        XCTAssertEqual(direct + indirect, 200_001)
    }
}

extension Day06Tests {
    typealias Visit = (_ o: Obj, _ path: [Obj]) -> Void

    func dfs(
        _ o: Obj,
        _ path: [Obj] = [],
        pre: Visit,
        post: Visit? = nil
    ) {
        pre(o, path)
        o.orbitedBy.forEach { by in
            dfs(by, path + [o], pre: pre, post: post)
        }
        post?(o, path)
    }

    class Obj {
        let name: String
        var orbitedBy: [Obj] = []

        init(name: String) { self.name = name }
    }

    typealias Orbit = (o: String, by: String)

    typealias Universe = [String: Obj]

    static func universeFrom(_ orbits: [Orbit]) -> Universe {
        orbits.reduce(into: Universe()) { u, orbit in
            ensure(orbit.o, in: &u).orbitedBy
                .append(ensure(orbit.by, in: &u))
        }
    }

    static func ensure(_ name: String, in u: inout Universe) -> Obj {
        if u[name] == nil { u[name] = Obj(name: name) }
        return u[name]!
    }
}

extension Day06Tests {
    static let input = resourceURL(filename: "Day06Input.txt")!.readContents()!

    static var example: String {
        """
        COM)B
        B)C
        C)D
        D)E
        E)F
        B)G
        G)H
        D)I
        E)J
        J)K
        K)L
        """
    }

    static var transferExample: String {
        """
        COM)B
        B)C
        C)D
        D)E
        E)F
        B)G
        G)H
        D)I
        E)J
        J)K
        K)L
        K)YOU
        I)SAN
        """
    }

    // MARK: - parser

    static let nameP = Prefix<Substring>(while: { ch in ch.isLetter || ch.isNumber }).map(String.init)
    static let orbitP = Parse { Orbit(o: $0, by: $1) } with: {
        nameP
        ")"
        nameP
    }

    static let universeP = Parse(universeFrom) {
        Many { orbitP } separator: { "\n" }
        Skip { Whitespace().pullback(\.utf8) }
        Skip { End() }
    }

    func testParseExample() throws {
        let u = try Self.universeP.parse(Self.example)
        XCTAssertEqual(u.count, 12)
    }

    func testParseInput() throws {
        let u = try Self.universeP.parse(Self.input)
        XCTAssertEqual(u.count, 1562)
    }
}
