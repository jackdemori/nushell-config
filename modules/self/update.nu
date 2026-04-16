# Self-update the nushell config. Uses `git pull` if ~/.config/nushell is a
# git checkout, otherwise downloads a fresh tarball from GitHub and rsyncs it
# over the existing files. Re-runs setup.nu at the end so the generated env
# block picks up any new defaults.

const REPO = "jackdemori/nushell-config"
const BRANCH = "main"

export def "self update" [] {
    let dir = ("~/.config/nushell" | path expand)

    if not ($dir | path exists) {
        error make { msg: $"($dir) does not exist — reinstall via install.sh" }
    }

    let is_git = (($dir | path join ".git") | path exists)

    if $is_git {
        print $"(ansi cyan)→ updating via git pull …(ansi reset)"
        ^git -C $dir pull --ff-only origin $BRANCH
    } else {
        print $"(ansi cyan)→ updating via tarball …(ansi reset)"
        let url = $"https://github.com/($REPO)/archive/($BRANCH).tar.gz"
        let tmp = (^mktemp -d | str trim)
        try {
            ^curl -fsSL $url | ^tar -xz -C $tmp
            let src = (ls $tmp | where type == dir | first | get name)
            # Mirror the tarball into place, deleting anything the repo no
            # longer contains. Exclude genuinely local state (.git, .claude,
            # .DS_Store) so it survives the update.
            ^rsync -a --delete --exclude=.git --exclude=.claude --exclude=.DS_Store $"($src)/" $"($dir)/"
        }
        ^rm -rf $tmp
    }

    # Refresh the auto-generated env block.
    ^nu ($dir | path join "setup.nu")
}
