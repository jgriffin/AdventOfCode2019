////
//// Created by John Griffin on 12/31/21
////
//
// import Parsing
// import XCTest
//
// final class Day19Tests: XCTestCase {
//    func testSolveWithSimplifyInput() throws {
//        let input = try Self.inputP.parse(Self.input)
//        let rules = updatingRules(input.rules, withRules: Self.modifiedRules)
//        let simplifiedRules = Self.simplifyRules(rules)
//        simplifiedRules.forEach { print($0) }
//
//        let rule42Strings = simplifiedRules.first(where: { $0.n == 42 })!.oneOf
//            .map { run in String(run.map { $0.character! }) }.sorted()
//        let rule31Strings = simplifiedRules.first(where: { $0.n == 31 })!.oneOf
//            .map { run in String(run.map { $0.character! }) }.sorted()
//
//        let passing = input.messages.filter { m in
//            EasyMatcher.isValidMessage(m, prefixRuns: rule42Strings.asSet, suffixRuns: rule31Strings.asSet)
//        }
//        passing.forEach { print($0) }
//        XCTAssertEqual(passing.count, 381)
//    }
//
//    func testSolveWithSimplifyExample() throws {
//        let input = try Self.inputP.parse(Self.modifiedRulesExample)!
//        let rules = updatingRules(input.rules, withRules: Self.modifiedRules)
//        let simplifiedRules = Self.simplifyRules(rules)
//        simplifiedRules.forEach { print($0) }
//
//        let rule42Strings = simplifiedRules.first(where: { $0.n == 42 })!.oneOf
//            .map { run in String(run.map { $0.character! }) }.sorted()
//        let rule31Strings = simplifiedRules.first(where: { $0.n == 31 })!.oneOf
//            .map { run in String(run.map { $0.character! }) }.sorted()
//
//        let passing = input.messages.filter { m in
//            EasyMatcher.isValidMessage(m, prefixRuns: rule42Strings.asSet, suffixRuns: rule31Strings.asSet)
//        }
//        XCTAssertEqual(passing.count, 12)
//    }
//
//    func testSimplifyInput() throws {
//        let input = try Self.inputP.parse(Self.input)
//        let rules = updatingRules(input.rules, withRules: Self.modifiedRules)
//        let simplifiedRules = Self.simplifyRules(rules)
//        simplifiedRules.forEach { print($0) }
//    }
//
//    func testSimplifyExample() throws {
//        let input = try Self.inputP.parse(Self.modifiedRulesExample)
//        let rules = updatingRules(input.rules, withRules: Self.modifiedRules)
//        let simplifiedRules = Self.simplifyRules(rules)
//        simplifiedRules.forEach { print($0) }
//    }
//
//    func txestModifiedRulesExample() throws {
//        let input = try Self.inputP.parse(Self.modifiedRulesExample)
//        let rules = updatingRules(input.rules, withRules: Self.modifiedRules)
//        let simplifiedRules = Self.simplifyRules(rules)
//        simplifiedRules.forEach { print($0) }
//
//        let passes = Matcher(simplifiedRules).completelyMatchesRule(0)
//
//        let testMessage = "bbabbbbaabaabba"
//        XCTAssertEqual(passes(testMessage), true)
//
//        let passing = input.messages.filter(passes)
//        passing.forEach { print($0) }
//        XCTAssertEqual(passing.count, 12)
//    }
//
//    func testUnModifiedRulesExample() throws {
//        let input = try Self.inputP.parse(Self.modifiedRulesExample)
//        let matcher = Matcher(input.rules)
//        let passes = matcher.completelyMatchesRule(0)
//
//        let passing = input.messages.filter(passes)
//        XCTAssertEqual(passing.count, 3)
//    }
//
//    func testMessagePassingInput() throws {
//        let input = try Self.inputP.parse(Self.input)
//        let passes = Matcher(input.rules).completelyMatchesRule(0)
//
//        let passing = input.messages
//            .filter(passes)
//        XCTAssertEqual(passing.count, 248)
//
//        let simplified = Self.simplifyRules(input.rules)
//        let simplifiedPasses = Matcher(simplified).completelyMatchesRule(0)
//        let simplifiedPassing = input.messages
//            .filter(simplifiedPasses)
//        XCTAssertEqual(simplifiedPassing.count, 248)
//    }
//
//    func testMessagePassingExample() throws {
//        let input = try Self.inputP.parse(Self.example)
//        let passes = Matcher(input.rules).completelyMatchesRule(0)
//
//        let passing = input.messages
//            .filter(passes)
//        XCTAssertEqual(passing.count, 2)
//
//        let simplified = Self.simplifyRules(input.rules)
//        let simplifiedPasses = Matcher(simplified).completelyMatchesRule(0)
//        let simplifiedPassing = input.messages
//            .filter(simplifiedPasses)
//        XCTAssertEqual(simplifiedPassing.count, 2)
//    }
// }
//
// extension Day19Tests {
//    //    static let modifedRules =
//    //        """
//    //        8: 42 | 42 8
//    //        11: 42 31 | 42 11 31
//    //        """
//    static let modifiedRules: [NumberedRule] = [
//        NumberedRule(8, [.many(42, atLeast: 1)]),
//        NumberedRule(11, [.rule(42), .many(11, atLeast: 0), .rule(31)]),
//    ]
//
//    static let input = resourceURL(filename: "Day19Input.txt")!.readContents()!
//
//    static var example: String {
//        """
//        0: 4 1 5
//        1: 2 3 | 3 2
//        2: 4 4 | 5 5
//        3: 4 5 | 5 4
//        4: "a"
//        5: "b"
//
//        ababbb
//        bababa
//        abbbab
//        aaabbb
//        aaaabbb
//        """
//    }
//
//    static var modifiedRulesExample: String {
//        """
//        42: 9 14 | 10 1
//        9: 14 27 | 1 26
//        10: 23 14 | 28 1
//        1: "a"
//        11: 42 31
//        5: 1 14 | 15 1
//        19: 14 1 | 14 14
//        12: 24 14 | 19 1
//        16: 15 1 | 14 14
//        31: 14 17 | 1 13
//        6: 14 14 | 1 14
//        2: 1 24 | 14 4
//        0: 8 11
//        13: 14 3 | 1 12
//        15: 1 | 14
//        17: 14 2 | 1 7
//        23: 25 1 | 22 14
//        28: 16 1
//        4: 1 1
//        20: 14 14 | 1 15
//        3: 5 14 | 16 1
//        27: 1 6 | 14 18
//        14: "b"
//        21: 14 1 | 1 14
//        25: 1 1 | 1 14
//        22: 14 14
//        8: 42
//        26: 14 22 | 1 20
//        18: 15 15
//        7: 14 5 | 1 21
//        24: 14 1
//
//        abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
//        bbabbbbaabaabba
//        babbbbaabbbbbabbbbbbaabaaabaaa
//        aaabbbbbbaaaabaababaabababbabaaabbababababaaa
//        bbbbbbbaaaabbbbaaabbabaaa
//        bbbababbbbaaaaaaaabbababaaababaabab
//        ababaaaaaabaaab
//        ababaaaaabbbaba
//        baabbaaaabbaaaababbaababb
//        abbbbabbbbaaaababbbbbbaaaababb
//        aaaaabbaabaaaaababaa
//        aaaabbaaaabbaaa
//        aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
//        babaaabbbaaabaababbaabababaaab
//        aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
//        """
//    }
//
//    // MARK: - parser
//
//    static let ruleNoP = Parse(input: Substring.self) {
//        Int.parser()
//        ": "
//    }
//
//    static let subRuleP = Parse(input: Substring.self) {
//        OneOf(output: Rule.self) {
//            Parse { Rule.rule($0) } with: {
//                Int.parser()
//            }
//            Parse { Rule.char($0) } with: {
//                "\""
//                First().filter(\.isLetter)
//                "\""
//            }
//        }
//    }
//
//    static let subRulesP = Parse {
//        Many(1...) {
//            subRuleP
//        } separator: {
//            " "
//        }
//    }
//
//    static let ruleP = Parse(input: Substring.self, NumberedRule.init) {
//        ruleNoP
//        Many(1...2) {
//            subRulesP
//        } separator: {
//            " | "
//        }
//    }
//
//    static let rulesP = Many { ruleP } separator: { "\n" }
//
//    static let messageP = Parse(input: Substring.self) { String($0) } with: {
//        Prefix(1...) { $0.isLetter }
//    }
//
//    static let messagesP = Many { messageP } separator: { "\n" }
//
//    static let inputP = Parse { (rules: $0, messages: $1) } with: {
//        rulesP
//        "\n\n"
//        messagesP
//        Skip {
//            Optionally { First().filter(\.isNewline) }
//            End()
//        }
//    }
//
//    func testParseExample() throws {
//        let input = try Self.inputP.parse(Self.example)
//        XCTAssertEqual(input.rules.count, 6)
//        XCTAssertEqual(input.messages.count, 5)
//    }
//
//    func testParseModifiedRulesExample() throws {
//        let input = try Self.inputP.parse(Self.modifiedRulesExample)
//        XCTAssertEqual(input.rules.count, 31)
//        XCTAssertEqual(input.messages.count, 15)
//        XCTAssertEqual(input.messages.last, "aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba")
//    }
//
//    func testParseInput() throws {
//        let input = try Self.inputP.parse(Self.input)
//        XCTAssertEqual(input.rules.count, 136)
//        XCTAssertEqual(input.messages.count, 489)
//    }
// }
