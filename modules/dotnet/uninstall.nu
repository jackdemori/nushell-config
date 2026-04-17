# Native nushell port of dotnet-core-uninstall (https://github.com/dotnet/cli-lab).
# Lists, previews, and removes installed .NET SDKs and runtimes from
# /usr/local/share/dotnet on macOS. Detects global.json influence and
# protects the active host SDK + every feature-band latest by default.

use ../ui [step done clear-status]

# ─── paths ──────────────────────────────────────────────────────────────────

def dotnet-root [] {
    $env.DOTNET_INSTALL_DIR? | default "/usr/local/share/dotnet"
}

# ─── version parsing ────────────────────────────────────────────────────────

def parse-version [v: string] {
    let parts = ($v | split row -n 2 "-")
    let base = $parts.0
    let suffix = if ($parts | length) > 1 { $parts.1 } else { "" }
    let nums = ($base | split row ".")
    if ($nums | length) != 3 { return null }
    try {
        let mj = ($nums.0 | into int)
        let mn = ($nums.1 | into int)
        let pt = ($nums.2 | into int)
        {
            raw: $v
            major: $mj
            minor: $mn
            patch: $pt
            preview: ($suffix | is-not-empty)
            suffix: $suffix
            band: ((($pt / 100) | math floor | into int) * 100)
        }
    } catch { null }
}

# Sortable tuple — non-preview ranks above preview at the same major.minor.patch.
def version-key [p: record] {
    [$p.major, $p.minor, $p.patch, (if $p.preview { 0 } else { 1 }), $p.suffix]
}

def sort-bundles [--desc] {
    let bundles = $in
    let s = ($bundles | sort-by {|b| version-key $b.parsed })
    if $desc { $s | reverse } else { $s }
}

# ─── bundle discovery ──────────────────────────────────────────────────────

def scan-versions [dir: path] {
    if not ($dir | path exists) { return [] }
    ls $dir | where type == "dir" | each {|e|
        let name = ($e.name | path basename)
        let parsed = (parse-version $name)
        if $parsed == null { null } else {
            {version: $name, parsed: $parsed, path: $e.name}
        }
    } | compact
}

def detect-arch [bundle_path: path] {
    if ($bundle_path | str contains "/x64/") { return "x64" }
    let rid_file = ($bundle_path | path join "NETCoreSdkRuntimeIdentifierChain.txt")
    if ($rid_file | path exists) {
        let txt = (try { open --raw $rid_file } catch { "" })
        if ($txt | str contains "osx-arm64") { return "arm64" }
        if ($txt | str contains "osx-x64") { return "x64" }
    }
    if $nu.os-info.arch == "aarch64" { "arm64" } else { "x64" }
}

# Returns a flat list of bundles:
#   {type: "sdk"|"runtime", version, parsed, arch, paths: [...]}
# Runtime bundles aggregate Microsoft.NETCore.App + Microsoft.AspNetCore.{App,All}
# + host/fxr at the same version, matching upstream's grouping.
export def discover-bundles [] {
    let root = (dotnet-root)
    let candidates = [$root, ($root | path join "x64")]
    let roots = ($candidates | where {|p| $p | path exists })

    $roots | each {|r|
        let sdks = (scan-versions ($r | path join "sdk") | each {|s|
            {type: "sdk", version: $s.version, parsed: $s.parsed, arch: (detect-arch $s.path), paths: [$s.path]}
        })

        let runtime_dirs = [
            ($r | path join "shared" "Microsoft.NETCore.App")
            ($r | path join "shared" "Microsoft.AspNetCore.App")
            ($r | path join "shared" "Microsoft.AspNetCore.All")
            ($r | path join "host" "fxr")
        ]
        let runtime_paths = ($runtime_dirs | each {|d| scan-versions $d } | flatten)

        let runtimes = ($runtime_paths | group-by version --to-table | each {|g|
            let first = ($g.items | first)
            {
                type: "runtime"
                version: $first.version
                parsed: $first.parsed
                arch: (detect-arch $first.path)
                paths: ($g.items | get path)
            }
        })

        $sdks | append $runtimes
    } | flatten
}

# ─── global.json detection ─────────────────────────────────────────────────

def find-global-json [] {
    mut dir = $env.PWD
    loop {
        let candidate = ($dir | path join "global.json")
        if ($candidate | path exists) { return $candidate }
        let parent = ($dir | path dirname)
        if $parent == $dir { return null }
        $dir = $parent
    }
}

def read-global-json [] {
    let path = (find-global-json)
    if $path == null { return null }
    let data = (try { open $path } catch { return null })
    let sdk = ($data.sdk? | default {})
    {
        path: $path
        version: ($sdk.version? | default null)
        rollForward: ($sdk.rollForward? | default "latestPatch")
        allowPrerelease: ($sdk.allowPrerelease? | default false)
    }
}

# True when the `dotnet` binary is on PATH.
def dotnet-available [] {
    (which dotnet | is-not-empty)
}

# Print a one-time warning pointing the user at PATH and DOTNET_ROOT. Used
# when a subcommand is invoked but dotnet isn't resolvable — the command
# still runs (filesystem discovery works), but NuGet scanning and global.json
# resolution are skipped.
def warn-dotnet-missing [] {
    print --stderr ""
    print --stderr $"(ansi yellow_bold)⚠ dotnet command not found(ansi reset)"
    print --stderr $"  (ansi dark_gray)SDK/runtime discovery under(ansi reset) (ansi cyan)/usr/local/share/dotnet(ansi reset) (ansi dark_gray)still works,(ansi reset)"
    print --stderr $"  (ansi dark_gray)but NuGet locals and global.json resolution will be skipped.(ansi reset)"
    print --stderr ""
    print --stderr "  Check:"
    print --stderr $"    (ansi cyan)which dotnet(ansi reset)           (ansi dark_gray)# binary on PATH?(ansi reset)"
    print --stderr $"    (ansi cyan)echo \$env.DOTNET_ROOT(ansi reset)  (ansi dark_gray)# runtime location set?(ansi reset)"
    print --stderr ""
}

# Run `dotnet --version` from a clean dir so global.json doesn't influence the answer.
# `complete` captures stdout/stderr/exit-code so dotnet's error spam stays silent.
# Returns null if dotnet isn't installed or the command fails.
def host-default-sdk [] {
    if not (dotnet-available) { return null }
    let r = (do { cd /tmp; ^dotnet --version } | complete)
    if $r.exit_code == 0 { $r.stdout | str trim } else { null }
}

def cwd-active-sdk [] {
    if not (dotnet-available) { return null }
    let r = (^dotnet --version | complete)
    if $r.exit_code == 0 { $r.stdout | str trim } else { null }
}

# ─── safety: which paths must never be removed (without --force) ───────────

# Protected set: the single latest SDK, the single latest runtime, and
# anything matching a global.json-pinned version. Everything else is
# deletable without --force.
def protected-paths [bundles: list] {
    step --tick 4 "Computing safety set"
    let global = (read-global-json)
    clear-status

    let sdks = ($bundles | where type == "sdk")
    let runtimes = ($bundles | where type == "runtime")

    mut keep = []

    let latest_sdk = ($sdks | sort-bundles --desc | first)
    if $latest_sdk != null {
        $keep = ($keep | append $latest_sdk)
    }

    let latest_runtime = ($runtimes | sort-bundles --desc | first)
    if $latest_runtime != null {
        $keep = ($keep | append $latest_runtime)
    }

    if $global != null and (($global.version? | default null) != null) {
        let pinned = ($sdks | where version == $global.version)
        if ($pinned | is-not-empty) {
            $keep = ($keep | append $pinned)
        }
    }

    $keep | each {|b| $b.paths } | flatten | uniq
}

# ─── filterers ─────────────────────────────────────────────────────────────

def filter-by-type [--sdk, --runtime, --nuget] {
    let bundles = $in
    let any_filter = ($sdk or $runtime or $nuget)
    if not $any_filter { return $bundles }
    $bundles | where {|b|
        (($sdk and $b.type == "sdk") or ($runtime and $b.type == "runtime") or ($nuget and $b.type == "nuget"))
    }
}

# Unified discovery: SDKs + runtimes from /usr/local/share/dotnet + NuGet locals.
def discover-all [] {
    discover-bundles | append (discover-nuget)
}

def invalid [msg: string] {
    print --stderr ""
    print --stderr $"(ansi red_bold)✗(ansi reset) ($msg)"
    print --stderr ""
}

def show-subcommands-help [] {
    print --stderr $"(ansi default_bold)Available subcommands:(ansi reset)"
    print --stderr $"  (ansi green)list(ansi reset)     Show installed SDKs, runtimes, and NuGet locals"
    print --stderr $"  (ansi green)dry-run(ansi reset)  Preview a removal"
    print --stderr $"  (ansi green)remove(ansi reset)   Remove SDKs/runtimes and/or clear NuGet locals"
    print --stderr ""
    print --stderr $"Run (ansi yellow)dotnet purge --help(ansi reset) for full docs."
}

def show-selectors-help [--sdk, --runtime, --nuget] {
    let only_nuget = ($nuget and (not $sdk) and (not $runtime))

    if $only_nuget {
        print --stderr $"(ansi default_bold)With (ansi yellow)--nuget(ansi reset)(ansi default_bold) you can target:(ansi reset)"
        print --stderr $"  (ansi yellow)--all(ansi reset)                       Everything \(default when used alone\)"
        print --stderr $"  (ansi yellow)--all-but <a,b,c>(ansi reset)           All except the listed resources"
        print --stderr $"  (ansi yellow)<name> [<name> ...](ansi reset)         Specific resources by name"
        print --stderr ""
        print --stderr $"(ansi default_bold)NuGet resource names:(ansi reset)"
        print --stderr $"  (ansi cyan)http-cache(ansi reset)        Cached HTTP responses from NuGet feeds"
        print --stderr $"  (ansi cyan)global-packages(ansi reset)   Extracted packages \(used by restore; rebuilds are slow\)"
        print --stderr $"  (ansi cyan)temp(ansi reset)              Scratch files during install/restore"
        print --stderr $"  (ansi cyan)plugins-cache(ansi reset)     Auth plugin response cache"
        return
    }

    print --stderr $"(ansi default_bold)Selectors \(pick one\):(ansi reset)"
    print --stderr $"  (ansi yellow)--all                       (ansi reset)Everything matching the filter"
    print --stderr $"  (ansi yellow)--all-below <version>       (ansi reset)Everything below the given version"
    print --stderr $"  (ansi yellow)--all-but <a,b,c>           (ansi reset)Everything except the listed versions"
    print --stderr $"  (ansi yellow)--all-but-latest            (ansi reset)Keep only the latest"
    print --stderr $"  (ansi yellow)--all-lower-patches         (ansi reset)Patches superseded by a higher patch"
    print --stderr $"  (ansi yellow)--all-previews              (ansi reset)All preview installs"
    print --stderr $"  (ansi yellow)--all-previews-but-latest   (ansi reset)Previews except the latest"
    print --stderr $"  (ansi yellow)--major-minor <X.Y>         (ansi reset)Everything in this major.minor band"
    print --stderr $"  (ansi yellow)<version> [<version> ...]   (ansi reset)Explicit version numbers"
    print --stderr ""
    print --stderr $"(ansi default_bold)Filters:(ansi reset)"
    print --stderr $"  (ansi yellow)--sdk                       (ansi reset)SDKs only"
    print --stderr $"  (ansi yellow)--runtime                   (ansi reset)Runtimes only"
    print --stderr $"  (ansi yellow)--nuget                     (ansi reset)NuGet locals only \(implies --all if used alone\)"
}

# Validate inputs. Returns null if valid, else a user-facing error string.
def validate-selector [opts: record, versions: list] {
    let count = (
        [$opts.all,
         ($opts.all_below | is-not-empty),
         ($opts.all_but | is-not-empty),
         $opts.all_but_latest,
         $opts.all_lower_patches,
         $opts.all_previews,
         $opts.all_previews_but_latest,
         ($opts.major_minor | is-not-empty),
         (($versions | length) > 0)]
        | where {|x| $x } | length
    )
    if $count == 0 {
        return "No selector given. You need to say what to target."
    }
    if $count > 1 {
        return "Multiple selectors given. Specify exactly one."
    }
    if ($opts.all_below | is-not-empty) and (parse-version $opts.all_below) == null {
        return $"(ansi yellow)--all-below(ansi reset) expects a version like X.Y.Z. Got: (ansi red)($opts.all_below)(ansi reset)"
    }
    if ($opts.major_minor | is-not-empty) {
        let parts = ($opts.major_minor | split row ".")
        let ok = if ($parts | length) == 2 {
            try { $parts.0 | into int; $parts.1 | into int; true } catch { false }
        } else { false }
        if not $ok {
            return $"(ansi yellow)--major-minor(ansi reset) expects a format like X.Y. Got: (ansi red)($opts.major_minor)(ansi reset)"
        }
    }
    null
}

def apply-selector [versions: list, opts: record] {
    let bundles = $in

    if $opts.all { return $bundles }
    if ($opts.all_below | is-not-empty) {
        let cut = (parse-version $opts.all_below)
        let cut_key = (version-key $cut)
        return ($bundles | where {|b| (version-key $b.parsed) < $cut_key })
    }
    if ($opts.all_but | is-not-empty) {
        let exclude = ($opts.all_but | split row "," | each {|v| $v | str trim })
        return ($bundles | where {|b| not ($b.version in $exclude) })
    }
    if $opts.all_but_latest {
        return ($bundles | sort-bundles --desc | skip 1)
    }
    if $opts.all_lower_patches {
        let by_band = (
            $bundles
            | insert _band {|b| $"($b.type)-($b.parsed.major).($b.parsed.minor).($b.parsed.band)" }
            | group-by _band --to-table
        )
        return ($by_band | each {|g| $g.items | sort-bundles --desc | skip 1 } | flatten)
    }
    if $opts.all_previews {
        return ($bundles | where {|b| $b.parsed.preview })
    }
    if $opts.all_previews_but_latest {
        let p = ($bundles | where {|b| $b.parsed.preview })
        return ($p | sort-bundles --desc | skip 1)
    }
    if ($opts.major_minor | is-not-empty) {
        let parts = ($opts.major_minor | split row ".")
        let mj = ($parts.0 | into int)
        let mn = ($parts.1 | into int)
        return ($bundles | where {|b| ($b.parsed.major == $mj) and ($b.parsed.minor == $mn) })
    }
    if ($versions | length) > 0 {
        return ($bundles | where {|b| $b.version in $versions })
    }
    []
}

def opts-from-flags [
    all: bool, all_below: any, all_but: any, all_but_latest: bool,
    all_lower_patches: bool, all_previews: bool, all_previews_but_latest: bool,
    major_minor: any
] {
    {
        all: $all
        all_below: $all_below
        all_but: $all_but
        all_but_latest: $all_but_latest
        all_lower_patches: $all_lower_patches
        all_previews: $all_previews
        all_previews_but_latest: $all_previews_but_latest
        major_minor: $major_minor
    }
}

# `--nuget` on its own with no selector is a small, safe fixed set — imply --all.
# Required-selector safety still applies when SDK/runtime are in scope.
def maybe-default-all [opts: record, versions: list, sdk: bool, runtime: bool, nuget: bool] {
    let only_nuget = ($nuget and (not $sdk) and (not $runtime))
    let no_selector = (
        (not $opts.all) and
        (($opts.all_below | is-empty)) and
        (($opts.all_but | is-empty)) and
        (not $opts.all_but_latest) and
        (not $opts.all_lower_patches) and
        (not $opts.all_previews) and
        (not $opts.all_previews_but_latest) and
        (($opts.major_minor | is-empty)) and
        (($versions | length) == 0)
    )
    if $only_nuget and $no_selector { $opts | upsert all true } else { $opts }
}

# ─── nuget locals ──────────────────────────────────────────────────────────

# Parse `dotnet nuget locals all --list` output into [{name, path}].
# Returns [] if dotnet isn't available or the call fails.
def get-nuget-locations [] {
    if not (dotnet-available) { return [] }
    let r = (^dotnet nuget locals all --list | complete)
    if $r.exit_code != 0 { return [] }
    $r.stdout
    | lines
    | each {|line| $line | parse --regex '^(?:info : )?(?P<name>[\w-]+): (?P<path>.+)$' }
    | flatten
}

def dir-size [path: path] {
    if not ($path | path exists) { return 0 }
    let r = (^du -sk $path | complete)
    if $r.exit_code != 0 { return 0 }
    let kb = ($r.stdout | str trim | split row "\t" | first | into int)
    $kb * 1024
}

# Load bundles with a spinner, skipping work the filter won't use.
# `--sdk`/`--runtime` alone skip the slow `du` on NuGet caches entirely;
# `--nuget` alone skips the (fast) SDK/runtime directory walk.
def load-bundles [--sdk, --runtime, --nuget] {
    let any_filter = ($sdk or $runtime or $nuget)
    let need_fs = ((not $any_filter) or $sdk or $runtime)
    let need_nuget = ((not $any_filter) or $nuget)

    mut bundles = []

    if $need_fs {
        step --tick 0 "Scanning .NET SDKs and runtimes"
        $bundles = (discover-bundles)
    }

    if $need_nuget {
        step --tick 2 "Reading NuGet local resources"
        let locs = (get-nuget-locations)
        let nbundles = ($locs | enumerate | each {|it|
            step --tick ($it.index + 3) $"Measuring NuGet (ansi cyan)($it.item.name)(ansi reset)"
            {
                type: "nuget"
                version: $it.item.name
                parsed: {major: 0, minor: 0, patch: 0, preview: false, suffix: "", band: 0}
                arch: "-"
                size: (dir-size $it.item.path)
                paths: [$it.item.path]
            }
        })
        $bundles = ($bundles | append $nbundles)
    }

    clear-status

    if not $any_filter { return $bundles }
    $bundles | where {|b|
        (($sdk and $b.type == "sdk") or ($runtime and $b.type == "runtime") or ($nuget and $b.type == "nuget"))
    }
}

# ─── display ───────────────────────────────────────────────────────────────

def show-global-json-banner [] {
    let g = (read-global-json)
    if $g == null { return }
    step --tick 0 "Resolving .NET host SDK"
    let host = (host-default-sdk)
    step --tick 2 "Resolving cwd-active SDK"
    let active = (cwd-active-sdk)
    clear-status

    print --stderr ""
    print --stderr $"(ansi yellow_bold)⚠ global.json in scope(ansi reset)"
    print --stderr $"  (ansi dark_gray)file:(ansi reset)         ($g.path)"
    if $g.version != null {
        print --stderr $"  (ansi dark_gray)pinned SDK:(ansi reset)   (ansi cyan)($g.version)(ansi reset)  (ansi dark_gray)\(rollForward: ($g.rollForward)\)(ansi reset)"
    }
    if $active == null {
        print --stderr $"  (ansi red)pinned SDK is not installed — `dotnet` errors in this dir.(ansi reset)"
    } else if $active != $host {
        print --stderr $"  (ansi dark_gray)active here:(ansi reset)  (ansi cyan)($active)(ansi reset)  (ansi dark_gray)\(host default: ($host)\)(ansi reset)"
    }
    print --stderr $"  (ansi dark_gray)→ SDKs in this band are protected; pass --force to override.(ansi reset)"
    print --stderr ""
}

# Installed SDK/runtime versions, filtered by --sdk/--runtime if present in context.
def installed-versions [context: string] {
    let has_sdk = ($context | str contains "--sdk")
    let has_runtime = ($context | str contains "--runtime")
    let bundles = (try { discover-bundles | where type != "nuget" } catch { [] })
    let filtered = if $has_sdk and (not $has_runtime) {
        $bundles | where type == "sdk"
    } else if $has_runtime and (not $has_sdk) {
        $bundles | where type == "runtime"
    } else {
        $bundles
    }
    $filtered | each {|b| {value: $b.version, description: $"($b.type) ($b.arch)"} } | uniq-by value
}

def nuget-resource-names [] {
    [
        {value: "http-cache",      description: "Cached HTTP responses from NuGet feeds"}
        {value: "global-packages", description: "Extracted packages (slow to rebuild)"}
        {value: "temp",            description: "Scratch files during install/restore"}
        {value: "plugins-cache",   description: "Auth plugin response cache"}
    ]
}

# Context-aware completer for positional args on dry-run/remove.
# --nuget only → resource names; otherwise installed SDK/runtime versions.
export def "nu-complete purge target" [context: string] {
    let has_nuget = ($context | str contains "--nuget")
    let has_sdk = ($context | str contains "--sdk")
    let has_runtime = ($context | str contains "--runtime")
    if $has_nuget and (not $has_sdk) and (not $has_runtime) {
        nuget-resource-names
    } else {
        installed-versions $context
    }
}

# Completer for --all-below: installed SDK/runtime versions.
export def "nu-complete purge version" [context: string] {
    installed-versions $context
}

# Completer for --major-minor: unique X.Y bands derived from installed SDK/runtime.
export def "nu-complete purge major-minor" [context: string] {
    let has_sdk = ($context | str contains "--sdk")
    let has_runtime = ($context | str contains "--runtime")
    let bundles = (try { discover-bundles | where type != "nuget" } catch { [] })
    let filtered = if $has_sdk and (not $has_runtime) {
        $bundles | where type == "sdk"
    } else if $has_runtime and (not $has_sdk) {
        $bundles | where type == "runtime"
    } else {
        $bundles
    }
    $filtered
    | each {|b| {value: $"($b.parsed.major).($b.parsed.minor)", description: $b.type} }
    | uniq-by value
}

def fmt-bundles [] {
    $in
    | sort-by type {|b| version-key $b.parsed }
    | each {|b|
        {
            type: $b.type
            version: $b.version
            arch: $b.arch
            size: (if ($b.size? | default null) != null and $b.size > 0 { $b.size | into filesize } else { "" })
            paths: $b.paths
        }
    }
}

# ─── commands ──────────────────────────────────────────────────────────────

def show-docs [] {
    print ""
    print $"(ansi cyan_bold)dotnet purge(ansi reset) (ansi dark_gray)— native nushell port of dotnet/cli-lab(ansi reset)"
    print ""
    print "Removes .NET SDKs and runtimes installed under /usr/local/share/dotnet on macOS."
    print "Cannot touch installs from Homebrew, manual scripts, or other locations."
    print ""
    print $"(ansi default_bold)Usage:(ansi reset)"
    print $"  > (ansi green)dotnet purge(ansi reset) (ansi yellow)<subcommand>(ansi reset) [args] [options]"
    print ""
    print $"(ansi default_bold)Subcommands:(ansi reset)"
    print $"  (ansi green_bold)list                        (ansi reset)- Show installed SDKs, runtimes, and NuGet locals"
    print $"  (ansi green_bold)dry-run                     (ansi reset)- Preview a removal without changing anything"
    print $"  (ansi green_bold)remove                      (ansi reset)- Remove SDKs/runtimes \(sudo\) and/or clear NuGet locals"
    print ""
    print $"(ansi default_bold)Selectors \(for dry-run / remove\):(ansi reset)"
    print $"  (ansi yellow)--all                       (ansi reset)Everything matching the type filter"
    print $"  (ansi yellow)--all-below <version>       (ansi reset)Everything below the given version"
    print $"  (ansi yellow)--all-but <a,b,c>           (ansi reset)Everything except the listed versions"
    print $"  (ansi yellow)--all-but-latest            (ansi reset)Keep only the latest"
    print $"  (ansi yellow)--all-lower-patches         (ansi reset)Patches superseded by a higher patch in the same band"
    print $"  (ansi yellow)--all-previews              (ansi reset)All preview installs"
    print $"  (ansi yellow)--all-previews-but-latest   (ansi reset)Previews except the latest"
    print $"  (ansi yellow)--major-minor <X.Y>         (ansi reset)Everything in this major.minor band"
    print $"  (ansi yellow)<version> [<version> ...]   (ansi reset)Explicit version numbers"
    print ""
    print $"(ansi default_bold)Filters:(ansi reset)"
    print $"  (ansi yellow)--sdk                       (ansi reset)SDKs only"
    print $"  (ansi yellow)--runtime                   (ansi reset)Shared runtimes only \(NETCore + AspNetCore + host/fxr\)"
    print $"  (ansi yellow)--nuget                     (ansi reset)NuGet locals only \(global-packages, http-cache, temp, plugins-cache\)"
    print ""
    print $"(ansi default_bold)Options:(ansi reset)"
    print $"  (ansi yellow)--force                     (ansi reset)Bypass safety check"
    print $"  (ansi yellow)-y, --yes                   (ansi reset)Skip the confirmation prompt"
    print ""
    print $"(ansi default_bold)Safety:(ansi reset)"
    print "  By default, the latest SDK in every (major.minor.band), the host's default"
    print "  SDK, the cwd-active SDK, and any global.json-pinned band are protected."
    print "  A global.json in scope triggers a banner before each command."
    print ""
}

# Show docs when called bare or with --help/-h.
export def --wrapped "dotnet purge" [...args: string] {
    if ($args | is-empty) or ($args | any {|a| $a in ["--help" "-h"]}) {
        show-docs
        return
    }
    invalid $"Unknown subcommand: (ansi yellow)($args | str join ' ')(ansi reset)"
    show-subcommands-help
}

# Show .NET SDKs, runtimes, and NuGet locals installed on this machine.
export def "dotnet purge list" [
    ...names: string@"nu-complete purge target"         # Filter to specific versions or NuGet resource names
    --sdk                                               # Show SDKs only
    --runtime                                           # Show runtimes only
    --nuget                                             # Show NuGet locals only
] {
    if not (dotnet-available) { warn-dotnet-missing }
    show-global-json-banner
    let bundles = (load-bundles --sdk=$sdk --runtime=$runtime --nuget=$nuget)
    let filtered = if ($names | is-empty) { $bundles } else { $bundles | where version in $names }
    $filtered | fmt-bundles
}

# Preview which bundles a remove would target.
export def "dotnet purge dry-run" [
    ...versions: string@"nu-complete purge target"      # Explicit version numbers or NuGet resource names
    --all                                               # Target everything (filtered)
    --all-below: string@"nu-complete purge version"     # Below this version
    --all-but: string@"nu-complete purge target"       # Except these versions (comma-separated)
    --all-but-latest                                    # Keep only the latest
    --all-lower-patches                                 # Older patches in each band
    --all-previews                                      # All preview installs
    --all-previews-but-latest                           # Previews except the latest
    --major-minor: string@"nu-complete purge major-minor"   # X.Y band
    --sdk                                               # SDKs only
    --runtime                                           # Runtimes only
    --nuget                                             # NuGet locals only
    --force                                             # Show even protected bundles as removable
] {
    if not (dotnet-available) { warn-dotnet-missing }
    show-global-json-banner
    let raw_opts = (opts-from-flags $all $all_below $all_but $all_but_latest $all_lower_patches $all_previews $all_previews_but_latest $major_minor)
    let opts = (maybe-default-all $raw_opts $versions $sdk $runtime $nuget)

    let err = (validate-selector $opts $versions)
    if $err != null {
        invalid $err
        show-selectors-help --sdk=$sdk --runtime=$runtime --nuget=$nuget
        return
    }

    let candidates = (load-bundles --sdk=$sdk --runtime=$runtime --nuget=$nuget | apply-selector $versions $opts)

    let no_type_filter = (not ($sdk or $runtime or $nuget))
    if ($versions | length) > 0 and $no_type_filter {
        let ambiguous = ($versions | where {|v| ($candidates | where version == $v | get type | uniq | length) > 1 })
        if ($ambiguous | is-not-empty) {
            invalid $"Ambiguous version\(s\): (ansi yellow)($ambiguous | str join ', ')(ansi reset) — matches more than one type. Add (ansi yellow)--sdk(ansi reset), (ansi yellow)--runtime(ansi reset), or (ansi yellow)--nuget(ansi reset) to disambiguate."
            return
        }
    }
    let blocked_paths = (protected-paths (discover-bundles))
    let blocked = ($candidates | where {|c| ($c.paths | any {|p| $p in $blocked_paths }) })
    let safe = ($candidates | where {|c| not ($c.paths | any {|p| $p in $blocked_paths }) })
    let to_show = if $force { $candidates } else { $safe }

    if ($candidates | is-empty) {
        print --stderr $"(ansi dark_gray)No bundles match this selector.(ansi reset)"
        return
    }

    print --stderr $"(ansi default_bold)Would remove:(ansi reset)"
    if ($to_show | is-empty) {
        print --stderr $"  (ansi dark_gray)\(nothing — all candidates are protected\)(ansi reset)"
    } else {
        for b in ($to_show | sort-bundles --desc) {
            let extra = if $b.type == "nuget" {
                $"(ansi dark_gray)\(($b.size | into filesize)\)(ansi reset)"
            } else {
                let n = ($b.paths | length)
                $"(ansi dark_gray)\(($b.arch), ($n) path\(s\)\)(ansi reset)"
            }
            print --stderr $"  (ansi green)✗(ansi reset) ($b.type) (ansi cyan)($b.version)(ansi reset) ($extra)"
        }
    }

    if (not $force) and ($blocked | is-not-empty) {
        print --stderr ""
        print --stderr $"(ansi yellow_bold)Protected \(would NOT remove\):(ansi reset)"
        for b in ($blocked | sort-bundles --desc) {
            print --stderr $"  (ansi yellow)•(ansi reset) ($b.type) (ansi cyan)($b.version)(ansi reset)"
        }
        print --stderr $"  (ansi dark_gray)Pass --force to include these.(ansi reset)"
    }
}

# Remove .NET SDKs/runtimes. Auto-elevates with sudo and prompts for confirmation.
export def "dotnet purge remove" [
    ...versions: string@"nu-complete purge target"      # Explicit version numbers or NuGet resource names
    --all                                               # Remove everything (filtered)
    --all-below: string@"nu-complete purge version"     # Below this version
    --all-but: string@"nu-complete purge target"       # Except these versions (comma-separated)
    --all-but-latest                                    # Keep only the latest
    --all-lower-patches                                 # Older patches in each band
    --all-previews                                      # All preview installs
    --all-previews-but-latest                           # Previews except the latest
    --major-minor: string@"nu-complete purge major-minor"   # X.Y band
    --sdk                                               # SDKs only
    --runtime                                           # Runtimes only
    --nuget                                             # NuGet locals only
    --force                                             # Bypass safety check
    --yes(-y)                                           # Skip confirmation prompt
] {
    if not (dotnet-available) { warn-dotnet-missing }
    show-global-json-banner
    let raw_opts = (opts-from-flags $all $all_below $all_but $all_but_latest $all_lower_patches $all_previews $all_previews_but_latest $major_minor)
    let opts = (maybe-default-all $raw_opts $versions $sdk $runtime $nuget)

    let err = (validate-selector $opts $versions)
    if $err != null {
        invalid $err
        show-selectors-help --sdk=$sdk --runtime=$runtime --nuget=$nuget
        return
    }

    let candidates = (load-bundles --sdk=$sdk --runtime=$runtime --nuget=$nuget | apply-selector $versions $opts)

    let no_type_filter = (not ($sdk or $runtime or $nuget))
    if ($versions | length) > 0 and $no_type_filter {
        let ambiguous = ($versions | where {|v| ($candidates | where version == $v | get type | uniq | length) > 1 })
        if ($ambiguous | is-not-empty) {
            invalid $"Ambiguous version\(s\): (ansi yellow)($ambiguous | str join ', ')(ansi reset) — matches more than one type. Add (ansi yellow)--sdk(ansi reset), (ansi yellow)--runtime(ansi reset), or (ansi yellow)--nuget(ansi reset) to disambiguate."
            return
        }
    }
    if ($candidates | is-empty) {
        print --stderr $"(ansi dark_gray)Nothing matches this selector.(ansi reset)"
        return
    }

    # Caches are never protected — safety only applies to SDK/runtime.
    let blocked_paths = (protected-paths (discover-bundles))
    let blocked = ($candidates | where {|c| ($c.paths | any {|p| $p in $blocked_paths }) })
    let safe = ($candidates | where {|c| not ($c.paths | any {|p| $p in $blocked_paths }) })
    let target = if $force { $candidates } else { $safe }

    if (not $force) and ($blocked | is-not-empty) {
        print --stderr $"(ansi yellow_bold)Refusing to remove protected bundles:(ansi reset)"
        for b in ($blocked | sort-bundles --desc) {
            print --stderr $"  (ansi yellow)•(ansi reset) ($b.type) (ansi cyan)($b.version)(ansi reset)"
        }
        print --stderr $"  (ansi dark_gray)Pass --force to override safety.(ansi reset)"
        if ($safe | is-empty) { return }
        print --stderr ""
    }

    if ($target | is-empty) {
        print --stderr $"(ansi dark_gray)Nothing safe to remove.(ansi reset)"
        return
    }

    print --stderr $"(ansi default_bold)Will remove:(ansi reset)"
    for b in ($target | sort-bundles --desc) {
        let extra = if $b.type == "nuget" {
            $"(ansi dark_gray)\(($b.size | into filesize)\)(ansi reset)"
        } else {
            $"(ansi dark_gray)\(($b.arch)\)(ansi reset)"
        }
        print --stderr $"  (ansi red)✗(ansi reset) ($b.type) (ansi cyan)($b.version)(ansi reset) ($extra)"
    }

    if not $yes {
        let reply = (input $"(ansi yellow)Continue? [y/N] (ansi reset)")
        if not ($reply in ["y" "Y" "yes"]) {
            print --stderr "Aborted."
            return
        }
    }

    let fs_targets = ($target | where type != "nuget")
    let nuget_targets = ($target | where type == "nuget")

    if ($fs_targets | is-not-empty) {
        let root = (dotnet-root)
        let x64root = ($root | path join "x64")
        let paths = ($fs_targets | each {|b| $b.paths } | flatten)
        let suspicious = ($paths | where {|p| not (($p | str starts-with $root) or ($p | str starts-with $x64root)) })
        if ($suspicious | is-not-empty) {
            invalid $"Refusing to delete paths outside ($root):"
            for p in $suspicious { print --stderr $"  (ansi dark_gray)($p)(ansi reset)" }
            return
        }
        let n = ($fs_targets | length)
        step --tick 0 $"Removing ($n) SDK/runtime bundle\(s\) — sudo may prompt"
        ^sudo rm -rf ...$paths
    }

    if ($nuget_targets | is-not-empty) {
        if not (dotnet-available) {
            invalid $"Cannot clear NuGet locals — (ansi yellow)dotnet(ansi reset) not on PATH."
            return
        }
        for t in ($nuget_targets | enumerate) {
            step --tick ($t.index + 2) $"Clearing NuGet (ansi cyan)($t.item.version)(ansi reset)"
            let r = (^dotnet nuget locals $t.item.version --clear | complete)
            if $r.exit_code != 0 {
                invalid $"Failed to clear NuGet (ansi yellow)($t.item.version)(ansi reset): ($r.stderr | str trim)"
                return
            }
        }
    }

    let freed = ($nuget_targets | get size | math sum)
    let freed_str = if $freed > 0 { $" freeing (ansi cyan)($freed | into filesize)(ansi reset)" } else { "" }
    done $"Removed ($target | length) bundle\(s\)($freed_str)."
}
