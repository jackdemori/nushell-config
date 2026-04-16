# Thin wrappers around macOS CLI tools so you can type `finder`, `reveal`,
# `preview`, and `notify` instead of remembering the `open`/`qlmanage`/`osascript` flags.

# Open a path (or cwd) in macOS Finder.
export def finder [path: path = "."] {
    ^open $path
}

# Open Finder to the file's parent folder with the file highlighted.
export def reveal [file: path] {
    ^open -R $file
}

# Show a file in macOS Quick Look (same as hitting space in Finder).
# Blocks until the Quick Look window is closed; Ctrl+C returns early.
export def preview [file: path] {
    ^qlmanage -p $file out+err> /dev/null
}

# POSIX shell single-quote escaping: foo's bar → 'foo'\''s bar'
def shq [s: string] {
    let escaped = ($s | str replace --all "'" "'\\''")
    $"'($escaped)'"
}

# Resolve the system default alert sound to its actual name (e.g. "Glass")
# so passing `--sound default` plays what the user set in System Settings.
def resolve-default-sound [] {
    let r = (^defaults read -g com.apple.sound.beep.sound | complete)
    if $r.exit_code != 0 { return "default" }
    let base = ($r.stdout | str trim | path basename)
    if ($base | str ends-with ".aiff") { $base | str substring 0..<(($base | str length) - 5) } else { $base }
}

export def "nu-complete notification-sound" [] {
    let sounds = (try {
        ls /System/Library/Sounds/
        | where type == "file"
        | each {|f| $f.name | path basename | str replace ".aiff" "" }
    } catch { [] })
    let system_default = (resolve-default-sound)
    [{value: "default", description: $"Your system alert sound \(currently ($system_default)\)"}]
    | append ($sounds | each {|s| {value: $s, description: "macOS system sound"} })
}

def summarize [text: string] {
    let all = ($text | lines)
    mut picked = if ($all | length) > 10 { $all | last 10 } else { $all }
    while (($picked | str join (char nl) | str length) > 350) and (($picked | length) > 1) {
        $picked = ($picked | skip 1)
    }
    $picked | str join (char nl)
}

# Fire an alerter notification in the background so the shell doesn't block.
def send-notification [
    title: string
    message: string
    --subtitle: string
    --sound: string@"nu-complete notification-sound"    # e.g. "default", "Glass", "Ping"
    --icon: path                                        # --appIcon <path>
    --sender: string                                    # bundle id to impersonate (default: com.apple.Terminal)
    --timeout: int                                      # auto-close after N seconds
    --delay: int                                        # fire after N seconds
    --at: string                                        # fire at "HH:mm" or "yyyy-MM-dd HH:mm"
] {
    mut a = ["--title" $title "--message" $message]
    if ($subtitle | is-not-empty) { $a = ($a | append ["--subtitle" $subtitle]) }
    if ($sound | is-not-empty) {
        let resolved = if $sound == "default" { resolve-default-sound } else { $sound }
        $a = ($a | append ["--sound" $resolved])
    }
    if ($icon | is-not-empty)     { $a = ($a | append ["--appIcon" ($icon | path expand)]) }
    if ($sender | is-not-empty)   { $a = ($a | append ["--sender" $sender]) }
    if $timeout != null           { $a = ($a | append ["--timeout" ($timeout | into string)]) }
    if $delay != null             { $a = ($a | append ["--delay" ($delay | into string)]) }
    if ($at | is-not-empty)       { $a = ($a | append ["--at" $at]) }
    # Detach from the shell so scheduled notifications (--delay / --at) survive
    # closing the terminal. Each arg is single-quoted for bash.
    let quoted = ($a | each {|s| shq $s } | str join " ")
    ^bash -c $"nohup alerter ($quoted) >/dev/null 2>&1 &"
}

# Extract a flag value from a ps-style command line (splits on whitespace;
# joins tokens after --flag until the next --flag or end of line).
def extract-arg [cmd: string, flag: string] {
    let tokens = ($cmd | split row ' ')
    let indices = (0..(($tokens | length) - 1) | where {|i| ($tokens | get $i) == $flag })
    if ($indices | is-empty) { return null }
    let idx = ($indices | first)
    if (($idx + 1) >= ($tokens | length)) { return null }
    let rest = ($tokens | skip ($idx + 1))
    let until_next = ($rest | take while {|t| not ($t | str starts-with "--") })
    if ($until_next | is-empty) { null } else { $until_next | str join ' ' }
}

# List currently pending notifications (scheduled or waiting for dismissal).
# These are the live `alerter` background processes our `notify` has spawned.
export def "notify list" [] {
    let r = (^ps -Ao "pid,command" | complete)
    if $r.exit_code != 0 { return [] }
    $r.stdout
    | lines
    | skip 1
    | each {|l|
        let m = ($l | parse --regex '^\s*(?P<pid>\d+)\s+(?P<cmd>.+)$')
        if ($m | is-empty) { null } else { $m | first }
    }
    | compact
    | where {|row| ($row.cmd | split row ' ' | first | path basename) == "alerter" }
    | each {|row|
        {
            pid: ($row.pid | into int)
            title: (extract-arg $row.cmd "--title")
            message: (extract-arg $row.cmd "--message")
            delay: (extract-arg $row.cmd "--delay")
            at: (extract-arg $row.cmd "--at")
        }
    }
}

# Tab-completer for `notify cancel` — offers active notification pids with titles.
export def "nu-complete alerter-pid" [] {
    notify list | each {|n|
        let when = if ($n.at | is-not-empty) { $"at ($n.at)" }
                   else if ($n.delay | is-not-empty) { $"delay ($n.delay)s" }
                   else { "pending" }
        {value: ($n.pid | into string), description: $"($n.title) — ($when)"}
    }
}

# Cancel pending notifications by pid. No args = cancel all.
export def "notify cancel" [
    ...pids: int@"nu-complete alerter-pid"
] {
    let targets = if ($pids | is-empty) { notify list | get pid } else { $pids }
    if ($targets | is-empty) {
        print --stderr "Nothing to cancel."
        return
    }
    for p in $targets { ^kill $p out+err> /dev/null }
    print --stderr $"(ansi green_bold)✓(ansi reset) Cancelled ($targets | length) notification\(s\)."
}

# Fire a native macOS notification via alerter. Four forms:
#   notify "Title"                            → just the title
#   notify "Title" "message"                  → explicit message
#   <cmd> | notify "Title"                    → pipeline output becomes the message
#   notify "Title" { <cmd> }                  → runs the block, times it, notifies with status + duration
# All forms accept --subtitle, --sound, --icon, --sender, --timeout.
export def notify [
    title: string
    message?: any
    --subtitle: string
    --sound: string@"nu-complete notification-sound"
    --icon: path
    --sender: string
    --timeout: int                                      # auto-close after N seconds
    --delay: int                                        # fire after N seconds
    --at: string                                        # fire at "HH:mm" or "yyyy-MM-dd HH:mm"
] {
    let input = $in
    let kind = ($message | describe)

    if ($kind | str starts-with "closure") {
        let outcome = try { {ok: true, val: (do $message)} } catch {|e| {ok: false, err: $e.msg?} }
        if $outcome.ok {
            let body = (summarize ($outcome.val | to text))
            send-notification $title $body --subtitle="✓ done" --sound=$sound --icon=$icon --sender=$sender --timeout=$timeout --delay=$delay --at=$at
            $outcome.val
        } else {
            send-notification $title (summarize $outcome.err) --subtitle="✗ failed" --sound=$sound --icon=$icon --sender=$sender --timeout=$timeout --delay=$delay --at=$at
            error make --unspanned {msg: $outcome.err}
        }
    } else if $message != null {
        send-notification $title (summarize ($message | into string)) --subtitle=$subtitle --sound=$sound --icon=$icon --sender=$sender --timeout=$timeout --delay=$delay --at=$at
    } else if $input != null {
        send-notification $title (summarize ($input | to text)) --subtitle=$subtitle --sound=$sound --icon=$icon --sender=$sender --timeout=$timeout --delay=$delay --at=$at
    } else {
        send-notification $title "" --subtitle=$subtitle --sound=$sound --icon=$icon --sender=$sender --timeout=$timeout --delay=$delay --at=$at
    }
}
