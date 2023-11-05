////
//// Created by John Griffin on 1/1/22
////
//
// import AdventOfCode2019
// import Algorithms
// import XCTest
//
// extension Day19Tests {
//    // MARK: - simplify rules
//
//    static func simplifyRules(_ rules: [NumberedRule]) -> [NumberedRule] {
//        var simplified = rules.sorted()
//        while let progress = simplifyOneRule(simplified)?.sorted() {
//            // print(difference(simplified, progress))
//            simplified = progress
//        }
//        return simplified
//    }
//
//    // MARK: - simplify oneRule
//
//    static func simplifyOneRule(_ rules: [NumberedRule]) -> [NumberedRule]? {
//        let skip = [0, 8, 11, 42, 31]
//
//        // replace .only rules
//        for rule in rules.filter({ !skip.contains($0.n) }) {
//            if rule.oneOf.count == 1,
//               let run = rule.oneOf.first
//            {
//                return replaceRule(rule.n, inRules: rules, withRun: run)
//            }
//        }
//
//        // replace .oneOf rules
//        for rule in rules.filter({ !skip.contains($0.n) }) {
//            if !rule.oneOf.contains(where: containsMany) {
//                return replaceRule(rule.n, inRules: rules, withOneOf: rule.oneOf)
//            }
//        }
//
//        return nil
//    }
//
//    static func containsMany(_ run: Run) -> Bool {
//        run.contains { r in if case .many = r { true } else { false } }
//    }
//
//    // MARK: - replace withRun
//
//    static func replaceRule(_ n: Int, inRules: [NumberedRule], withRun: Run) -> [NumberedRule] {
//        inRules.compactMap { nRule in replaceRule(n, inNRule: nRule, withRun: withRun) }
//    }
//
//    static func replaceRule(_ n: Int, inNRule: NumberedRule, withRun: Run) -> NumberedRule? {
//        guard inNRule.n != n else { return nil }
//        return NumberedRule(inNRule.n, inNRule.oneOf.map { run in replaceRule(n, inRun: run, withRun: withRun) })
//    }
//
//    static func replaceRule(_ n: Int, inRun: Run, withRun: Run) -> Run {
//        inRun.flatMap { r in .rule(n) == r ? withRun : [r] }
//    }
//
//    // MARK: - replace withOneOf
//
//    static func replaceRule(_ n: Int, inRules: [NumberedRule], withOneOf: [Run]) -> [NumberedRule] {
//        inRules.compactMap { nRule in replaceRule(n, inNRule: nRule, withOneOf: withOneOf) }
//    }
//
//    static func replaceRule(_ n: Int, inNRule: NumberedRule, withOneOf: [Run]) -> NumberedRule? {
//        guard inNRule.n != n else { return nil }
//        return NumberedRule(
//            inNRule.n,
//            inNRule.oneOf.flatMap { run in replaceRule(n, inRun: run, withOneOf: withOneOf) }
//        )
//    }
//
//    static func replaceRule(_ n: Int, inRun: Run, withOneOf: [Run]) -> [Run] {
//        let nCount = inRun.reduce(0) { result, r in result + (.rule(n) == r ? 1 : 0) }
//        guard nCount > 0 else { return [inRun] }
//
//        let nRunsPermutations: [[Run]] = productMany(withOneOf, count: nCount)
//
//        let result = nRunsPermutations.map { nRuns in
//            replaceRule(n, inRun: inRun, withNRuns: nRuns)
//        }
//        return result
//    }
//
//    static func replaceRule(_ n: Int, inRun: Run, withNRuns: [Run]) -> Run {
//        var withRunIt = withNRuns.makeIterator()
//        return inRun.reduce(into: [Rule]()) { result, r in
//            if .rule(n) == r {
//                result.append(contentsOf: withRunIt.next()!)
//            } else {
//                result.append(r)
//            }
//        }
//    }
//
//    // MARK: - difference
//
//    static func difference(_ lRules: [NumberedRule], _ rRules: [NumberedRule]) -> String {
//        var lRules = lRules[...]
//        var rRules = rRules[...]
//
//        var output = [String]()
//        while let l = lRules.first, let r = rRules.first {
//            guard l != r else {
//                lRules = lRules.dropFirst()
//                rRules = rRules.dropFirst()
//                continue
//            }
//
//            if l.n == r.n {
//                output.append("u \(l) \(r)")
//                lRules = lRules.dropFirst()
//                rRules = rRules.dropFirst()
//            } else if l.n < r.n {
//                output.append("r \(l)")
//                lRules = lRules.dropFirst()
//            } else {
//                fatalError()
//            }
//        }
//        assert(rRules.isEmpty)
//        output.append(contentsOf: lRules.map { l in "remove \(l)" })
//
//        return output.joined(separator: "\n")
//    }
// }
