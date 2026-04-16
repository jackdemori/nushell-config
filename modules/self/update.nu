use ../ui *

const REPO = "jackdemori/nushell-config"
const BRANCH = "main"

# Pull the latest version of this nushell configuration.
#
# If ~/.config/nushell/ is a git checkout, runs `git pull --ff-only origin
# main`. Otherwise downloads a fresh tarball and mirrors it over the
# existing files (orphan files from old versions are removed, local-only
# state like .git/.claude/.DS_Store is preserved).
#
# setup.nu is re-run at the end so the auto-generated block in env.nu
# picks up any new defaults.
export def "self update" [] {
    let dir = ("~/.config/nushell" | path expand)

    if not ($dir | path exists) {
        error make { msg: $"($dir) does not exist — reinstall via install.sh" }
    }

    let is_git = (($dir | path join ".git") | path exists)

    if $is_git {
        let result = (with-spinner "pulling latest from origin/main" {||
            ^git -C $dir pull --ff-only --quiet origin $BRANCH | complete
        })
        if $result.exit_code != 0 {
            print --stderr ($result.stderr | str trim)
            error make { msg: "git pull failed" }
        }
        done "git checkout updated"
    } else {
        let url = $"https://github.com/($REPO)/archive/($BRANCH).tar.gz"
        let tmp = (^mktemp -d | str trim)
        let result = (with-spinner "downloading and syncing tarball" {||
            do {
                ^curl -fsSL $url | ^tar -xz -C $tmp
                let src = (ls $tmp | where type == dir | first | get name)
                ^rsync -a --delete --exclude=.git --exclude=.claude --exclude=.DS_Store $"($src)/" $"($dir)/"
            } | complete
        })
        ^rm -rf $tmp
        if $result.exit_code != 0 {
            print --stderr ($result.stderr | str trim)
            error make { msg: "tarball sync failed" }
        }
        done "synced from tarball"
    }

    # Refresh the auto-generated env block.
    ^nu ($dir | path join "setup.nu")
}
