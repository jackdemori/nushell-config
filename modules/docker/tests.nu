# Coverage tests for modules/docker/completions.nu.
#
# For each documented docker command, parse `docker <cmd> --help` and assert
# every long flag the CLI advertises is present in the extern signature.
# Subcommand discovery walks `docker --help` plus each parent group (compose /
# container / image / system).
#
# Run: `nu modules/docker/tests.nu`  (exit 1 if anything fails).
# Requires: docker installed on PATH.

use ./completions.nu *
use ../ui [has-command]

const UNIVERSAL = [--help -h]

# Parse a `docker <cmd> --help` output into alias groups.
# Cobra-style flag lines have 2–8 leading spaces followed by `-`. The token
# after a flag name (e.g. `string`, `int`, `list`, `stringArray`, `duration`)
# is a type hint and is dropped by taking just the first token of each entry.
def parse-help-flags [help_output: string] {
    $help_output | lines
        | where {|line| ($line =~ '^ {2,8}-') }
        | each {|line|
            let head = ($line | str trim | split row -r '\s{2,}' | first)
            $head | split row -r ',\s*'
                | each {|t| $t | split row ' ' | first | str trim }
                | where {|t| ($t | str starts-with "-") }
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
    let help = (do { ^docker ...$parts --help } | complete)
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
    "docker login"
    "docker logout"
    "docker search"
    "docker version"
    "docker buildx"
    "docker compose"
    "docker compose attach"
    "docker compose build"
    "docker compose commit"
    "docker compose config"
    "docker compose cp"
    "docker compose create"
    "docker compose down"
    "docker compose events"
    "docker compose exec"
    "docker compose export"
    "docker compose images"
    "docker compose kill"
    "docker compose logs"
    "docker compose ls"
    "docker compose pause"
    "docker compose port"
    "docker compose ps"
    "docker compose publish"
    "docker compose pull"
    "docker compose push"
    "docker compose restart"
    "docker compose rm"
    "docker compose run"
    "docker compose scale"
    "docker compose start"
    "docker compose stats"
    "docker compose stop"
    "docker compose top"
    "docker compose unpause"
    "docker compose up"
    "docker compose version"
    "docker compose volumes"
    "docker compose wait"
    "docker compose watch"
    "docker container"
    "docker container attach"
    "docker container commit"
    "docker container cp"
    "docker container create"
    "docker container diff"
    "docker container exec"
    "docker container export"
    "docker container inspect"
    "docker container kill"
    "docker container logs"
    "docker container ls"
    "docker container pause"
    "docker container port"
    "docker container prune"
    "docker container rename"
    "docker container restart"
    "docker container rm"
    "docker container run"
    "docker container start"
    "docker container stats"
    "docker container stop"
    "docker container top"
    "docker container unpause"
    "docker container update"
    "docker container wait"
    "docker image"
    "docker image build"
    "docker image history"
    "docker image import"
    "docker image inspect"
    "docker image load"
    "docker image ls"
    "docker image prune"
    "docker image pull"
    "docker image push"
    "docker image rm"
    "docker image save"
    "docker image tag"
    "docker system"
    "docker system df"
    "docker system events"
    "docker system info"
    "docker system prune"
    "docker attach"
    "docker build"
    "docker commit"
    "docker cp"
    "docker create"
    "docker diff"
    "docker events"
    "docker exec"
    "docker export"
    "docker history"
    "docker images"
    "docker import"
    "docker inspect"
    "docker kill"
    "docker load"
    "docker logs"
    "docker pause"
    "docker port"
    "docker pull"
    "docker push"
    "docker rename"
    "docker restart"
    "docker rm"
    "docker rmi"
    "docker run"
    "docker save"
    "docker start"
    "docker stats"
    "docker stop"
    "docker tag"
    "docker top"
    "docker unpause"
    "docker update"
    "docker wait"
]

# Parents to walk for subcommand discovery.
const SUBCOMMAND_PARENTS = [
    "docker compose"
    "docker container"
    "docker image"
    "docker system"
]

# Docker top-level commands we intentionally skip. Plugins (marked with `*`
# in `docker --help`) that aren't part of mainstream workflows, and admin /
# Swarm / experimental commands that aren't typically used interactively.
const TOP_LEVEL_SKIP = [
    "agent" "ai" "debug" "desktop" "dhi" "extension" "init" "mcp" "model"
    "offload" "sandbox" "sbom" "scout"
    "bake" "checkpoint" "context" "manifest" "network" "plugin" "volume"
    "builder" "info" "ps" "pull" "push" "build" "run" "exec" "images"
    "config" "node" "secret" "service" "stack" "swarm"
]

# `docker --help` lists each command as `  NAME[*]  DESCRIPTION`.
# `*` marks plugins; the parser strips it.
def discover-top-level [] {
    let raw = (do { ^docker --help } | complete)
    if $raw.exit_code != 0 { return [] }
    $raw.stdout | lines
        | where ($it =~ '^  [a-z]')
        | each {|l| $l | str trim | split row ' ' | first | str replace -r '\*$' '' }
        | where ($it | str trim | is-not-empty)
        | uniq
}

# `docker <parent> --help` has the same `Commands:` format for subcommands.
def discover-parent-subcommands [parent: string] {
    let parts = ($parent | split row ' ' | skip 1)
    let raw = (do { ^docker ...$parts --help } | complete)
    if $raw.exit_code != 0 { return [] }
    $raw.stdout | lines
        | skip until {|l| $l | str starts-with "Commands:" }
        | skip 1
        | take while {|l| not ($l | str trim | is-empty) }
        | where ($it =~ '^  [a-z]')
        | each {|l| $l | str trim | split row ' ' | first | str replace -r '\*$' '' }
        | where ($it | str trim | is-not-empty)
        | uniq
}

def check-top-level-coverage [] {
    let known = (scope commands | where name =~ '^docker' | get name)
    let discovered = (discover-top-level)
    let missing = $discovered | where {|sub|
        ($"docker ($sub)" not-in $known) and ($sub not-in $TOP_LEVEL_SKIP)
    }
    if not ($missing | is-empty) {
        error make {msg: $"new top-level command\(s\): ($missing | str join ', ')"}
    }
}

def check-no-new-subcommands [parent: string] {
    let known = (scope commands | where name =~ '^docker' | get name)
    let discovered = (discover-parent-subcommands $parent)
    let missing = $discovered | where {|sub| $"($parent) ($sub)" not-in $known }
    if not ($missing | is-empty) {
        error make {msg: $"new subcommand\(s\) under `($parent)`: ($missing | str join ', ')"}
    }
}

def main [] {
    if not (has-command docker) {
        print $"(ansi yellow_bold)⚠(ansi reset)  docker not on PATH; skipping coverage tests"
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
    let disc_results = ["docker"] | append $SUBCOMMAND_PARENTS | each {|parent|
        try {
            if $parent == "docker" {
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
