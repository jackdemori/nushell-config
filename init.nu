# Sourced from nushell's real config.nu (at $nu.default-config-dir).
# Run `nu ~/.config/nushell/setup.nu` to wire this up on a new machine,
# or `curl -fsSL https://raw.githubusercontent.com/jackdemori/nushell-config/main/install.sh | bash`
# on a fresh machine to fetch + install in one step.

use modules/git *
use modules/dotnet *
use modules/docker *
use modules/ulid *
use modules/world-time
use modules/macos *
use modules/brew *
use modules/self *

# Reload this config and all modules in-place (keeps the terminal, replaces the shell process).
def reload [] { exec nu }

$env.PROMPT_COMMAND_RIGHT = {||
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        # We define the format explicitly to ensure yyyy-mm-dd and 24h time regardless of locale
        (date now | format date '%Y-%m-%d %H:%M:%S')
    ] | str join | str replace --regex --all "([-:])" $"(ansi green)${1}(ansi magenta)")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    let is_git_repo_check = (do { git rev-parse --is-inside-work-tree } | complete)
    let is_git_repo = ($is_git_repo_check.exit_code == 0)

    let git_status = if $is_git_repo {
        let branch = (git rev-parse --abbrev-ref HEAD | str trim)
        let changes = (git status --porcelain | lines | length)
        let color = if $changes > 0 { "yb" } else { "gb" }
        let changes_indicator = if $changes > 0 { $"±($changes)" } else { "" }
        $"(ansi $color)git:\(($branch))($changes_indicator)(ansi reset) "
    } else {
        ""
    }

    ([$last_exit_code, (char space), $git_status, $time_segment] | str join)
}
