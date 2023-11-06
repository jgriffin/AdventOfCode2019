//
// Created by John Griffin on 11/4/23
//

import Parsing

// An Intcode program is a list of integers separated by commas (like 1,0,0,3,99). To run one, start by looking at the first integer (called position 0). Here, you will find an opcode - either 1, 2, or 99. The opcode indicates what to do; for example, 99 means that the program is finished and should immediately halt. Encountering an unknown opcode means something went wrong.
//
// Opcode 1 adds together numbers read from two positions and stores the result in a third position. The three integers immediately after the opcode tell you these three positions - the first two indicate the positions from which you should read the input values, and the third indicates the position at which the output should be stored.
//
// For example, if your Intcode computer encounters 1,10,20,30, it should read the values at positions 10 and 20, add those values, and then overwrite the value at position 30 with their sum.
//
// Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them. Again, the three integers after the opcode indicate where the inputs and outputs are, not their values.
//
// Once you're done processing an opcode, move to the next one by stepping forward 4 positions.
public struct IntcodeComputer {
    public let input: () -> Int
    public var output: [Int] = []

    public var state: [Int]
    public var ip: Int = 0
    public var debug: Bool

    init(
        program: [Int],
        input: @escaping () -> Int,
        debug: Bool = false
    ) {
        self.state = program
        self.input = input
        self.debug = debug
    }

    // MARK: - convenience accessors

    private mutating func setLocation(_ location: Int, value: Int) {
        dbgPrint("set: \(location) = \(value)\n")
        state[location] = value
    }

    var currentOpCode: OpCode { OpCode(state[ip]) }
    var parameter1: Int { state[ip+1] }
    var parameter2: Int { state[ip+2] }
    var parameter3: Int { state[ip+3] }

    func resolve(_ parameter: Int, isImmediate: Bool) -> Int {
        isImmediate ? parameter : state[parameter]
    }

    public var result: Int { state[0] }

    public func dbgPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        guard debug else { return }
        print(items, separator: separator, terminator: terminator)
    }

    enum RuntimeError: Error {
        case invalidOpcode(location: Int, value: Int)
        case halted
    }

    // MARK: - run

    /**
     create an run program
     */
    public static func run(
        program: [Int],
        noun: Int? = nil,
        verb: Int? = nil,
        input: @escaping () -> Int = { fatalError() }
    ) throws -> Self {
        var computer = IntcodeComputer(program: program, input: input)
        if let noun {
            computer.state[1] = noun
        }
        if let verb {
            computer.state[2] = verb
        }

        while true {
            do {
                try computer.step()
            } catch RuntimeError.halted {
                break
            }
        }

        return computer
    }

    /// process one OpCode
    mutating func step() throws {
        let opCode = currentOpCode
        dbgPrint("\(ip):", "opCode", opCode.value)

        switch opCode.operation {
        case .add:
            let (p1, p2, p3) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2),
                parameter3
            )
            setLocation(p3, value: p1+p2)
            ip += 4

        case .multiply:
            let (p1, p2, p3) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2),
                parameter3
            )
            setLocation(p3, value: p1 * p2)
            ip += 4

        case .input:
            let p1 = parameter1
            let result = input()
            setLocation(p1, value: result)
            ip += 2

        case .output:
            let p1 = resolve(parameter1, isImmediate: opCode.isImmediate1)
            dbgPrint("out: \(p1)\n")
            output.append(p1)
            ip += 2

        case .jumpIfTrue:
            let (p1, p2) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2)
            )
            if p1 != 0 {
                ip = p2
            } else {
                ip += 3
            }

        case .jumpIfFalse:
            let (p1, p2) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2)
            )
            if p1 == 0 {
                ip = p2
            } else {
                ip += 3
            }

        case .lessThan:
            let (p1, p2, p3) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2),
                parameter3
            )
            setLocation(p3, value: p1 < p2 ? 1 : 0)
            ip += 4

        case .equals:
            let (p1, p2, p3) = (
                resolve(parameter1, isImmediate: opCode.isImmediate1),
                resolve(parameter2, isImmediate: opCode.isImmediate2),
                parameter3
            )
            setLocation(p3, value: p1 == p2 ? 1 : 0)
            ip += 4

        case .halt:
            throw RuntimeError.halted
        }
    }
}

extension IntcodeComputer {}

public extension IntcodeComputer {
    struct OpCode {
        let value: Int
        let operation: Operation

        public init(_ value: Int) {
            self.value = value
            guard let op = Operation(rawValue: value % 100) else { fatalError("invalid opCode") }
            self.operation = op
        }

        public enum Operation: Int {
            case add = 1
            case multiply = 2
            case input = 3
            case output = 4
            case jumpIfTrue = 5
            case jumpIfFalse = 6
            case lessThan = 7
            case equals = 8
            case halt = 99
        }

        public var isImmediate1: Bool { ((value / 100) % 10) == 1 }
        public var isImmediate2: Bool { ((value / 1000) % 10) == 1 }
    }
}

public extension IntcodeComputer {
    static let programParser = Parse(input: Substring.self) {
        Many { Int.parser() } separator: { "," }
        Skip {
            Optionally { "\n" }
            End()
        }
    }
}
