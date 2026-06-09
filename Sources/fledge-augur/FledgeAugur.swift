@preconcurrency import Foundation
import ArgumentParser
import AugurKit

/// `fledge augur` — runs augur's deterministic change-risk engine through fledge.
///
/// This plugin links `AugurKit` directly, so no external `augur` binary is
/// required. It exposes the two signals an agent loop or CI gate cares about:
/// a human/JSON `check` and a non-zero-on-risk `gate`.
@main
struct FledgeAugur: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fledge-augur",
        abstract: "🔮 Graded trust for changes — how risky is this diff, and should a human look?",
        discussion: """
        Scores a git diff with deterministic signals (churn, coupling, test gaps, \
        sensitive paths, ownership, and revert history) and returns a verdict: \
        proceed, review, or block. No API key or LLM required.
        """,
        version: "0.1.0",
        subcommands: [Check.self, Gate.self],
        defaultSubcommand: Check.self
    )
}

// MARK: - Shared options

/// Scope + repository selection, shared by `check` and `gate`.
struct ScopeOptions: ParsableArguments {
    @Option(name: .long, help: "A git range to assess, e.g. 'main..HEAD'.")
    var range: String?

    @Flag(name: .long, help: "Assess staged changes (git diff --cached).")
    var staged = false

    @Option(name: [.long, .customShort("C")], help: "Path to the repository.")
    var path: String = "."

    /// Maps the flags to an `AugurKit` `DiffScope`.
    func resolvedScope() -> DiffScope {
        if let range {
            return .range(range)
        }
        if staged {
            return .staged
        }
        return .workingTree
    }

    /// Builds an `Augur` bound to a validated `GitRepository` at `path`.
    /// - Returns: The engine entry point and the resolved scope.
    /// - Throws: `AugurError.notARepository` when `path` is not a git work tree.
    func makeAugur() throws -> (augur: Augur, scope: DiffScope) {
        let repository = GitRepository(path: path)
        try repository.validate()
        return (Augur(probe: repository), resolvedScope())
    }
}

// MARK: - check

/// Assess a change and print a verdict (always exits 0).
struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Assess a change and print a risk verdict."
    )

    @OptionGroup var scope: ScopeOptions

    @Flag(name: .long, help: "Emit machine-readable JSON.")
    var json = false

    @Flag(name: [.long, .customShort("v")], help: "Show every contributing signal.")
    var verbose = false

    func run() async throws {
        let (augur, diffScope) = try scope.makeAugur()
        do {
            let assessment = try augur.assess(scope: diffScope)
            if json {
                print(try assessment.jsonString())
            } else {
                print(Reporter.render(assessment, verbose: verbose))
            }
        } catch AugurError.noChanges {
            if json {
                print("{\"verdict\":\"proceed\",\"riskScore\":0,\"files\":[],\"excludedPaths\":[]}")
            } else {
                print("augur · no changes to assess")
            }
        }
    }
}

// MARK: - gate

/// Exit non-zero if the verdict meets or exceeds a threshold (for CI / agent loops).
struct Gate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Exit non-zero if the verdict meets or exceeds a threshold (for CI / agent loops)."
    )

    @OptionGroup var scope: ScopeOptions

    @Option(name: .long, help: "Threshold verdict: proceed, review, or block.")
    var threshold: String = "review"

    @Flag(name: .long, help: "Emit machine-readable JSON.")
    var json = false

    func run() async throws {
        guard let limit = Verdict(rawValue: threshold) else {
            throw ValidationError("threshold must be one of: proceed, review, block")
        }
        let (augur, diffScope) = try scope.makeAugur()
        let assessment: Assessment
        do {
            assessment = try augur.assess(scope: diffScope)
        } catch AugurError.noChanges {
            return  // nothing to gate
        }
        if json {
            print(try assessment.jsonString())
        } else {
            print("augur gate · \(assessment.verdict.rawValue) (risk \(Int(assessment.riskScore.rounded())))")
        }
        if assessment.verdict >= limit {
            throw ExitCode(1)
        }
    }
}
