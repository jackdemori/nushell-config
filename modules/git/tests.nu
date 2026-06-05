# Coverage tests for modules/git/completions.nu.
#
# For each documented git command, parse `git <cmd> -h` and assert every long
# flag the CLI advertises is in our extern signature. Subcommand discovery is
# limited to the parent groups we declare (config / bisect / stash / remote /
# worktree); enforcing every git porcelain command is out of scope.
#
# Run: `nu modules/git/tests.nu`  (exit 1 if anything fails).
# Requires: git installed on PATH.

use ./completions.nu *

const UNIVERSAL = [--help -h]

# Parse a `git <cmd> -h` output into alias groups.
# Git's flag lines have 2-8 leading spaces followed by `-`. Value placeholders
# of the forms `[=<x>]`, `[=(a|b)]`, `<x>`, `=<x>` after the flag name are
# stripped. `--[no-]X` is expanded to the pair `[--X, --no-X]`.
def parse-help-flags [help_output: string] {
    $help_output | lines
        | where {|line| ($line =~ '^ {2,8}-') }
        | each {|line|
            let head = ($line | str trim | split row -r '\s{2,}' | first)
            $head | split row -r ',\s*'
                | each {|t| $t | split row ' ' | first | str trim }
                | each {|t| $t | str replace -r '\[=.*$' '' | str replace -r '=<.*$' '' | str replace -r '\[<.*$' '' | str replace -r '<.*$' '' }
                | where {|t| ($t | str starts-with "-") }
                # Drop synthetic shorts like `-NUM` / `-n<n>` that git uses as
                # value placeholders rather than actual flag names.
                | where {|t| not ($t =~ '^-[A-Z][A-Z]+$') }
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
    let parts = ($cmd | split row ' ' | skip 1)
    let help = (do { ^git ...$parts -h } | complete)
    # git emits help to stderr and returns exit 129; that's fine. Bail only on
    # truly empty output (which usually means an unknown command).
    let text = ($help.stdout + $help.stderr)
    # Some real subcommands (e.g. `git bisect run`, `git bisect visualize`)
    # emit no help text at all. Treat that as nothing to check rather than
    # a failure — there's no flag group list to compare against.
    if ($text | str trim | is-empty) { return }
    let groups = (parse-help-flags $text)
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

# Real git commands we declare externs for. Custom helpers in modules/git/mod.nu
# (authors, clear, diff-copy, histogram, history) are excluded — they're nu
# defs, not wrappers around `git <name>`.
const COMMANDS = [
    "git add"
    "git branch"
    "git checkout"
    "git cherry-pick"
    "git clone"
    "git commit"
    "git diff"
    "git fetch"
    "git grep"
    "git init"
    "git log"
    "git merge"
    "git prune"
    "git pull"
    "git push"
    "git rebase"
    "git reflog"
    "git reset"
    "git restore"
    "git rm"
    "git status"
    "git switch"
    "git tag"
    "git bisect"
    "git bisect bad"
    "git bisect good"
    "git bisect log"
    "git bisect next"
    "git bisect replay"
    "git bisect reset"
    "git bisect run"
    "git bisect skip"
    "git bisect start"
    "git bisect terms"
    "git bisect visualize"
    "git config"
    "git config edit"
    "git config get"
    "git config list"
    "git config remove-section"
    "git config rename-section"
    "git config set"
    "git config unset"
    "git remote"
    "git remote add"
    "git remote get-url"
    "git remote prune"
    "git remote remove"
    "git remote rename"
    "git remote set-branches"
    "git remote set-head"
    "git remote set-url"
    "git stash"
    "git stash apply"
    "git stash branch"
    "git stash clear"
    "git stash create"
    "git stash drop"
    "git stash list"
    "git stash pop"
    "git stash push"
    "git stash save"
    "git stash show"
    "git stash store"
    "git worktree"
    "git worktree add"
    "git worktree list"
    "git worktree lock"
    "git worktree move"
    "git worktree prune"
    "git worktree remove"
    "git worktree repair"
    "git worktree unlock"
]

# Parents to walk for subcommand discovery.
const SUBCOMMAND_PARENTS = [
    "git config"
    "git bisect"
    "git stash"
    "git remote"
    "git worktree"
]

# Parse `git <parent> -h` output and extract subcommand names from the usage
# block. Lines look like `usage: git stash list [...]` or `   or: git stash show`.
def discover-subcommands [parent: string] {
    let parts = ($parent | split row ' ' | skip 1)
    let raw = (do { ^git ...$parts -h } | complete)
    let text = ($raw.stdout + $raw.stderr)
    let prefix = $"git ($parts | str join ' ')"
    $text | lines
        | where {|l| (($l | str trim) | str starts-with $"usage: ($prefix) ") or (($l | str trim) | str starts-with $"or: ($prefix) ") }
        | each {|l|
            # Strip the `usage:`/`or:` prefix and the leading `git <parent> `
            let stripped = ($l | str trim | str replace -r '^(usage|or):\s*' '' | str replace $"($prefix) " "")
            $stripped | split row ' ' | first | str trim
        }
        | where ($it | str trim | is-not-empty)
        | where {|sub| not ($sub | str starts-with "[") }
        | where {|sub| not ($sub | str starts-with "<") }
        | where {|sub| not ($sub | str starts-with "(") }
        | uniq
}

def check-no-new-subcommands [parent: string] {
    let known = (scope commands | where name =~ '^git' | get name)
    let discovered = (discover-subcommands $parent)
    let missing = $discovered | where {|sub| $"($parent) ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new subcommand\(s\) under `($parent)`: ($missing | str join ', ')"}
    }
}

def main [] {
    if (which git | is-empty) {
        print $"(ansi yellow_bold)⚠(ansi reset)  git not on PATH; skipping coverage tests"
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
