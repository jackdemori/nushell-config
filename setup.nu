#!/usr/bin/env nu

# Wires an already-downloaded nushell config into the system:
#   1. Sources ~/.config/nushell/init.nu from $nu.config-path
#   2. Appends an auto-generated environment block to $nu.env-path
#   3. Makes nu the default login shell (adds to /etc/shells, runs chsh)
#
# Usage:  nu ~/.config/nushell/setup.nu
#
# For a fresh machine, see install.sh in this directory — it downloads
# the files from GitHub, then invokes this script.
#
# Status helpers are inlined (rather than imported from modules/ui) so this
# script stays self-contained — it must run before the modules are wired up.

const LABEL_WIDTH = 7

def fmt-path [p: string] {
    $p | str replace -r $"^($env.HOME)" "~"
}

def pad [label: string]: nothing -> string {
    $label | fill --width $LABEL_WIDTH --alignment left --character ' '
}

def ok [label: string, msg: string] {
    print $"(ansi green_bold)✓(ansi reset) (pad $label)  ($msg)"
}

def warn [label: string, msg: string] {
    print $"(ansi yellow_bold)⚠(ansi reset) (pad $label)  ($msg)"
}

def fail [label: string, msg: string] {
    error make { msg: $"(ansi red_bold)✗(ansi reset) (pad $label)  ($msg)" }
}

# Send a native macOS notification via alerter if available.
# Silent no-op when alerter is missing (install.sh installs it on first run).
def notify-success [] {
    if (which alerter | is-not-empty) {
        ^alerter --title "Nushell Config" --message "Setup complete" --sound default --timeout 5 out+err> /dev/null
    }
}

# Compute prefix needed so appended content is separated by one blank line.
def append-prefix [existing: string]: nothing -> string {
    if ($existing | is-empty) {
        ""
    } else if ($existing | str ends-with "\n\n") {
        ""
    } else if ($existing | str ends-with "\n") {
        "\n"
    } else {
        "\n\n"
    }
}

# Returns true if the file was modified.
def install-init-source [] {
    let init_path = ("~/.config/nushell/init.nu" | path expand)
    let source_line = "source ~/.config/nushell/init.nu"
    let target = $nu.config-path

    if not ($init_path | path exists) {
        fail "config" $"expected (fmt-path $init_path) — clone repo to ~/.config/nushell first"
    }

    let existing = if ($target | path exists) { open --raw $target } else { "" }

    if ($existing | str contains "source ~/.config/nushell/config.nu") {
        warn "config" "old config.nu source line present — remove manually"
    }

    if ($existing | str contains $source_line) {
        ok "config" "source line already present"
        return false
    }

    $"(append-prefix $existing)($source_line)\n" | save --append $target
    ok "config" $"added source line to (fmt-path $target)"
    true
}

# Returns true if the file was modified.
def install-brew-env [] {
    let brew = (["/opt/homebrew/bin/brew" "/usr/local/bin/brew"]
        | where {|p| $p | path exists }
        | get 0?)
    if $brew == null {
        warn "env" "brew not found — skipped"
        return false
    }

    let target = $nu.env-path
    let start_marker = "# ─── Environment (auto-generated) ────────────────────"
    let end_marker = "# ──────────────────────────────────────────────────────"
    let existing = if ($target | path exists) { open --raw $target } else { "" }

    # zsh's `eval $(brew shellenv)` also invokes macOS path_helper, which
    # assembles PATH from /etc/paths + /etc/paths.d/* — so we get the full
    # system PATH without hardcoding machine-specific entries. We also ask
    # zsh to resolve the dotnet binary (in its freshly-set PATH) so we can
    # derive DOTNET_ROOT from it.
    let script = 'eval "$("$BREW" shellenv zsh)"; echo "$PATH"; command -v dotnet || echo ""'
    let out = (with-env { BREW: $brew } { ^zsh -c $script } | lines)
    let path_raw = ($out | get 0)
    let dotnet_bin = ($out | get 1? | default "" | str trim)

    let dotnet_section = if ($dotnet_bin | is-not-empty) {
        let dotnet_root = ($dotnet_bin | path dirname)
        [$"# .NET
$env.DOTNET_ROOT = \"($dotnet_root)\"
$env.DOTNET_CLI_TELEMETRY_OPTOUT = true
$env.DOTNET_NOLOGO = true"]
    } else {
        warn "env" "dotnet not found — .NET section skipped"
        []
    }

    let path_block = ($path_raw
        | split row ":"
        | each {|p| $"    \"($p)\"" }
        | str join "\n")

    let sections = ([
        "# Shell\n$env.config.completions.algorithm = \"fuzzy\"\n$env.config.show_banner = false"
        "# Editor\n$env.EDITOR = \"code\""
    ] ++ $dotnet_section ++ [
        $"# PATH\n$env.PATH = [\n($path_block)\n]"
    ])

    let body = ($sections | str join "\n\n")
    let stamp = (date now | format date '%Y-%m-%d %H:%M:%S %Z')
    let block = $"($start_marker)
# Last generated ($stamp). PATH is assembled from `brew shellenv` and macOS
# path_helper \(/etc/paths, /etc/paths.d\). Regenerate by re-running setup.nu.

($body)
($end_marker)"

    # Splice the block in: replace whatever sits between our markers, or
    # append at the end if the block isn't there yet. Content outside the
    # markers is preserved verbatim.
    let had_block = ($existing | str contains $start_marker)
    let head = if $had_block {
        ($existing | split row $start_marker | get 0 | str trim --right)
    } else {
        ($existing | str trim --right)
    }
    let tail = if $had_block {
        ($existing | split row $start_marker | get 1
            | split row $end_marker | get 1? | default ""
            | str trim)
    } else {
        ""
    }

    let parts = ([$head $block $tail] | where {|p| not ($p | is-empty) })
    let new_file = (($parts | str join "\n\n") + "\n")
    $new_file | save --force $target

    if $had_block {
        ok "env" $"refreshed environment block in (fmt-path $target)"
    } else {
        ok "env" $"generated environment block in (fmt-path $target)"
    }
    true
}

# Query the user's actual login shell from Directory Services.
# `$env.SHELL` is whatever the *current* terminal launched — often stale
# (e.g. reads /bin/zsh in a zsh-launched Ghostty session even after chsh
# set nu as the default). dscl reads the DS record itself, which is what
# `chsh` updates, so this matches what the next login will see.
def current-login-shell [] {
    let r = (do { ^dscl . -read $"/Users/($env.USER)" UserShell } | complete)
    if $r.exit_code != 0 { return "" }
    $r.stdout
        | str trim
        | str replace --regex '^UserShell:\s*' ''
}

# Returns true if chsh was run (default shell changed).
def install-default-shell [] {
    let nu_path = (["/opt/homebrew/bin/nu" "/usr/local/bin/nu"]
        | where {|p| $p | path exists }
        | get 0?)
    if $nu_path == null {
        warn "shell" "nu binary not found — skipped"
        return false
    }

    let current = (current-login-shell)
    if $current == $nu_path {
        ok "shell" $"already default — (ansi cyan)($nu_path)(ansi reset)"
        return false
    }

    let shells = if ("/etc/shells" | path exists) { open --raw /etc/shells } else { "" }
    if not ($shells | str contains $nu_path) {
        warn "shell" $"adding (ansi cyan)($nu_path)(ansi reset) to /etc/shells — sudo required"
        $"($nu_path)\n" | ^sudo tee -a /etc/shells | ignore
    }

    # `chsh -s <shell>` (no username arg) updates only the invoking user's
    # Directory Services record on macOS. It does not touch /etc/passwd or
    # any system-wide default. Other users on the machine keep their own
    # shell — we queried the same record above via `dscl . -read`.
    ^chsh -s $nu_path
    ok "shell" $"default set to (ansi cyan)($nu_path)(ansi reset) — new terminal to apply"
    true
}

# Spawn a fresh login nu, ask it to exit, and observe what happens.
# `--login` is required — without it nu skips env.nu/config.nu entirely.
# The login startup parses env.nu, config.nu, and (transitively) init.nu,
# so any syntax or resolution error surfaces here. We print nushell's own
# error output — file path + line number + snippet — and guide the user
# to the three files that could be at fault.
def check-configs [] {
    let result = (do { ^nu --login -c "exit 0" } | complete)
    if $result.exit_code == 0 { return false }

    let editor = ($env.EDITOR? | default "code")
    print --stderr ""
    print --stderr $"(ansi red_bold)✗(ansi reset) (pad "check")  nushell reports errors when starting with your config:"
    print --stderr ""
    print --stderr ($result.stderr | str trim)
    print --stderr ""
    print --stderr "  Fix with:"
    print --stderr $"    (ansi cyan)($editor) ($nu.config-path)(ansi reset)"
    print --stderr $"    (ansi cyan)($editor) ($nu.env-path)(ansi reset)"
    print --stderr $"    (ansi cyan)($editor) ~/.config/nushell/init.nu(ansi reset)"
    print --stderr ""
    true
}

def main [] {
    let changed = [
        (install-init-source)
        (install-brew-env)
        (install-default-shell)
    ] | any {|c| $c }

    let has_errors = (check-configs)

    if $changed and not $has_errors {
        print $"\n(ansi dark_gray)run(ansi reset) (ansi cyan)exec nu(ansi reset) (ansi dark_gray)to pick up changes(ansi reset)"
        notify-success
    }
}
