# Coverage tests for modules/brew/completions.nu.
#
# For each documented brew command, parse the live `brew <cmd> --help` and
# assert every long-flag the CLI advertises is in our extern signature.
# Subcommand discovery walks `brew commands` (top level) and the `Subcommands:`
# section of each parent's help (services / bundle / analytics / completions).
#
# Run: `nu modules/brew/tests.nu`  (exit 1 if anything fails).
# Requires: Homebrew installed on PATH.

use ./completions.nu *

const UNIVERSAL = [--help -h]

# Parse a `brew help <cmd>` output into alias groups.
# Same indent-based filter as the dotnet parser — real flag lines have
# 2–8 leading spaces followed by `-`; deeper indentation is a wrapped
# description line.
#
# Special: `--[no-]X` is brew shorthand for the pair `--X` and `--no-X`. The
# parser expands it so externs that declare both names match.
def parse-help-flags [help_output: string] {
    $help_output | lines
        | where {|line| ($line =~ '^ {2,8}-') }
        | each {|line|
            let head = ($line | str trim | split row -r '\s{2,}' | first)
            $head | split row -r ',\s*'
                | each {|t| $t | split row ' ' | first | str trim }
                | where {|t| ($t | str starts-with "-") }
                | each {|t|
                    if ($t =~ '^--\[no-\]') {
                        let base = ($t | str replace -r '^--\[no-\]' '')
                        [$"--($base)", $"--no-($base)"]
                    } else {
                        [$t]
                    }
                }
                | flatten
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
    # `brew help <cmd>` works universally; `brew <cmd> --help` doesn't for some
    # commands (which-formula rejects --help; update-if-needed returns nothing).
    let parts = ($cmd | split row ' ' | skip 1)
    let help = (do { ^brew help ...$parts } | complete)
    if $help.exit_code != 0 {
        error make {msg: $"`brew help ($parts | str join ' ')` failed: ($help.stderr | str trim)"}
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

# User-facing brew built-in commands that should each have an extern.
# Developer/internal commands (mcp-server, gist-logs, developer, *-sync, etc.)
# are deliberately omitted — see SUBCOMMAND_SKIP_TOP.
const COMMANDS = [
    "brew install"
    "brew uninstall"
    "brew reinstall"
    "brew upgrade"
    "brew list"
    "brew leaves"
    "brew outdated"
    "brew autoremove"
    "brew missing"
    "brew cleanup"
    "brew info"
    "brew desc"
    "brew deps"
    "brew uses"
    "brew home"
    "brew options"
    "brew log"
    "brew search"
    "brew pin"
    "brew unpin"
    "brew link"
    "brew unlink"
    "brew tap"
    "brew untap"
    "brew tap-info"
    "brew trust"
    "brew untrust"
    "brew update"
    "brew update-if-needed"
    "brew update-reset"
    "brew migrate"
    "brew fetch"
    "brew doctor"
    "brew config"
    "brew services"
    "brew services start"
    "brew services stop"
    "brew services restart"
    "brew services run"
    "brew services list"
    "brew services kill"
    "brew services info"
    "brew services cleanup"
    "brew bundle"
    "brew bundle install"
    "brew bundle dump"
    "brew bundle cleanup"
    "brew bundle check"
    "brew bundle list"
    "brew bundle exec"
    "brew bundle env"
    "brew bundle edit"
    "brew bundle add"
    "brew bundle remove"
    "brew bundle sh"
    "brew analytics"
    "brew analytics state"
    "brew analytics on"
    "brew analytics off"
    "brew analytics regenerate-uuid"
    "brew completions"
    "brew completions state"
    "brew completions link"
    "brew completions unlink"
    "brew shellenv"
    "brew formulae"
    "brew casks"
    "brew alias"
    "brew unalias"
    "brew commands"
    "brew command"
    "brew help"
    "brew docs"
    "brew exec"
    "brew postinstall"
    "brew which-formula"
    "brew readall"
]

# Parents to walk for subcommand discovery. New entries added here will be
# automatically checked against our externs.
const SUBCOMMAND_PARENTS = [
    "brew services"
    "brew bundle"
    "brew analytics"
    "brew completions"
]

# Top-level commands we intentionally don't expose (internal helpers, dev
# integrations, MCP server, etc.). Plus path-flag entries from `brew commands`
# (--cache, --version, ...) which live as flags on the top-level brew extern.
const SUBCOMMAND_SKIP_TOP = [
    "as-console-user"
    "command-not-found-init"
    "developer"
    "gist-logs"
    "mcp-server"
    "nodenv-sync"
    "pyenv-sync"
    "rbenv-sync"
    "setup-ruby"
    "source"
    "tab"
    "version-install"
]

def discover-top-level [] {
    ^brew commands | lines
        | skip until {|l| $l == "==> Built-in commands" }
        | skip 1
        | take while {|l| not ($l | str starts-with "==>") }
        | where ($it | str trim | is-not-empty)
        | each {|l| $l | str trim }
        | where {|c| not ($c | str starts-with "-") }
        | where {|c| $c not-in $SUBCOMMAND_SKIP_TOP }
}

def discover-parent-subcommands [parent: string] {
    let parts = ($parent | split row ' ' | skip 1)
    let raw = (do { ^brew help ...$parts } | complete)
    if $raw.exit_code != 0 { return [] }
    $raw.stdout | lines
        | skip until {|l| $l | str starts-with "Subcommands:" }
        | skip 1
        | take while {|l| not ($l | str trim | is-empty) }
        | where ($it =~ '^  \w[\w-]*:')
        | each {|l| $l | str trim | str replace -r ':.*$' '' }
}

def check-top-level-coverage [] {
    let known = (scope commands | where name =~ '^brew' | get name)
    let discovered = (discover-top-level)
    let missing = $discovered | where {|sub| $"brew ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new top-level command\(s\): ($missing | str join ', ')"}
    }
}

def check-no-new-subcommands [parent: string] {
    let known = (scope commands | where name =~ '^brew' | get name)
    let discovered = (discover-parent-subcommands $parent)
    let missing = $discovered | where {|sub| $"($parent) ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new subcommand\(s\) under `($parent)`: ($missing | str join ', ')"}
    }
}

def main [] {
    if (which brew | is-empty) {
        print $"(ansi yellow_bold)⚠(ansi reset)  brew not on PATH; skipping coverage tests"
        return
    }

    print $"(ansi default_dimmed)Flag coverage(ansi reset)"
    # Run --help invocations in parallel — each takes ~400ms.
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
    let disc_results = ["brew"] | append $SUBCOMMAND_PARENTS | each {|parent|
        try {
            if $parent == "brew" {
                check-top-level-coverage
            } else {
                check-no-new-subcommands $parent
            }
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
