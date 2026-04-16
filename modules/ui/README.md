# UI Module

Shared helpers for user-facing output in nushell scripts. All functions print to `stderr` so their output stays clear of anything piped to another command.

## Exported commands

| Command        | Purpose                                                                  |
| -------------- | ------------------------------------------------------------------------ |
| `step`         | Print (or overwrite) a single progress line with a braille spinner frame |
| `done`         | Replace the current progress line with a green `✓` and a final message   |
| `clear-status` | Clear the progress line without leaving a marker                         |
| `with-spinner` | Run a closure while an animated spinner ticks in the background          |
| `fmt-path`     | Replace `$env.HOME` with `~` for compact path display                    |

## Two animation patterns

There are two distinct situations where progress feedback is useful, and they call for different helpers.

### 1. Staged work — use `step --tick N`

When your command has several **natural phases**, call `step` at the start of each phase with an incrementing tick. Between calls, nushell is running synchronously; each `step` writes the next spinner frame to the same line.

Use this when the work decomposes into named stages and you want the user to see what the script is currently doing.

Example from `modules/git/mod.nu`:

```nu
use ../ui [step done clear-status]

export def "git author" [branch_ref: string = "HEAD"] {
    step --tick 0 $"Reading commit log for (ansi cyan)($branch_ref)(ansi reset)"
    let commits = (^git log $branch_ref --numstat | lines)

    step --tick 2 "Parsing commit numstats"
    let parsed = ($commits | each {|l| parse-line $l } | compact)

    step --tick 4 "Aggregating per author"
    let agg = ($parsed | group-by author | ...)

    clear-status
    $agg
}
```

The spinner appears to move because three `step` calls fire in quick succession. There is no background thread — the frames simply advance as the work progresses.

### 2. One opaque call — use `with-spinner`

When the work is a single long-running command with no visible stages (a network request, an external process that does not report progress), use `with-spinner`. It spawns a background job that ticks the spinner every 100&nbsp;ms while your closure runs in the foreground.

Use this when you cannot insert progress checkpoints because the work is a black box.

Example from `modules/self/update.nu`:

```nu
use ../ui *

export def "self update" [] {
    let dir = ("~/.config/nushell" | path expand)

    let result = (with-spinner "pulling latest from origin/main" {||
        ^git -C $dir pull --ff-only --quiet origin main | complete
    })

    if $result.exit_code != 0 {
        print --stderr ($result.stderr | str trim)
        error make { msg: "git pull failed" }
    }

    done "git checkout updated"
}
```

`with-spinner` returns whatever the closure returns, so wrap external commands with `| complete` inside the closure if you need `exit_code`, `stdout`, or `stderr`.

## Picking between the two

| Situation                                        | Helper                                            |
| ------------------------------------------------ | ------------------------------------------------- |
| Work has two or more named phases                | `step --tick N`                                   |
| Work is a single opaque call (git, curl, build)  | `with-spinner`                                    |
| You need the return value of an external command | `with-spinner` + `\| complete` inside the closure |

Do not mix the two — they both write to the same status line. Finish any `step` chain with `clear-status` or `done` before invoking `with-spinner`.

## `fmt-path`

Small utility to compact paths for display. Replaces a leading `$env.HOME` with `~`.

```nu
use ../ui [fmt-path]

let p = "/Users/jack/Library/Application Support/nushell/env.nu"
fmt-path $p
# => ~/Library/Application Support/nushell/env.nu
```

Use wherever paths appear in user-facing messages so the output stays readable regardless of home directory length.
