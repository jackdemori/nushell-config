# Shared CLI status helpers: animated single-line steps and completion markers.
# Step lines overwrite each other in place via CR + clear-line; the spinner
# prefix cycles through braille frames driven by an explicit --tick index.

export const CLEAR_LINE = "\r\u{1b}[2K"

const BRAILLE_FRAMES = [
    "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"
]

# Print/update an animated status line. Each call overwrites the previous.
# Pass --tick N to advance the spinner; N is taken mod the frame count.
export def step [msg: string, --tick(-t): int = 0] {
    let frame = ($BRAILLE_FRAMES | get ($tick mod ($BRAILLE_FRAMES | length)))
    print --stderr --no-newline $"($CLEAR_LINE)(ansi cyan)($frame)(ansi reset) ($msg)"
}

# Finalize the status line with a green check and a newline.
export def done [msg: string] {
    print --stderr $"($CLEAR_LINE)(ansi green_bold)✓(ansi reset) ($msg)"
}

# Clear the in-progress status line without leaving a marker — use when
# the next output (e.g. a table) should render cleanly after a `step` chain.
export def clear-status [] {
    print --stderr --no-newline $"($CLEAR_LINE)"
}

# Replace the $env.HOME prefix of a path with ~ for compact display.
export def fmt-path [p: string] {
    $p | str replace -r $"^($env.HOME)" "~"
}

# Run `work` in the foreground while a spinner animates `msg` in the
# background. Returns whatever `work` returns. The status line is cleared
# on exit, leaving the terminal ready for a follow-up `done` or regular
# output. If you need exit_code/stdout/stderr from an external command,
# wrap the body with `| complete` inside the closure.
export def with-spinner [msg: string, work: closure] {
    let spinner = job spawn {
        mut tick = 0
        loop {
            step $msg --tick $tick
            sleep 100ms
            $tick = ($tick + 1)
        }
    }
    let result = do $work
    job kill $spinner
    clear-status
    $result
}
