export use status.nu *

# True if an executable named `name` is on $env.PATH. Unlike `which`, this
# ignores `extern` declarations — a module that ships completions for a CLI
# would otherwise "find" that CLI even when the binary isn't installed.
export def has-command [name: string]: nothing -> bool {
    $env.PATH | any {|dir| $dir | path join $name | path exists }
}
