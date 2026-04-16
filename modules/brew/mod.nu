# Export/import your user-installed Homebrew packages (formulae + casks).
# The export deliberately skips transitive dependencies so that on import,
# `brew` installs them as auto-deps — so `brew uninstall <pkg> && brew autoremove`
# properly cleans them up later.

use ../ui [step done clear-status]

def check-brew [] {
    if (which brew | is-empty) {
        print $"(ansi red_bold)✗(ansi reset) Homebrew isn't installed (or not on PATH)."
        return false
    }
    true
}

# Write a portable Brewfile of user-requested packages (formulae + casks + taps).
# Transitive dependencies are excluded so they remain auto-marked on re-install,
# which lets `brew uninstall <pkg> && brew autoremove` clean up cleanly later.
#
# Examples:
#   brew export                           → ./Brewfile
#   brew export ~/dotfiles/Brewfile       → custom path
#   brew export --force                   → overwrite without prompting
export def "brew export" [
    path: path = "./Brewfile"                           # Destination file
    --force                                             # Overwrite if file exists
] {
    if not (check-brew) { return }

    let target = ($path | path expand)
    if ($target | path exists) and (not $force) {
        print $"(ansi yellow_bold)⚠(ansi reset) (ansi cyan)($target)(ansi reset) already exists. Pass (ansi yellow)--force(ansi reset) to overwrite."
        return
    }

    step --tick 0 "Listing taps"
    let taps = (^brew tap | lines | each {|t| $t | str trim } | where ($it | is-not-empty))

    step --tick 2 "Listing user-installed formulae"
    let formulae = (^brew list --installed-on-request | lines | each {|f| $f | str trim } | where ($it | is-not-empty) | sort)

    step --tick 4 "Listing casks"
    let casks = (^brew list --cask | lines | each {|c| $c | str trim } | where ($it | is-not-empty) | sort)

    step --tick 6 "Writing Brewfile"
    let tap_lines = ($taps | each {|t| $'tap "($t)"' })
    let brew_lines = ($formulae | each {|f| $'brew "($f)"' })
    let cask_lines = ($casks | each {|c| $'cask "($c)"' })

    let content = ([
        $tap_lines
        (if ($tap_lines | is-empty) { [] } else { [""] })
        $brew_lines
        (if ($brew_lines | is-empty) { [] } else { [""] })
        $cask_lines
    ] | flatten | str join (char nl))

    $content | save --force $target
    done $"Exported (ansi cyan)($formulae | length)(ansi reset) formulae, (ansi cyan)($casks | length)(ansi reset) casks, (ansi cyan)($taps | length)(ansi reset) taps to (ansi dark_gray)($target)(ansi reset)"
}

# Install every package listed in a Brewfile via `brew bundle`.
# Deps are auto-installed; packages in the file are marked installed-on-request.
#
# Examples:
#   brew import                                → reads ./Brewfile
#   brew import ~/dotfiles/Brewfile            → custom path
export def "brew import" [
    path: path = "./Brewfile"                           # Source file
] {
    if not (check-brew) { return }

    let source = ($path | path expand)
    if not ($source | path exists) {
        print $"(ansi red_bold)✗(ansi reset) Brewfile not found at (ansi cyan)($source)(ansi reset)."
        return
    }

    step --tick 0 $"Running brew bundle on (ansi cyan)($source)(ansi reset)"
    let r = (^brew bundle --file $source | complete)
    clear-status

    if $r.exit_code != 0 {
        print $"(ansi red_bold)✗(ansi reset) brew bundle failed:"
        print ($r.stderr | str trim)
        return
    }
    if ($r.stdout | str trim | is-not-empty) {
        print ($r.stdout | str trim)
    }
    done $"Imported from (ansi dark_gray)($source)(ansi reset)."
}
