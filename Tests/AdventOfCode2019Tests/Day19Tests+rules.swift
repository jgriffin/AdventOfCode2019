////
//// Created by John Griffin on 1/2/22
////
//
// extension Day19Tests {
//    struct NumberedRule: Equatable, CustomStringConvertible, Comparable {
//        let n: Int
//        let oneOf: [Run]
//
//        init(_ n: Int, _ oneOf: [Run]) {
//            self.n = n
//            self.oneOf = oneOf
//        }
//
//        init(_ n: Int, _ run: [Rule]) {
//            self.init(n, [Run(run)])
//        }
//
//        var description: String {
//            "\(n): " + oneOf.map(\.description).joined(separator: " | ")
//        }
//
//        static func < (lhs: NumberedRule, rhs: NumberedRule) -> Bool { lhs.n < rhs.n }
//    }
//
//    typealias Run = [Rule]
//
//    enum Rule: Equatable, CustomStringConvertible {
//        case char(Character)
//        case anyChar
//        case many(Int, atLeast: Int)
//        case rule(Int)
//
//        var description: String {
//            switch self {
//            case let .char(ch): return "\(ch)"
//            case .anyChar: return "*"
//            case let .rule(n): return "\(n)"
//            case let .many(n, t): return "(\(n),\(t))"
//            }
//        }
//
//        var character: Character? {
//            switch self {
//            case let .char(ch): return ch
//            case .anyChar, .rule, .many: return nil
//            }
//        }
//
//        var isAnyChar: Bool {
//            switch self {
//            case .anyChar: return true
//            case .char, .rule, .many: return false
//            }
//        }
//    }
//
//    func updatingRules(_ rules: [NumberedRule], withRules: [NumberedRule]) -> [NumberedRule] {
//        rules.map { r in
//            if let update = withRules.first(where: { $0.n == r.n }) {
//                return update
//            }
//            return r
//        }
//    }
// }
//
// extension Day19Tests.Run {
//    var description: String { map(\.description).joined(separator: " ") }
// }
