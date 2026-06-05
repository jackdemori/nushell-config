# Coverage tests for modules/dotnet/completions.nu.
#
# For each known leaf extern, parse the live `dotnet <cmd> --help` output and
# assert every long flag the CLI advertises is present in the extern signature.
# Flag aliases (e.g. `--sc, --self-contained`) are treated as a group — if any
# name in the group is in the extern, the group counts as covered.
#
# Run: `nu modules/dotnet/tests.nu` (exit code 1 if anything fails).
# Requires: dotnet SDK installed on PATH.

use ./completions.nu *

# Universal flags every dotnet command accepts — never required in externs.
const UNIVERSAL = [--help -h -? /h /?]

# Parse `dotnet <cmd> --help` output into a list of alias groups.
# Each group is the set of names that refer to the same flag (e.g.
# ["--sc", "--self-contained"]). Returns: list<list<string>>.
#
# Filtering: only lines with 2-8 leading spaces followed by `-` are flag
# definitions; deeper indentation is a continuation or usage example.
# Normalisation: single-dash multi-char names (MSBuild style, e.g. `-verbosity`)
# are also treated as their `--verbosity` form so they match our externs.
def parse-help-flags [help_output: string] {
    $help_output | lines
        | where {|line| ($line =~ '^ {2,8}-') }
        | each {|line|
            let head = ($line | str trim | split row -r '\s{2,}' | first)
            $head | split row -r ',\s*'
                | each {|t| $t | split row ' ' | first | str trim }
                | where {|t| ($t | str starts-with "-") }
                | each {|t|
                    # Expand `-verbosity` → both `-verbosity` and `--verbosity`
                    # (single-dash multi-char is an MSBuild alias of the --form).
                    if (($t | str starts-with "--") or ($t | str length) <= 2) {
                        [$t]
                    } else {
                        [$t, $"-($t)"]
                    }
                }
                | flatten
        }
        | where {|group| not ($group | is-empty) }
}

# Extract every flag name declared in the extern signature (both long `--xxx`
# and short `-x` forms). For short-only flags the long form is empty.
def extern-flags [cmd: string] {
    let sigs = (scope commands | where name == $cmd | get signatures? | first | default {})
    if ($sigs | is-empty) {
        error make {msg: $"extern not found: ($cmd)"}
    }
    $sigs | values | first
        | where parameter_type in [named switch]
        | each {|p|
            let long = if ($p.parameter_name | is-not-empty) { [$"--($p.parameter_name)"] } else { [] }
            let short = if ($p.short_flag | is-not-empty) { [$"-($p.short_flag)"] } else { [] }
            $long | append $short
        }
        | flatten
}

# Assert coverage: every alias group from help has at least one member in the extern.
# `SHELL=bash` is forced because System.CommandLine eagerly evaluates default
# values for `dotnet completions script <shell>` before `--help` short-circuits;
# when SHELL is `nu` the lookup throws and `--help` exits non-zero.
def check-coverage [cmd: string, --ignore: list<string> = []] {
    let help = (with-env {SHELL: "bash"} { ^dotnet ...($cmd | split row ' ' | skip 1) --help } | complete)
    if $help.exit_code != 0 {
        error make {msg: $"`($cmd) --help` failed: ($help.stderr | str trim)"}
    }
    let groups = (parse-help-flags $help.stdout)
    let actual = (extern-flags $cmd)
    let ignored = ($UNIVERSAL | append $ignore)

    let missing = $groups | where {|group|
        let g = ($group | where ($it not-in $ignored))
        if ($g | is-empty) { false } else {
            not ($g | any {|name| $name in $actual })
        }
    }

    if not ($missing | is-empty) {
        let pretty = ($missing | each {|g| $g | str join '/' } | str join ', ')
        error make {msg: $"missing flag groups: ($pretty)"}
    }
}

# Parents to walk for subcommand discovery. Every command `dotnet complete`
# reports under each of these must have a corresponding extern — otherwise
# dotnet has added something we haven't documented yet.
#
# `dotnet new` is intentionally omitted: its `complete` output mixes template
# short-names (apicontroller, blazor, ...) with subcommands (install, list,
# search, ...) and the two are indistinguishable from the outside.
const SUBCOMMAND_PARENTS = [
    "dotnet"
    "dotnet tool"
    "dotnet workload"
    "dotnet nuget"
    "dotnet nuget trust"
    "dotnet package"
    "dotnet reference"
    "dotnet solution"
    "dotnet sln"
    "dotnet build-server"
    "dotnet sdk"
    "dotnet project"
    "dotnet completions"
    "dotnet format"
]

# Top-level extras: bundled-tool commands that ship with the SDK but don't
# appear under `dotnet complete "dotnet "` (they're not part of the core
# completion engine). Keep this list in sync with `dotnet help`.
const TOP_LEVEL_EXTRAS = [
    "dotnet dev-certs"
    "dotnet fsi"
    "dotnet user-jwts"
    "dotnet user-secrets"
    "dotnet watch"
    "dotnet purge"        # custom command from modules/dotnet/uninstall.nu
]

def discover-subcommands [path: string] {
    let raw = (with-env {SHELL: "bash"} { ^dotnet complete $"($path) " } | complete)
    if $raw.exit_code != 0 { return [] }
    $raw.stdout | lines
        | each {|l| $l | str trim }
        | where ($it | is-not-empty)
        | where {|l| not ($l | str starts-with "-") }
        | where {|l| not ($l | str starts-with "/") }
}

def check-no-new-subcommands [parent: string] {
    let known = (scope commands | where name =~ '^dotnet' | get name)
    let discovered = (discover-subcommands $parent)
    let missing = $discovered | where {|sub| $"($parent) ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new subcommand\(s\) under `($parent)`: ($missing | str join ', ')"}
    }
}

# Leaf externs whose flag set should match `dotnet <cmd> --help`.
# Pure pass-through externs (msbuild, vstest, dev-certs, fsi, user-jwts,
# user-secrets) are intentionally omitted — they forward all args.
# Parent externs (e.g. `dotnet tool`) are skipped — they only declare a
# subcommand positional, not the underlying CLI flags.
const COMMANDS = [
    "dotnet build"
    "dotnet run"
    "dotnet test"
    "dotnet publish"
    "dotnet clean"
    "dotnet restore"
    "dotnet pack"
    "dotnet new"
    "dotnet new install"
    "dotnet new uninstall"
    "dotnet new list"
    "dotnet new search"
    "dotnet new create"
    "dotnet new details"
    "dotnet new update"
    "dotnet format"
    "dotnet watch"
    "dotnet solution add"
    "dotnet solution list"
    "dotnet solution remove"
    "dotnet solution migrate"
    "dotnet sln add"
    "dotnet sln list"
    "dotnet sln remove"
    "dotnet sln migrate"
    "dotnet package add"
    "dotnet package list"
    "dotnet package remove"
    "dotnet package search"
    "dotnet package download"
    "dotnet package update"
    "dotnet reference add"
    "dotnet reference list"
    "dotnet reference remove"
    "dotnet nuget push"
    "dotnet nuget delete"
    "dotnet nuget locals"
    "dotnet nuget sign"
    "dotnet nuget verify"
    "dotnet nuget why"
    "dotnet nuget trust"
    "dotnet tool install"
    "dotnet tool uninstall"
    "dotnet tool update"
    "dotnet tool list"
    "dotnet tool run"
    "dotnet tool search"
    "dotnet tool restore"
    "dotnet tool exec"
    "dotnet tool execute"
    "dotnet workload install"
    "dotnet workload update"
    "dotnet workload uninstall"
    "dotnet workload list"
    "dotnet workload search"
    "dotnet workload repair"
    "dotnet workload restore"
    "dotnet workload clean"
    "dotnet workload config"
    "dotnet workload history"
    "dotnet build-server shutdown"
    "dotnet store"
    "dotnet sdk check"
    "dotnet completions script"
    "dotnet project convert"
]

def main [] {
    if (which dotnet | is-empty) {
        print $"(ansi yellow_bold)⚠(ansi reset)  dotnet not on PATH; skipping coverage tests"
        return
    }

    print $"(ansi default_dimmed)Flag coverage(ansi reset)"
    let cov_results = $COMMANDS | each {|cmd|
        try {
            check-coverage $cmd
            print $"(ansi green_bold)✓(ansi reset) ($cmd)"
            {ok: true}
        } catch {|e|
            print $"(ansi red_bold)✗(ansi reset) ($cmd): ($e.msg)"
            {ok: false}
        }
    }

    print ""
    print $"(ansi default_dimmed)Subcommand discovery(ansi reset)"
    let disc_results = $SUBCOMMAND_PARENTS | each {|parent|
        try {
            check-no-new-subcommands $parent
            print $"(ansi green_bold)✓(ansi reset) ($parent)"
            {ok: true}
        } catch {|e|
            print $"(ansi red_bold)✗(ansi reset) ($parent): ($e.msg)"
            {ok: false}
        }
    }

    let total = (($cov_results | length) + ($disc_results | length))
    let failed_count = (($cov_results | append $disc_results) | where ok == false | length)
    print ""
    if $failed_count == 0 {
        print $"(ansi green_bold)All ($total) tests passed(ansi reset)"
    } else {
        print $"(ansi red_bold)($failed_count)/($total) tests failed(ansi reset)"
        exit 1
    }
}
