//
// Created by John Griffin on 12/29/21
//

import Algorithms
import EulerTools
import Parsing
import XCTest

final class Day10Tests: XCTestCase {
    func testLaserSmallExample() throws {
        let space = try Self.spaceP.parse(Self.laserSmallExample)
        let best = space.lineOfSights()
            .max(by: { l, r in l.value.count < r.value.count })!
        XCTAssertEqual(best.value.count, 30)
        XCTAssertEqual(best.key, Asteroid(8, 3))

        let removed = space.laserAsteroids(from: best.key, count: .max)
        XCTAssertEqual(removed.count, 36)
        XCTAssertEqual(removed.last, Asteroid(14, 3))
    }

    func testLaserExample() throws {
        let space = try Self.spaceP.parse(Self.laserExample)
        let best = space.lineOfSights()
            .max(by: { l, r in l.value.count < r.value.count })!
        XCTAssertEqual(best.value.count, 210)
        XCTAssertEqual(best.key, Asteroid(11, 13))

        let destroyed = space.laserAsteroids(from: best.key, count: 200)
        XCTAssertEqual(destroyed.count, 200)
        XCTAssertEqual(destroyed.last, Asteroid(8, 2))
    }

    func testLaserInput() throws {
        let space = try Self.spaceP.parse(Self.input)
        let best = space.lineOfSights()
            .max(by: { l, r in l.value.count < r.value.count })!
        XCTAssertEqual(best.value.count, 260)
        XCTAssertEqual(best.key, Asteroid(14, 17))

        let destroyed = space.laserAsteroids(from: best.key, count: 200)
        XCTAssertEqual(destroyed.count, 200)
        XCTAssertEqual(destroyed.last, Asteroid(6, 8))
        XCTAssertEqual(6 * 100 + 8, 608)
    }

    func testBestMonitorExample() throws {
        let space = try Self.spaceP.parse(Self.example)
        let sights = space.lineOfSights()
        let best = sights.max(by: { l, r in l.value.count < r.value.count })!
        XCTAssertEqual(best.value.count, 41)
        XCTAssertEqual(best.key, Asteroid(6, 3))
    }

    func testBestMonitorInput() throws {
        let space = try Self.spaceP.parse(Self.input)
        let sights = space.lineOfSights()
        let best = sights.max(by: { l, r in l.value.count < r.value.count })!
        XCTAssertEqual(best.value.count, 260)
        XCTAssertEqual(best.key, Asteroid(14, 17))
    }
}

extension Day10Tests {
    typealias Asteroid = IndexXY
    typealias Polar = (r: Double, phi: Double)

    struct Space {
        let indices: Asteroid.IndexRanges
        var asteriods: Set<Asteroid>

        init(_ s: [[Bool]]) {
            let indices = s.indexXYRanges()
            self.indices = indices
            asteriods = product(indices.x, indices.y)
                .map { x, y in Asteroid(x, y) }
                .filter { s[$0] }
                .asSet
        }

        func laserAsteroids(from: Asteroid, count: Int) -> [Asteroid] {
            let clockwise = clockwiseAVQS(from: from)
            let fireOrder = fireOrderFromClockwiseSorted(clockwise)
            return fireOrder.prefix(count).map(\.a)
        }

        func clockwiseAVQS(from: Asteroid) -> [AVQS] {
            asteriods
                .filter { $0 != from }
                .map { a in Self.aVectorQuadrantSlope(a, from: from) }
                .sorted(by: Self.isBeforeClockwise)
        }

        static func isBeforeClockwise(
            _ l: AsteroidVectorQuadrandAndSlope,
            _ r: AsteroidVectorQuadrandAndSlope
        ) -> Bool {
            guard l.q == r.q else {
                return l.q < r.q
            }

            if l.slope == r.slope {
                return lengthSquared(l.v) < lengthSquared(r.v)
            } else {
                return l.slope > r.slope
            }
        }

        func fireOrderFromClockwiseSorted(_ avqss: [AVQS]) -> [AVQS] {
            var fireOrder = [AVQS]()

            var pending = avqss
            var prev: AVQS?

            while !pending.isEmpty {
                if Self.isHidden(pending.first!, by: prev) {
                    fireOrder.append(contentsOf: pending)
                    break
                }
                var hidden = [AVQS]()

                for a in pending {
                    defer { prev = a }
                    if Self.isHidden(a, by: prev) {
                        hidden.append(a)
                    } else {
                        fireOrder.append(a)
                    }
                }

                pending = hidden
            }

            return fireOrder
        }

        static func isHidden(_ a: AVQS, by: AVQS?) -> Bool {
            guard let by,
                  a.q == by.q,
                  a.slope == by.slope,
                  lengthSquared(a.v) > lengthSquared(by.v)
            else {
                return false
            }
            return true
        }

        typealias AsteroidVectorQuadrandAndSlope = (a: Asteroid, v: IndexXY, q: Int, slope: Float)
        typealias AVQS = AsteroidVectorQuadrandAndSlope
        typealias IsIncreasingAVQS = (AVQS, AVQS) -> Bool

        static func aVectorQuadrantSlope(_ a: Asteroid, from: Asteroid) -> AVQS {
            let v = IndexXY(a.x - from.x, from.y - a.y)
            return (
                a: a,
                v: v,
                q: quadrant(v),
                slope: v.x != 0 ? Float(v.y) / Float(v.x) : Float(.max)
            )
        }

        static func lengthSquared(_ v: IndexXY) -> Int { v.x * v.x + v.y * v.y }

        static func quadrant(_ p: IndexXY) -> Int {
            if p.x >= 0, p.y > 0 {
                return 1
            } else if p.x > 0, p.y <= 0 {
                return 2
            } else if p.x <= 0, p.y < 0 {
                return 3
            } else if p.x < 0, p.y >= 0 {
                return 4
            }
            fatalError()
        }

        func lineOfSights() -> [Asteroid: [Asteroid]] {
            asteriods.combinations(ofCount: 2).map { c in (c[0], c[1]) }
                .reduce(into: [Asteroid: [Asteroid]]()) { sights, pair in
                    guard isLineOfSight(from: pair.0, to: pair.1) else { return }

                    sights[pair.0, default: []].append(pair.1)
                    sights[pair.1, default: []].append(pair.0)
                }
        }

        func isLineOfSight(from: Asteroid, to: Asteroid) -> Bool {
            guard from != to else { return false }

            let delta = to - from
            let steps = abs(GCD(delta.x, delta.y))
            let step = (delta.x / steps, delta.y / steps)
            assert(delta.x % steps == 0 && delta.y % steps == 0)

            var c = from + step
            while c != to {
                if asteriods.contains(c) {
                    return false
                }
                c += step
            }

            return true
        }
    }
}

extension Day10Tests {
    static let input = resourceURL(filename: "Day10Input.txt")!.readContents()!

    static var example: String {
        """
        .#..#..###
        ####.###.#
        ....###.#.
        ..###.##.#
        ##.##.#.#.
        ....###..#
        ..#.#..#.#
        #..#.#.###
        .##...##.#
        .....#.#..
        """
    }

    static var laserSmallExample: String {
        """
        .#....#####...#..
        ##...##.#####..##
        ##...#...#.#####.
        ..#.....#...###..
        ..#.#.....#....##
        """
    }

    static var laserExample: String {
        """
        .#..##.###...#######
        ##.############..##.
        .#.######.########.#
        .###.#######.####.#.
        #####.##.#.##.###.##
        ..#####..#.#########
        ####################
        #.####....###.#.#.##
        ##.#################
        #####.##.###..####..
        ..######..##.#######
        ####.##.####...##..#
        .#####..#.######.###
        ##...#.##########...
        #.##########.#######
        .####.#.###.###.#.##
        ....##.##.###..#####
        .#.#.###########.###
        #.#.#.#####.####.###
        ###.##.####.##.#..##
        """
    }

    // MARK: - parser

    static let asteroidParser = OneOf {
        "#".map { true }
        ".".map { false }
    }

    static let lineP = Many(1...) { asteroidParser }
    static let spaceP = Parse(Space.init) {
        Many { lineP } separator: { "\n" }
        Skip {
            Optionally { "\n" }
            End()
        }
    }

    func testParseExample() throws {
        let space = try Self.spaceP.parse(Self.example)
        XCTAssertEqual(space.asteriods.count, 50)
    }

    func testParseInput() throws {
        let space = try Self.spaceP.parse(Self.input)
        XCTAssertEqual(space.asteriods.count, 356)
    }
}
