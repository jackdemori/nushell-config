export use completions.nu *
use ../ui [done with-spinner clear-status]

export def is_git_repo [] {
    (do -i { 
        git rev-parse --is-inside-work-tree | str trim } err> /dev/null
    ) == "true"
} 

export def "git history" [
    max_lines: int = 10
] {
    let is_git_repo: bool = is_git_repo

    if not $is_git_repo {
        print $"(ansi red_bold)✗(ansi reset) Not a git repository."
        return
    }

    with-spinner $"Reading git log \(last ($max_lines)\)" {||
        git log --pretty=%h»¦«%s»¦«%aN»¦«%aE»¦«%aD -n $max_lines
            | lines
            | split column "»¦«" commit subject name email date
            | upsert date {|d| $d.date | into datetime}
            | sort-by date
            | reverse
    }
}

export def "git histogram" [
    max_lines: int = 10
] {
    let is_git_repo: bool = is_git_repo

    if not $is_git_repo {
        print $"(ansi red_bold)✗(ansi reset) Not a git repository."
        return
    }

    with-spinner $"Computing commit histogram \(last ($max_lines)\)" {||
        git log --pretty=%h»¦«%aN»¦«%s»¦«%aD
            | lines
            | split column "»¦«" sha1 committer desc merged_at
            | histogram committer merger
            | sort-by merger
            | reverse
    }
}

# Tab-completer for local branch names (used by diff-copy / git clear --ignore).
# Parse `git log --numstat --pretty=format:"%H|%aN"` output into
# a flat list of {hash, author, added, deleted, files} per commit.
def parse-numstat-log [raw: string] {
    mut current: any = null
    mut out: any = []
    for line in ($raw | lines) {
        if ($line | is-empty) { continue }
        let has_tab = ($line | str contains "\t")
        let has_pipe = ($line | str contains "|")
        if $has_pipe and (not $has_tab) {
            if $current != null { $out = ($out | append $current) }
            let parts = ($line | split row -n 2 "|")
            $current = {hash: $parts.0, author: ($parts | get 1? | default ""), added: 0, deleted: 0, files: 0}
        } else if $has_tab and ($current != null) {
            let parts = ($line | split row "\t")
            let a = (try { $parts.0 | into int } catch { 0 })
            let d = (try { $parts.1 | into int } catch { 0 })
            $current = {
                hash: $current.hash
                author: $current.author
                added: ($current.added + $a)
                deleted: ($current.deleted + $d)
                files: ($current.files + 1)
            }
        }
    }
    if $current != null { $out = ($out | append $current) }
    $out
}

# Show per-author contribution stats for a branch.
#
# Returns top 10 authors by commit count by default; use --top N for a
# different cutoff or --all to show everyone. Pipe through `sort-by` to
# rank by a different column.
#
# Columns: commits, distinct file touches, lines added, lines deleted,
# net (added − deleted). Binary diffs count as 0 added/deleted. Merges included.
#
# Examples:
#   git authors                                       → top 10 by commits
#   git authors --top 25                              → top 25
#   git authors --all                                 → everyone
#   git authors main --since "1 year ago"             → main, last year
#   git authors --all | sort-by added --reverse      → rank by lines added
export def "git authors" [
    branch?: string@"nu-complete git-branches"          # Branch or ref to analyze (default: HEAD)
    --since: string                                     # Only include commits after this (e.g. "2024-01-01" or "2 weeks ago")
    --until: string                                     # Only include commits before this
    --top: int = 10                                     # Keep only the top N by commits (default: 10)
    --all                                               # Show all authors (overrides --top)
] {
    if not (is_git_repo) {
        print $"(ansi red_bold)✗(ansi reset) Not a git repository."
        return
    }

    let branch_ref = ($branch | default "HEAD")
    mut flags = []
    if ($since | is-not-empty) { $flags = ($flags | append ["--since" $since]) }
    if ($until | is-not-empty) { $flags = ($flags | append ["--until" $until]) }
    let extra = $flags

    let raw = (with-spinner $"Reading commit log for (ansi cyan)($branch_ref)(ansi reset)" {||
        ^git log $branch_ref --numstat --pretty=format:"%H|%aN" ...$extra | complete
    })
    if $raw.exit_code != 0 {
        print $"(ansi red_bold)✗(ansi reset) git log failed: ($raw.stderr | str trim)"
        return
    }

    let commits = (with-spinner "Parsing commit numstats" {||
        parse-numstat-log $raw.stdout
    })

    let by_author = (with-spinner "Aggregating per author" {||
        $commits
            | group-by author --to-table
            | each {|g|
                {
                    author: $g.author
                    commits: ($g.items | length)
                    files: ($g.items | get files | math sum)
                    added: ($g.items | get added | math sum)
                    deleted: ($g.items | get deleted | math sum)
                    net: (($g.items | get added | math sum) - ($g.items | get deleted | math sum))
                }
            }
            | sort-by commits
            | reverse
    })

    if $all { $by_author } else { $by_author | first $top }
}

export def "nu-complete git-branches" [] {
    if not (is_git_repo) { return [] }
    ^git branch --format "%(refname:short)" | lines | each {|b| $b | str trim }
}

# Copy a git diff between two refs to the macOS clipboard.
# Defaults: base = "main", target = current branch.
export def "git diff-copy" [
    base?: string@"nu-complete git-branches"            # Base ref (default: main)
    target_branch?: string@"nu-complete git-branches"   # Target ref (default: current branch)
] {
    if not (is_git_repo) {
        print $"(ansi red_bold)✗(ansi reset) Not a git repository."
        return
    }

    let base_branch = ($base | default "main")
    let current_branch = (git branch --show-current | str trim)
    let target = ($target_branch | default $current_branch)

    let diff = (with-spinner $"Computing diff (ansi cyan)($base_branch)(ansi reset) (ansi dark_gray)→(ansi reset) (ansi cyan)($target)(ansi reset)" {||
        ^git diff $"($base_branch)..($target)"
    })
    let lines_total = ($diff | lines | length)
    let files_changed = ($diff | lines | where $it =~ '^diff --git' | length)

    if $files_changed == 0 {
        print $"(ansi yellow_bold)⚠(ansi reset) No differences between (ansi cyan)($base_branch)(ansi reset) and (ansi cyan)($target)(ansi reset)."
        return
    }

    $diff | pbcopy

    done $"Copied (ansi cyan)($base_branch)(ansi reset) (ansi dark_gray)→(ansi reset) (ansi cyan)($target)(ansi reset) to clipboard (ansi dark_gray)\(($files_changed) files, ($lines_total) lines\)(ansi reset)."
}

def print-git-clear-help [] {
    print ""
    print $"(ansi cyan_bold)git clear(ansi reset) (ansi dark_gray)— delete local branches that aren't protected(ansi reset)"
    print ""
    print "Always keeps main and the currently checked-out branch. Pass branch names"
    print "after --ignore to keep more. Deletes worktrees attached to a branch first."
    print ""
    print $"(ansi default_bold)Usage:(ansi reset)"
    print $"  > (ansi green)git clear(ansi reset) [(ansi yellow)--ignore(ansi reset) <branch> ...] [(ansi yellow)--dry-run(ansi reset)]"
    print ""
    print $"(ansi default_bold)Flags:(ansi reset)"
    print $"  (ansi yellow)--ignore, -i(ansi reset)    Additional branches to keep (space-separated names follow)"
    print $"  (ansi yellow)--dry-run(ansi reset)       Preview without deleting"
    print $"  (ansi yellow)--whatif(ansi reset)        Alias for --dry-run"
    print $"  (ansi yellow)--help, -h(ansi reset)      Show this help"
    print ""
    print $"(ansi default_bold)Examples:(ansi reset)"
    print $"  (ansi green)git clear(ansi reset)                                        (ansi dark_gray)# delete all non-protected(ansi reset)"
    print $"  (ansi green)git clear --ignore(ansi reset) feat/1234                     (ansi dark_gray)# also keep feat/1234(ansi reset)"
    print $"  (ansi green)git clear --ignore(ansi reset) feat/1234 old-topic (ansi green)--dry-run(ansi reset)  (ansi dark_gray)# preview(ansi reset)"
    print ""
}

# Context-aware completer for wrapped git clear: after --ignore (or -i),
# suggest local branch names; otherwise suggest flags.
export def "nu-complete git-clear-args" [context: string] {
    if (is_git_repo) {
        ^git branch --format "%(refname:short)"
        | lines
        | each {|b| {value: ($b | str trim), description: "local branch"} }
    } else { [] }
}

# Delete local branches that aren't protected. Always keeps main and the
# currently checked-out branch; use --ignore <names...> to keep more.
# Deletes any worktrees attached to a branch before removing it.
#
# Examples:
#   git clear                                       → delete all non-protected
#   git clear --ignore feat/1234                    → also keep feat/1234
#   git clear --ignore feat/1234 old --dry-run      → preview, keeping two extra
export def --wrapped "git clear" [
    --dry-run                                           # Preview which branches would be deleted
    --whatif                                            # Alias for --dry-run
    --ignore (-i)                                       # Treat following positional args as branches to keep
    ...args: string@"nu-complete git-clear-args"        # Branch names (only valid after --ignore)
]: nothing -> nothing {
    if (not $ignore) and (not ($args | is-empty)) {
        print $"(ansi red_bold)✗(ansi reset) Unexpected argument\(s\): (ansi yellow)($args | str join ' ')(ansi reset)"
        print $"  (ansi dark_gray)Did you mean (ansi yellow)--ignore(ansi reset) (ansi dark_gray)($args | str join ' ')?(ansi reset)"
        return
    }
    let keep = if $ignore { $args } else { [] }
    let preview = ($dry_run or $whatif)
    if not (is_git_repo) {
        print $"(ansi red_bold)✗(ansi reset) Not a git repository."
        return
    }

    let current_branch = (git branch --show-current | str trim)
    let always_protected = (["main" $current_branch] | uniq | where {|b| $b | is-not-empty })
    let ignored = ($keep | uniq | where {|b| $b | is-not-empty })
    let all_local = (git branch --format "%(refname:short)" | lines | each {|b| $b | str trim })
    let branches_to_delete = ($all_local | where {|b| (not ($b in $always_protected)) and (not ($b in $ignored)) })

    if ($branches_to_delete | is-empty) {
        print $"(ansi green_bold)✓(ansi reset) Nothing to delete — all branches are protected."
        return
    }

    let header = if $dry_run {
        $"(ansi yellow_bold)⚠ Dry-run(ansi reset) (ansi dark_gray)— would delete ($branches_to_delete | length) branch\(es\):(ansi reset)"
    } else {
        $"(ansi red_bold)⚠ Will delete ($branches_to_delete | length) branch\(es\):(ansi reset)"
    }
    print $header
    for b in $branches_to_delete {
        print $"  (ansi red)✗(ansi reset) (ansi cyan)($b)(ansi reset)"
    }

    print ""
    print $"(ansi default_bold)Protected:(ansi reset) (ansi dark_gray)\(always kept: main, current branch\)(ansi reset)"
    for b in $always_protected {
        let tag = if $b == $current_branch { $" (ansi dark_gray)\(current\)(ansi reset)" } else { "" }
        print $"  (ansi green)•(ansi reset) (ansi cyan)($b)(ansi reset)($tag)"
    }

    if ($ignored | is-not-empty) {
        print ""
        print $"(ansi default_bold)Ignored:(ansi reset) (ansi dark_gray)\(passed as args\)(ansi reset)"
        for b in $ignored {
            let exists = ($b in $all_local)
            let tag = if $exists { "" } else { $" (ansi yellow)\(not found\)(ansi reset)" }
            print $"  (ansi blue)•(ansi reset) (ansi cyan)($b)(ansi reset)($tag)"
        }
    }

    if $preview { return }

    print ""
    let answer = (input $"(ansi yellow)Continue? [y/N] (ansi reset)" | str downcase | str trim)
    if $answer != "y" and $answer != "yes" {
        print $"(ansi yellow_bold)⚠(ansi reset) Aborted."
        return
    }

    with-spinner $"Deleting ($branches_to_delete | length) branch\(es\)" {||
        for branch in $branches_to_delete {
            let worktree = (git worktree list --porcelain
                | split row "\n\n"
                | where ($it =~ $"branch refs/heads/($branch)")
                | if ($in | is-empty) { "" } else { $in | first })
            if ($worktree | is-not-empty) {
                let wt_path = ($worktree | lines | first | str replace "worktree " "")
                git worktree remove --force $wt_path out+err> /dev/null
            }
            git branch -D $branch out+err> /dev/null
        }
    }
    done $"Deleted ($branches_to_delete | length) branch\(es\)."
}