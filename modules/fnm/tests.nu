# Coverage tests for modules/fnm/completions.nu.
#
# For each known fnm subcommand, parse `fnm <cmd> --help` and assert every long
# flag the CLI advertises is present in the extern signature. Subcommand
# discovery parses the top-level `fnm --help` "Commands:" section.
#
# Run: `nu modules/fnm/tests.nu`  (exit 1 if anything fails).
# Requires: fnm installed on PATH.

use ./completions.nu *
use ../ui [has-command]

const UNIVERSAL = [--help -h]

# Parse a clap-style help output (fnm uses clap). Flag lines look like:
#   `      --lts` or `      --foo <FOO>` or `  -f, --foo`
# with descriptions on subsequent indented lines. Real flag lines have at most
# ~10 leading spaces and start with a dash.
def parse-help-flags [help_output: string] {
    $help_output | lines
        | where {|line| ($line =~ '^ {2,10}-[\w-]') }
        | each {|line|
            # Drop the value placeholder like `<FOO>` and trailing description.
            let head = ($line | str trim | split row -r '\s+' | where {|t| $t | str starts-with "-" })
            $head | each {|t| $t | str replace -r ',$' '' }
        }
        | where {|group| not ($group | is-empty) }
}

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

def check-coverage [cmd: string, --ignore: list<string> = []] {
    let parts = ($cmd | split row ' ' | skip 1)
    let help = (do { ^fnm ...$parts --help } | complete)
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

const COMMANDS = [
    "fnm"
    "fnm list-remote"
    "fnm list"
    "fnm install"
    "fnm use"
    "fnm env"
    "fnm completions"
    "fnm alias"
    "fnm unalias"
    "fnm default"
    "fnm current"
    "fnm exec"
    "fnm uninstall"
]

# Parse the top-level `fnm --help` "Commands:" section to discover subcommands.
# Format: `  name  description [aliases: x]`
def discover-fnm-subcommands [] {
    let raw = (do { ^fnm --help } | complete)
    if $raw.exit_code != 0 { return [] }
    $raw.stdout | lines
        | skip until {|l| $l | str starts-with "Commands:" }
        | skip 1
        | take while {|l| not ($l | str trim | is-empty) }
        | where ($it =~ '^  \S')
        | each {|l| $l | str trim | split row ' ' | first }
        | where ($it != "help")  # `fnm help` is built-in clap output, no extern needed
}

def check-no-new-subcommands [] {
    let known = (scope commands | where name =~ '^fnm' | get name)
    let discovered = (discover-fnm-subcommands)
    let missing = $discovered | where {|sub| $"fnm ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new subcommand\(s\): ($missing | str join ', ')"}
    }
}

def main [] {
    if not (has-command fnm) {
        print $"(ansi yellow_bold)⚠(ansi reset)  fnm not on PATH; skipping coverage tests"
        return
    }

    print $"(ansi default_dimmed)Flag coverage(ansi reset)"
    let cov_results = $COMMANDS | par-each {|cmd|
        try {
            check-coverage $cmd
            {cmd: $cmd, ok: true, msg: null}
        } catch {|e|
            {cmd: $cmd, ok: false, msg: $e.msg}
        }
    } | sort-by cmd
    for r in $cov_results {
        if $r.ok {
            print $"(ansi green_bold)✓(ansi reset) ($r.cmd)"
        } else {
            print $"(ansi red_bold)✗(ansi reset) ($r.cmd): ($r.msg)"
        }
    }

    print ""
    print $"(ansi default_dimmed)Subcommand discovery(ansi reset)"
    let disc_result = try {
        check-no-new-subcommands
        print $"(ansi green_bold)✓(ansi reset) fnm"
        {ok: true}
    } catch {|e|
        print $"(ansi red_bold)✗(ansi reset) fnm: ($e.msg)"
        {ok: false}
    }

    let total = (($cov_results | length) + 1)
    let failed_count = (($cov_results | where ok == false | length) + (if $disc_result.ok { 0 } else { 1 }))
    print ""
    if $failed_count == 0 {
        print $"(ansi green_bold)All ($total) tests passed(ansi reset)"
    } else {
        print $"(ansi red_bold)($failed_count)/($total) tests failed(ansi reset)"
        exit 1
    }
}
