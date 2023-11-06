//
// Created by John Griffin on 11/4/23
//

import Foundation

// An Intcode program is a list of integers separated by commas (like 1,0,0,3,99). To run one, start by looking at the first integer (called position 0). Here, you will find an opcode - either 1, 2, or 99. The opcode indicates what to do; for example, 99 means that the program is finished and should immediately halt. Encountering an unknown opcode means something went wrong.
//
// Opcode 1 adds together numbers read from two positions and stores the result in a third position. The three integers immediately after the opcode tell you these three positions - the first two indicate the positions from which you should read the input values, and the third indicates the position at which the output should be stored.
//
// For example, if your Intcode computer encounters 1,10,20,30, it should read the values at positions 10 and 20, add those values, and then overwrite the value at position 30 with their sum.
//
// Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them. Again, the three integers after the opcode indicate where the inputs and outputs are, not their values.
//
// Once you're done processing an opcode, move to the next one by stepping forward 4 positions.
public struct OpCode {
    let value: Int
    
    public init(_ value: Int) {
        self.value = value
    }
    
    public var op: Operation {
        guard let op = Operation(rawValue: value % 100) else { fatalError("invalid oppcode") }
        return op
    }

    public var isImmediate1: Bool { (value / 100 % 10) == 1 }
    public var isImmediate2: Bool { (value / 1000 % 10) == 1 }

    public enum Operation: Int {
        case add = 1
        case multiply = 2
        case input = 3
        case output = 4
        case halt = 99
        
        public var length: Int {
            switch self {
            case .add: 4
            case .multiply: 4
            case .input: 2
            case .output: 2
            case .halt: 1
            }
        }
    }
}

public struct IntcodeComputer {
    public let input: () -> Int
    public let output: (Int) -> Void
    public var state: [Int]
    public var ip: Int = 0
        
    init(
        program: [Int],
        input: @escaping () -> Int,
        output: @escaping (Int) -> Void
    ) {
        self.state = program
        self.input = input
        self.output = output
    }
        
    /**
     create an run program
     */
    public static func run(
        program: [Int],
        noun: Int? = nil,
        verb: Int? = nil,
        input: @escaping () -> Int = { fatalError() },
        output: @escaping (Int) -> Void = { _ in fatalError() }
    ) throws -> Self {
        var computer = IntcodeComputer(program: program, input: input, output: output)
        if let noun {
            computer.state[1] = noun
        }
        if let verb {
            computer.state[2] = verb
        }
        try computer.runUntilHalt()
        return computer
    }
        
    /// run until halt
    mutating func runUntilHalt() throws {
        var intcode = OpCode(state[ip])
        while intcode.op != .halt {
            processOpCode(intcode)
                
            ip += intcode.op.length
            intcode = OpCode(state[ip])
        }
    }
        
    func parameter1(_ opCode: OpCode) -> Int {
        opCode.isImmediate1 ? state[ip + 1] : state[state[ip + 1]]
    }

    func parameter2(_ opCode: OpCode) -> Int {
        opCode.isImmediate2 ? state[ip + 2] : state[state[ip + 2]]
    }
        
    func parameter3(_ opcode: OpCode) -> Int {
        state[ip + 3]
    }

    /// process one OpCode
    mutating func processOpCode(_ opCode: OpCode) {
        switch opCode.op {
        case .add:
            state[parameter3(opCode)] = parameter1(opCode) + parameter2(opCode)
        case .multiply:
            state[parameter3(opCode)] = parameter1(opCode) * parameter2(opCode)
        case .input:
            state[state[ip + 1]] = input()
        case .output:
            output(state[ip + 1])
        case .halt:
            fatalError("doesn't get handled here")
        }
    }
        
    enum RuntimeError: Error {
        case invalidOpcode(location: Int, value: Int)
    }
}
