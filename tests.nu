# Top-level test runner. Discovers `modules/*/tests.nu` and runs each in a
# subprocess so a failure in one module doesn't abort the rest.
#
# Run: `nu tests.nu`
# Exit code 1 if any module's tests fail.

def main [] {
    let here = ($env.FILE_PWD)
    let files = (glob $"($here)/modules/*/tests.nu")

    if ($files | is-empty) {
        print "no tests found"
        return
    }

    let results = $files | each {|file|
        let module = ($file | path dirname | path basename)
        print ""
        print $"(ansi cyan_bold)═══ ($module) ═══(ansi reset)"
        # Stream subprocess output; capture only the exit code afterwards.
        ^nu $file
        {module: $module, ok: ($env.LAST_EXIT_CODE == 0)}
    }

    let failed = ($results | where ok == false)
    print ""
    print $"(ansi default_dimmed)══════════════════════════(ansi reset)"
    if ($failed | is-empty) {
        print $"(ansi green_bold)All modules passed(ansi reset)"
    } else {
        let names = ($failed | get module | str join ', ')
        print $"(ansi red_bold)Failed modules:(ansi reset) ($names)"
        exit 1
    }
}
