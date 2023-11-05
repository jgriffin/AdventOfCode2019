////
//// Created by John Griffin on 1/1/22
////
//
// import Algorithms
// import XCTest
//
// extension Day19Tests {
//    enum EasyMatcher {
//        static func isValidMessage(_ s: String, prefixRuns: Set<String>, suffixRuns: Set<String>) -> Bool {
//            let chunkSize = prefixRuns.first!.count
//            guard s.count % chunkSize == 0 else {
//                return false
//            }
//            let chunks = s.chunks(ofCount: prefixRuns.first!.count).map { String($0) }
//            let prefix = chunks.prefix(while: prefixRuns.contains)
//            let suffix = chunks.dropFirst(prefix.count).prefix(while: suffixRuns.contains)
//
//            print(prefix.count, chunks.count, suffix.count, s)
//
//            guard prefix.count + suffix.count == chunks.count,
//                  prefix.count >= 2,
//                  suffix.count >= 1,
//                  prefix.count > suffix.count
//            else { return false }
//            return true
//        }
//
//        // example hand rolled
//        static let rule42 = "aaaaa|aaaab|aaaba|aaabb|aabbb|ababa|abbbb|baaaa|baabb|babbb|bbaaa|bbaab|bbabb|bbbab|bbbba|bbbbb"
//        static let rule31 = "aabaa|aabab|aabba|abaaa|abaab|ababb|abbaa|abbab|abbba|baaab|baaba|babaa|babab|babba|bbaba|bbbaa"
//    }
//
//    struct Matcher: CustomStringConvertible {
//        let rules: [Int: NumberedRule]
//
//        // MARK: - init
//
//        init(_ rulesByNo: [Int: NumberedRule]) {
//            rules = rulesByNo
//        }
//
//        init(_ rules: [NumberedRule]) {
//            self.init(
//                rules.reduce(into: [Int: NumberedRule]()) { rules, rule in
//                    rules[rule.n] = rule
//                }
//            )
//        }
//
//        var description: String {
//            rules.values.sorted(by: { l, r in l.n < r.n }).map(\.description).joined(separator: "\n")
//        }
//
//        // MARK: - MessageParser
//
//        typealias MessageParser = (_ input: inout Substring) -> Bool
//
//        func completelyMatchesRule(_ ruleNo: Int) -> (String) -> Bool {
//            { message in
//                var input = message[...]
//                guard parserFor(ruleNo)(&input) else { return false }
//                return input.isEmpty
//            }
//        }
//
//        func parserFor(_ ruleNo: Int) -> MessageParser {
//            { input in
//                let rule = rules[ruleNo]!
//                let original = input
//
//                for r in rule.oneOf {
//                    if parserFor(r)(&input) {
//                        return true
//                    }
//                }
//
//                input = original
//                return false
//            }
//        }
//
//        func parserFor(_ run: Run) -> MessageParser {
//            { input in
//                let original = input
//
//                var seq = run[...]
//                while !seq.isEmpty {
//                    let sr = seq.removeFirst()
//
//                    guard parserFor(sr)(&input) else {
//                        input = original
//                        return false
//                    }
//                }
//
//                return true
//            }
//        }
//
//        func parserFor(_ sr: Rule) -> MessageParser {
//            switch sr {
//            case let .char(ch):
//                return { input in
//                    guard input.first == ch else {
//                        return false
//                    }
//                    input = input.dropFirst()
//                    return true
//                }
//
//            case .anyChar:
//                return { input in
//                    input = input.dropFirst()
//                    return true
//                }
//
//            case let .rule(no):
//                return parserFor(no)
//            case let .many(ruleNo, atLeast):
//                return parserForMany(ruleNo, atLeast: atLeast)
//            }
//        }
//
//        func parserForMany(_ ruleNo: Int, atLeast: Int) -> MessageParser {
//            { input in
//                let original = input
//                var best = original
//                var i = 0
//
//                let parser = parserFor(ruleNo)
//
//                while true {
//                    guard parser(&input) else {
//                        guard i >= atLeast else {
//                            input = original
//                            return false
//                        }
//
//                        input = best
//                        return true
//                    }
//
//                    best = input
//                    i += 1
//                }
//            }
//        }
//    }
// }
