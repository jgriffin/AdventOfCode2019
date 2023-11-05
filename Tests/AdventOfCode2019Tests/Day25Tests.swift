//
// Created by John Griffin on 12/31/21
//

import Parsing
import XCTest

final class Day25Tests: XCTestCase {
    typealias PublicKeys = (card: Int, door: Int)

    let example = PublicKeys(5_764_801, 17_807_724)
    let input = PublicKeys(3_248_366, 4_738_476)

    func testEncryptionKeyInput() async {
        let encryptionKey = await encryptionKeyForPublicKeys(input)
        XCTAssertEqual(encryptionKey, 18_293_391)
    }

    func testEncryptionKeyExample() async {
        let encryptionKey = await encryptionKeyForPublicKeys(example)
        XCTAssertEqual(encryptionKey, 14_897_079)
    }

    func testMultipleLoopSizeInput() async {
        let pubKeys = input
        let loopSizesCard = await loopSizesForPublicKey(pubKeys.card).prefix(3).collect()
        XCTAssertEqual(loopSizesCard, [13_330_548, 33_531_774, 53_733_000])
        let loopSizesDoor = await loopSizesForPublicKey(pubKeys.door).prefix(3).collect()
        XCTAssertEqual(loopSizesDoor, [17_111_924, 37_313_150, 57_514_376])
    }

    func testLoopSizeInput() async {
        let pubKeys = input
        let loopSizeCard = await loopSizesForPublicKey(pubKeys.card).first()!
        let loopSizeDoor = await loopSizesForPublicKey(pubKeys.door).first()!
        XCTAssertEqual(loopSizeCard, 13_330_548)
        XCTAssertEqual(loopSizeDoor, 17_111_924)
    }

    func testLoopSizeExample() async {
        let pubKeys = example
        let loopSizeCard = await loopSizesForPublicKey(pubKeys.card).first()!
        let loopSizeDoor = await loopSizesForPublicKey(pubKeys.door).first()!
        XCTAssertEqual(loopSizeCard, 8)
        XCTAssertEqual(loopSizeDoor, 11)
    }
}

extension Day25Tests {
    func encryptionKeyForPublicKeys(_ pubKeys: PublicKeys) async -> Int {
        var loopSizeCardIt = await loopSizesForPublicKey(pubKeys.card).makeAsyncIterator()
        var loopSizeDoorIt = await loopSizesForPublicKey(pubKeys.door).makeAsyncIterator()

        var cardEncryptionKeys = Set<Int>()
        var doorEncryptionKeys = Set<Int>()

        while cardEncryptionKeys.isDisjoint(with: doorEncryptionKeys) {
            let nextCardLoopSize = await loopSizeCardIt.next()!
            let nextDoorLoopSize = await loopSizeDoorIt.next()!
            print("loopSize:", nextCardLoopSize, nextDoorLoopSize)

            let nextCardEncryptionKey = await encryptionKey(pubKeys.door, loopSize: nextCardLoopSize)
            let nextDoorEncryptionKey = await encryptionKey(pubKeys.card, loopSize: nextDoorLoopSize)
            print("encryptionKey:", nextCardEncryptionKey, nextDoorEncryptionKey)

            cardEncryptionKeys.insert(nextCardEncryptionKey)
            doorEncryptionKeys.insert(nextDoorEncryptionKey)
        }

        let encryptionKeys = cardEncryptionKeys.intersection(doorEncryptionKeys)
        assert(encryptionKeys.count == 1)
        return encryptionKeys.min()!
    }

    func encryptionKey(_ pubKey: Int, loopSize: Int) async -> Int {
        (0 ..< loopSize).reduce(1) { value, _ in
            step(value: value, subject: pubKey)
        }
    }

    func loopSizesForPublicKey(_ k: Int) async -> AsyncStream<Int> {
        AsyncStream { c in
            Task {
                let subject = 7
                var value = 1
                var i = 0
                while !Task.isCancelled {
                    value = step(value: value, subject: subject)
                    i += 1
                    if value == k {
                        c.yield(i)
                    }
                }
            }
        }
    }

    @inlinable
    func step(value: Int, subject: Int) -> Int {
        value * subject % 20_201_227
    }
}
