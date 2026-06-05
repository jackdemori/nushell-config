# Static tab completions for Homebrew. Modelled on modules/dotnet/completions.nu —
# no live `^brew` calls during completion, so tab is instant.
#
# Coverage: the user-facing surface area (install/uninstall/upgrade/list/search/
# tap/services/bundle/...). Developer-only commands such as `audit`, `bump-*`,
# `bottle`, `tests`, `typecheck` etc. are intentionally omitted.

def "nu-complete brew services-state" [] {
    [started, stopped, error, scheduled, none, unknown]
}

def "nu-complete brew shells" [] {
    [bash, csh, fish, pwsh, sh, tcsh, zsh]
}

def "nu-complete brew log-categories" [] {
    [install, install-on-request, build-error, cask-install, os-version]
}

def "nu-complete brew analytics-days" [] {
    [30, 90, 365]
}

# Static subcommand completers — keep tab-completion fast and prevent nu from
# falling back to filesystem completion on parent externs (e.g. `brew ` or
# `brew services ` should show the subcommand list, not files in the cwd).

def "nu-complete brew subcommands" [] {
    [
        {value: "install",           description: "Install a formula or cask"}
        {value: "uninstall",         description: "Uninstall a formula or cask"}
        {value: "reinstall",         description: "Reinstall a formula or cask"}
        {value: "upgrade",           description: "Upgrade outdated, unpinned formulae and casks"}
        {value: "list",              description: "List all installed formulae and casks"}
        {value: "leaves",            description: "List installed formulae not depended on by anything"}
        {value: "outdated",          description: "List installed packages with updates available"}
        {value: "autoremove",        description: "Uninstall formulae only installed as transitive deps"}
        {value: "missing",           description: "Check installed formulae for missing dependencies"}
        {value: "cleanup",           description: "Remove stale lock files, downloads and old versions"}
        {value: "info",              description: "Show brief info or stats about a formula or cask"}
        {value: "desc",              description: "Display formula and cask descriptions"}
        {value: "deps",              description: "Show dependencies of a formula"}
        {value: "uses",              description: "Show formulae and casks that depend on the given formula"}
        {value: "home",              description: "Open a formula or cask's homepage in a browser"}
        {value: "options",           description: "Show install options specific to a formula"}
        {value: "log",               description: "Show the git log for a formula, cask, or Homebrew"}
        {value: "search",            description: "Search cask tokens and formula names"}
        {value: "pin",               description: "Pin a package, preventing upgrades"}
        {value: "unpin",             description: "Unpin a package"}
        {value: "link",              description: "Symlink a formula's files into Homebrew's prefix"}
        {value: "unlink",            description: "Remove a formula's symlinks from Homebrew's prefix"}
        {value: "tap",               description: "Tap a formula repository"}
        {value: "untap",             description: "Remove a tapped repository"}
        {value: "tap-info",          description: "Show detailed information about one or more taps"}
        {value: "trust",             description: "Trust non-official tap formulae, casks or commands"}
        {value: "untrust",           description: "Stop trusting non-official tap formulae or commands"}
        {value: "update",            description: "Fetch the newest version of Homebrew and all formulae"}
        {value: "update-if-needed",  description: "Run brew update if it hasn't run recently"}
        {value: "update-reset",      description: "Reset all taps to their upstream branch"}
        {value: "migrate",           description: "Migrate renamed packages to new names"}
        {value: "fetch",             description: "Download a bottle or source packages"}
        {value: "doctor",            description: "Check the system for potential problems"}
        {value: "config",            description: "Show Homebrew and system configuration info"}
        {value: "services",          description: "Manage background services with launchd / systemd"}
        {value: "bundle",            description: "Bundler for Homebrew/Cask/MAS/VSCode/... dependencies"}
        {value: "analytics",         description: "Control Homebrew's anonymous aggregate analytics"}
        {value: "completions",       description: "Control linking of external tap shell completions"}
        {value: "shellenv",          description: "Print export statements for the shell"}
        {value: "formulae",          description: "List all locally installable formulae"}
        {value: "casks",             description: "List all locally installable casks"}
        {value: "alias",             description: "Show or define an alias for a brew command"}
        {value: "unalias",           description: "Remove brew command aliases"}
        {value: "commands",          description: "Show lists of built-in and external brew commands"}
        {value: "command",           description: "Display the path to the file that implements a command"}
        {value: "help",              description: "Show help for a brew command"}
        {value: "docs",              description: "Open Homebrew's online documentation"}
        {value: "exec",              description: "Run a command in an environment populated by formulae"}
        {value: "postinstall",       description: "Re-run the post-install steps for a formula"}
        {value: "which-formula",     description: "Find the formula or tap that provides a binary"}
        {value: "readall",           description: "Read all formulae in the specified or all installed taps"}
        {value: "export",            description: "Write a portable Brewfile of user-requested packages"}
        {value: "import",            description: "Install every package listed in a Brewfile via brew bundle"}
    ]
}

def "nu-complete brew services-subcommands" [] {
    [
        {value: "start",   description: "Start a service and register for boot/login"}
        {value: "stop",    description: "Stop and unregister a service"}
        {value: "restart", description: "Stop (if needed) and start a service"}
        {value: "run",     description: "Run a service without registering"}
        {value: "list",    description: "List managed services"}
        {value: "kill",    description: "Stop a service but keep it registered"}
        {value: "info",    description: "List all managed services with detail"}
        {value: "cleanup", description: "Remove all unused services"}
    ]
}

def "nu-complete brew bundle-subcommands" [] {
    [
        {value: "install", description: "Install (and upgrade) all dependencies from the Brewfile"}
        {value: "dump",    description: "Write installed casks/formulae/taps to a Brewfile"}
        {value: "cleanup", description: "Uninstall dependencies not present in the Brewfile"}
        {value: "check",   description: "Check that all Brewfile dependencies are installed"}
        {value: "list",    description: "List all dependencies in the Brewfile"}
        {value: "exec",    description: "Run an external command in an isolated bundle env"}
        {value: "env",     description: "Print the env vars that bundle exec would set"}
        {value: "edit",    description: "Edit the Brewfile in $EDITOR"}
        {value: "add",     description: "Add entries to the Brewfile"}
        {value: "remove",  description: "Remove entries from the Brewfile"}
        {value: "sh",      description: "Run the shell in a bundle exec environment"}
    ]
}

def "nu-complete brew analytics-subcommands" [] {
    [
        {value: "state",           description: "Display the current state of analytics"}
        {value: "on",              description: "Turn analytics on"}
        {value: "off",              description: "Turn analytics off"}
        {value: "regenerate-uuid",  description: "Delete the legacy analytics UUID"}
    ]
}

def "nu-complete brew completions-subcommands" [] {
    [
        {value: "state",  description: "Display the current state of completions"}
        {value: "link",   description: "Link external tap completions"}
        {value: "unlink", description: "Unlink external tap completions"}
    ]
}

# The Homebrew package manager
export extern "brew" [
    command?: string@"nu-complete brew subcommands" #Subcommand to run
    --cache                                             #Display Homebrew's download cache
    --caskroom                                          #Display Homebrew's Caskroom path
    --cellar                                            #Display Homebrew's Cellar path
    --env                                               #Summarise Homebrew's build environment
    --prefix                                            #Display Homebrew's install path
    --repository                                        #Display where Homebrew's Git repository is located
    --repo                                              #Alias for --repository
    --taps                                              #Display the path to Homebrew's Taps directory
    --version(-v)                                       #Print the version numbers of Homebrew and core taps
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# Install a formula or cask
export extern "brew install" [
    ...packages: string                                 #Formulae or casks to install
    --debug(-d)                                         #Open an interactive debugging session on failure
    --display-times                                     #Print install times for each package
    --force(-f)                                         #Install without checking for previously installed versions
    --verbose(-v)                                       #Print the verification and post-install steps
    --dry-run(-n)                                       #Show what would be installed but don't install
    --ask                                               #Ask for confirmation before downloading and installing
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --ignore-dependencies                               #Skip installing dependencies (unsupported)
    --only-dependencies                                 #Install only dependencies, not the formula itself
    --cc: string                                        #Compile using the specified compiler
    --build-from-source(-s)                             #Compile from source even if a bottle is available
    --force-bottle                                      #Install from a bottle if one exists for the current macOS
    --include-test                                      #Install testing dependencies
    --HEAD                                              #Install the HEAD (main/trunk) version of the formula
    --fetch-HEAD                                        #Fetch upstream to detect outdated HEAD installs
    --keep-tmp                                          #Retain temporary files from the build
    --debug-symbols                                     #Generate debug symbols on build
    --build-bottle                                      #Prepare the formula for bottling, skipping post-install
    --skip-post-install                                 #Install but skip post-install steps
    --skip-link                                         #Install but skip linking the keg into the prefix
    --as-dependency                                     #Mark as installed as a dependency, not on request
    --bottle-arch: string                               #Optimise bottles for the specified architecture
    --interactive(-i)                                   #Download and patch the formula, then open a shell
    --git(-g)                                           #Create a Git repository in the source tree
    --overwrite                                         #Delete existing files in the prefix while linking
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --binaries                                          #Enable linking of helper executables (cask)
    --no-binaries                                       #Disable linking of helper executables (cask)
    --require-sha                                       #Require all casks to have a checksum
    --adopt                                             #Adopt existing identical artifacts in the destination
    --skip-cask-deps                                    #Skip installing cask dependencies
    --zap                                               #Remove all files associated with a cask
    --appdir: path                                      #Target Applications directory
    --appimagedir: path                                 #Target AppImages directory
    --keyboard-layoutdir: path                          #Target Keyboard Layouts directory
    --colorpickerdir: path                              #Target Color Pickers directory
    --prefpanedir: path                                 #Target Preference Panes directory
    --qlplugindir: path                                 #Target Quick Look Plugins directory
    --mdimporterdir: path                               #Target Spotlight Plugins directory
    --dictionarydir: path                               #Target Dictionaries directory
    --fontdir: path                                     #Target Fonts directory
    --servicedir: path                                  #Target Services directory
    --input-methoddir: path                             #Target Input Methods directory
    --internet-plugindir: path                          #Target Internet Plugins directory
    --audio-unit-plugindir: path                        #Target Audio Unit Plugins directory
    --vst-plugindir: path                               #Target VST Plugins directory
    --vst3-plugindir: path                              #Target VST3 Plugins directory
    --screen-saverdir: path                             #Target Screen Savers directory
    --language: string                                  #Comma-separated cask language preferences
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# Uninstall a formula or cask
export extern "brew uninstall" [
    ...packages: string                                 #Installed formulae or casks to remove
    --force(-f)                                         #Delete all installed versions of a formula
    --zap                                               #Remove all files associated with a cask
    --ignore-dependencies                               #Don't fail if formula is a dependency of another
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Reinstall a formula or cask using the same options
export extern "brew reinstall" [
    ...packages: string                                 #Installed formulae or casks to reinstall
    --debug(-d)                                         #Open an interactive debugging session on failure
    --display-times                                     #Print install times for each package
    --force(-f)                                         #Skip prior-version checks before reinstalling
    --verbose(-v)                                       #Print verification and post-install steps
    --ask                                               #Ask for confirmation before reinstalling
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --build-from-source(-s)                             #Compile from source even if a bottle is available
    --interactive(-i)                                   #Download and patch the formula, then open a shell
    --force-bottle                                      #Install from a bottle if one exists
    --keep-tmp                                          #Retain temporary files from the build
    --debug-symbols                                     #Generate debug symbols on build
    --git(-g)                                           #Create a Git repository in the source tree
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --binaries                                          #Enable linking of helper executables (cask)
    --no-binaries                                       #Disable linking of helper executables (cask)
    --require-sha                                       #Require all casks to have a checksum
    --adopt                                             #Adopt existing identical artifacts in the destination
    --skip-cask-deps                                    #Skip installing cask dependencies
    --zap                                               #Remove all files associated with a cask
    --appdir: path                                      #Target Applications directory
    --appimagedir: path                                 #Target AppImages directory
    --keyboard-layoutdir: path                          #Target Keyboard Layouts directory
    --colorpickerdir: path                              #Target Color Pickers directory
    --prefpanedir: path                                 #Target Preference Panes directory
    --qlplugindir: path                                 #Target Quick Look Plugins directory
    --mdimporterdir: path                               #Target Spotlight Plugins directory
    --dictionarydir: path                               #Target Dictionaries directory
    --fontdir: path                                     #Target Fonts directory
    --servicedir: path                                  #Target Services directory
    --input-methoddir: path                             #Target Input Methods directory
    --internet-plugindir: path                          #Target Internet Plugins directory
    --audio-unit-plugindir: path                        #Target Audio Unit Plugins directory
    --vst-plugindir: path                               #Target VST Plugins directory
    --vst3-plugindir: path                              #Target VST3 Plugins directory
    --screen-saverdir: path                             #Target Screen Savers directory
    --language: string                                  #Comma-separated cask language preferences
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# Upgrade outdated, unpinned formulae and casks
export extern "brew upgrade" [
    ...packages: string                                 #Outdated formulae or casks to upgrade
    --debug(-d)                                         #Open an interactive debugging session on failure
    --display-times                                     #Print install times for each package
    --force(-f)                                         #Skip prior-version checks
    --verbose(-v)                                       #Print verification and post-install steps
    --dry-run(-n)                                       #Show what would be upgraded but don't upgrade
    --minimum-version: string                           #Only upgrade if installed version is below this
    --min-version: string                               #Alias for --minimum-version
    --ask                                               #Ask for confirmation before upgrading
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --build-from-source(-s)                             #Compile from source even if a bottle is available
    --interactive(-i)                                   #Download and patch the formula, then open a shell
    --force-bottle                                      #Install from a bottle if one exists
    --fetch-HEAD                                        #Fetch upstream to detect outdated HEAD installs
    --keep-tmp                                          #Retain temporary files from the build
    --debug-symbols                                     #Generate debug symbols on build
    --overwrite                                         #Delete existing files in the prefix while linking
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --skip-cask-deps                                    #Skip installing cask dependencies
    --no-quit                                           #Prevent running cask applications from being quit before upgrading
    --greedy(-g)                                        #Also include casks pinned to :latest
    --greedy-latest                                     #Only include casks pinned to :latest
    --greedy-auto-updates                               #Only include casks that auto-update themselves
    --binaries                                          #Enable linking of helper executables (cask)
    --no-binaries                                       #Disable linking of helper executables (cask)
    --require-sha                                       #Require all casks to have a checksum
    --adopt                                             #Adopt existing identical artifacts in the destination
    --appdir: path                                      #Target Applications directory
    --appimagedir: path                                 #Target AppImages directory
    --keyboard-layoutdir: path                          #Target Keyboard Layouts directory
    --colorpickerdir: path                              #Target Color Pickers directory
    --prefpanedir: path                                 #Target Preference Panes directory
    --qlplugindir: path                                 #Target Quick Look Plugins directory
    --mdimporterdir: path                               #Target Spotlight Plugins directory
    --dictionarydir: path                               #Target Dictionaries directory
    --fontdir: path                                     #Target Fonts directory
    --servicedir: path                                  #Target Services directory
    --input-methoddir: path                             #Target Input Methods directory
    --internet-plugindir: path                          #Target Internet Plugins directory
    --audio-unit-plugindir: path                        #Target Audio Unit Plugins directory
    --vst-plugindir: path                               #Target VST Plugins directory
    --vst3-plugindir: path                              #Target VST3 Plugins directory
    --screen-saverdir: path                             #Target Screen Savers directory
    --language: string                                  #Comma-separated cask language preferences
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# List all installed formulae and casks
export extern "brew list" [
    ...packages: string                                 #Limit output to these installed packages
    --formula                                           #List only formulae
    --formulae                                          #List only formulae
    --cask                                              #List only casks
    --casks                                             #List only casks
    --full-name                                         #Print formulae with fully-qualified names
    --versions                                          #Show installed version numbers
    --json                                              #Output as JSON
    --multiple                                          #Show only formulae with multiple versions installed
    --pinned                                            #List only pinned packages
    --installed-on-request                              #List formulae installed on request
    --installed-as-dependency                           #List formulae installed as dependencies
    --poured-from-bottle                                #List formulae installed from a bottle
    --built-from-source                                 #List formulae compiled from source
    -1                                                  #One entry per line
    -l                                                  #Long-format listing
    -r                                                  #Reverse the sort order
    -t                                                  #Sort by modification time
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose                                           #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List installed formulae that are not a dependency of anything else
export extern "brew leaves" [
    --installed-on-request                              #Only list leaves installed on request
    --installed-as-dependency                           #Only list leaves installed as a dependency
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List installed casks and formulae with updates available
export extern "brew outdated" [
    ...packages: string                                 #Limit the check to these packages
    --quiet(-q)                                         #List only names of outdated kegs
    --verbose(-v)                                       #Include detailed version information
    --formula                                           #List only outdated formulae
    --formulae                                          #List only outdated formulae
    --cask                                              #List only outdated casks
    --casks                                             #List only outdated casks
    --json                                              #Print output as JSON
    --minimum-version: string                           #Only list if installed version is below this
    --min-version: string                               #Alias for --minimum-version
    --fetch-HEAD                                        #Fetch upstream to detect outdated HEAD installs
    --greedy(-g)                                        #Also include casks pinned to :latest
    --greedy-latest                                     #Only include casks pinned to :latest
    --greedy-auto-updates                               #Only include casks that auto-update themselves
    --debug(-d)                                         #Display debugging information
    --help(-h)                                          #Show usage
]

# Uninstall formulae that were only installed as transitive dependencies
export extern "brew autoremove" [
    --dry-run(-n)                                       #Show what would be removed
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Check installed formulae for missing dependencies
export extern "brew missing" [
    ...packages: string                                 #Limit the check to these formulae
    --hide: string                                      #Comma-separated formulae to ignore
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove stale lock files, outdated downloads and old versions
export extern "brew cleanup" [
    ...packages: string                                 #Limit cleanup to these packages
    --prune: string                                     #Remove cache files older than N days (or 'all')
    --dry-run(-n)                                       #Show what would be removed
    --scrub(-s)                                         #Scrub the cache including the latest versions
    --prune-prefix                                      #Only prune symlinks and dirs from the prefix
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Display brief statistics or info about a formula or cask
export extern "brew info" [
    ...packages: string                                 #Formulae or casks to describe
    --analytics                                         #List global analytics or analytics for a formula
    --days: string@"nu-complete brew analytics-days"    #Analytics window (30, 90, 365)
    --category: string@"nu-complete brew log-categories" #Analytics category
    --github                                            #Open the GitHub source page in a browser
    --fetch-manifest                                    #Fetch GitHub Packages manifest for extra info
    --json: string                                      #Print as JSON (v1, v2)
    --installed                                         #Output inventory of installed formulae and casks
    --eval-all                                          #Evaluate all formulae and casks
    --variations                                        #Include the variations hash in JSON output
    --verbose(-v)                                       #Show more verbose data
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --sizes                                             #Show the size of installed formulae and casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# Display formula and cask descriptions
export extern "brew desc" [
    ...packages: string                                 #Formulae or casks to look up
    --search(-s)                                        #Search names, descriptions and aliases
    --name(-n)                                          #Search names only
    --description(-d)                                   #Search descriptions only
    --eval-all                                          #Evaluate all formulae and casks
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --debug                                             #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show dependencies of a formula
export extern "brew deps" [
    ...packages: string                                 #Formulae or casks to inspect
    --topological(-n)                                   #Sort dependencies in topological order
    --direct(-1)                                        #Show only directly declared dependencies
    --union                                             #Show the union of dependencies for multiple formulae
    --full-name                                         #List dependencies by their full name
    --include-implicit                                  #Include implicit dependencies
    --include-build                                     #Include :build dependencies
    --include-optional                                  #Include :optional dependencies
    --include-test                                      #Include :test dependencies
    --skip-recommended                                  #Skip :recommended dependencies
    --include-requirements                              #Include requirements in addition to dependencies
    --tree                                              #Show dependencies as a tree
    --prune                                             #Prune parts of the tree already seen
    --graph                                             #Show dependencies as a directed graph
    --dot                                               #Show graph in DOT format
    --annotate                                          #Annotate build/test/implicit/optional/recommended
    --installed                                         #List dependencies for installed formulae only
    --eval-all                                          #Evaluate all formulae and casks
    --missing                                           #Only show missing dependencies
    --for-each                                          #Show dependencies for each formula individually
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --HEAD                                              #Show dependencies for the HEAD version
    --os: string                                        #Operating system to use for dependency resolution
    --arch: string                                      #CPU architecture to use
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show formulae and casks that depend on the given formula
export extern "brew uses" [
    ...packages: string                                 #Formulae to find dependents of
    --recursive                                         #Resolve more than one level of dependents
    --installed                                         #Only list installed dependents
    --missing                                           #Only list dependents that are not installed
    --eval-all                                          #Evaluate all formulae and casks
    --include-implicit                                  #Include implicit dependents
    --include-build                                     #Include :build dependents
    --include-test                                      #Include :test dependents
    --include-optional                                  #Include :optional dependents
    --skip-recommended                                  #Skip :recommended dependents
    --formula                                           #Include only formulae
    --formulae                                          #Include only formulae
    --cask                                              #Include only casks
    --casks                                             #Include only casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Open a formula or cask's homepage in a browser
export extern "brew home" [
    ...packages: string                                 #Formulae or casks whose homepage to open
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show install options specific to a formula
export extern "brew options" [
    ...packages: string                                 #Formulae whose options to show
    --compact                                           #Show all options on a single line
    --installed                                         #Show options for installed formulae
    --eval-all                                          #Evaluate all formulae and casks
    --command: string                                   #Show options for the specified brew command
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show the git log for a formula, cask, or Homebrew itself
export extern "brew log" [
    package?: string                                    #Formula or cask whose log to show
    --patch(-p)                                         #Also print the patch from each commit
    --stat                                              #Also print the diffstat from each commit
    --oneline                                           #Print only one line per commit
    -1                                                  #Print only one commit
    --max-count(-n): int                                #Print only N commits
    --formula                                           #Treat the argument as a formula
    --formulae                                          #Treat the argument as a formula
    --cask                                              #Treat the argument as a cask
    --casks                                             #Treat the argument as a cask
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Perform a substring search of cask tokens and formula names
export extern "brew search" [
    query?: string                                      #Text or /regex/ to search for
    --formula                                           #Search for formulae
    --formulae                                          #Search for formulae
    --cask                                              #Search for casks
    --casks                                             #Search for casks
    --desc                                              #Search descriptions too
    --eval-all                                          #Evaluate all formulae and casks
    --pull-request                                      #Search GitHub pull requests instead
    --open                                              #Only show open pull requests
    --closed                                            #Only show closed pull requests
    --alpine                                            #Also search Alpine Linux packages
    --repology                                          #Also search Repology
    --macports                                          #Also search MacPorts
    --fink                                              #Also search Fink
    --opensuse                                          #Also search openSUSE
    --fedora                                            #Also search Fedora
    --archlinux                                         #Also search Arch Linux
    --debian                                            #Also search Debian
    --ubuntu                                            #Also search Ubuntu
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Pin a package, preventing `brew upgrade` from touching it
export extern "brew pin" [
    ...packages: string                                 #Packages to pin
    --formula                                           #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Unpin a package
export extern "brew unpin" [
    ...packages: string                                 #Packages to unpin
    --formula                                           #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Symlink a formula's installed files into Homebrew's prefix
export extern "brew link" [
    ...packages: string                                 #Installed formulae to link
    --overwrite                                         #Delete existing files in the prefix
    --dry-run(-n)                                       #Show what would be linked
    --force(-f)                                         #Allow keg-only formulae to be linked
    --HEAD                                              #Link the HEAD version
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove a formula's symlinks from Homebrew's prefix
export extern "brew unlink" [
    ...packages: string                                 #Installed formulae to unlink
    --dry-run(-n)                                       #Show what would be unlinked
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Tap a formula repository
export extern "brew tap" [
    user_repo?: string                                  #user/repo of the tap to install (or list taps if omitted)
    url?: string                                        #Optional URL for non-GitHub taps
    --custom-remote                                     #Install or change a tap with a custom remote
    --repair                                            #Repair missing symlinks and corrupt remote refs
    --eval-all                                          #Evaluate all formulae/casks/aliases for validity
    --force(-f)                                         #Force install core taps under API mode
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove a tapped repository
export extern "brew untap" [
    ...taps: string                                     #Taps to remove (user/repo)
    --force(-f)                                         #Untap even if formulae from this tap are installed
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Trust non-official tap formulae, casks or commands
export extern "brew trust" [
    ...targets: string                                  #Names to trust
    --tap                                               #Trust the named tap
    --formula                                           #Trust the named formula
    --formulae                                          #Trust the named formula
    --cask                                              #Trust the named cask
    --casks                                             #Trust the named cask
    --command                                           #Trust the named external command
    --commands                                          #Trust the named external command
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Stop trusting non-official tap formulae, casks or commands
export extern "brew untrust" [
    ...targets: string                                  #Names to untrust
    --tap                                               #Untrust the named tap
    --formula                                           #Untrust the named formula
    --formulae                                          #Untrust the named formula
    --cask                                              #Untrust the named cask
    --casks                                             #Untrust the named cask
    --command                                           #Untrust the named external command
    --commands                                          #Untrust the named external command
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show detailed information about one or more taps
export extern "brew tap-info" [
    ...taps: string                                     #Taps to describe (user/repo)
    --installed                                         #Show info for all installed taps
    --json                                              #Print as JSON
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Fetch the newest version of Homebrew and all formulae from GitHub
export extern "brew update" [
    --merge                                             #Use `git merge` instead of `git rebase`
    --auto-update                                       #Run update only if newer than HOMEBREW_AUTO_UPDATE_SECS
    --force(-f)                                         #Always do a slow, full update check
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Run `brew update` if it hasn't run recently
export extern "brew update-if-needed" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Reset all taps to their upstream branch
export extern "brew update-reset" [
    ...taps: string                                     #Taps to reset (default: all)
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Migrate renamed packages to new names
export extern "brew migrate" [
    ...packages: string                                 #Packages whose old names need migrating
    --force(-f)                                         #Treat installed and updated formulae as if they aren't
    --dry-run(-n)                                       #Show what would be migrated
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Download a bottle or source packages for formulae and casks
export extern "brew fetch" [
    ...packages: string                                 #Formulae or casks to download
    --os: string                                        #Operating system for the download
    --arch: string                                      #CPU architecture for the download
    --all-platforms                                     #Download for every supported OS and architecture
    --bottle-tag: string                                #Download a bottle for the given tag
    --HEAD                                              #Fetch the HEAD version instead of stable
    --force(-f)                                         #Remove a cached version and re-fetch
    --verbose(-v)                                       #Verbose VCS checkout
    --retry                                             #Retry on failure (up to 5 times with backoff)
    --deps                                              #Also download dependencies of listed formulae
    --build-from-source(-s)                             #Download source packages rather than a bottle
    --build-bottle                                      #Download source packages for eventual bottling
    --force-bottle                                      #Download a bottle if one exists for this macOS
    --formula                                           #Treat all named arguments as formulae
    --formulae                                          #Treat all named arguments as formulae
    --cask                                              #Treat all named arguments as casks
    --casks                                             #Treat all named arguments as casks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --help(-h)                                          #Show usage
]

# Check the system for potential problems
export extern "brew doctor" [
    ...diagnostics: string                              #Optional diagnostic checks to run
    --list-checks                                       #List available diagnostic checks
    --audit-debug                                       #Enable debugging in audit checks
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show Homebrew and system configuration info
export extern "brew config" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Manage background services with launchd / systemd
export extern "brew services" [
    subcommand?: string@"nu-complete brew services-subcommands" #Services subcommand
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Start a service and register it to launch at login (or boot)
export extern "brew services start" [
    ...services: string                                 #Services to start (or --all)
    --all                                               #Start all services
    --file: path                                        #Use a custom plist/service file
    --sudo-service-user: string                         #When run as root, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Stop a service immediately and unregister it from launching at login (or boot)
export extern "brew services stop" [
    ...services: string                                 #Services to stop (or --all)
    --all                                               #Stop all services
    --keep                                              #Keep the service registered to relaunch
    --no-wait                                           #Don't wait for the service to stop
    --max-wait: int                                     #Max seconds to wait when stopping
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Stop (if needed) and start a service immediately
export extern "brew services restart" [
    ...services: string                                 #Services to restart (or --all)
    --all                                               #Restart all services
    --file: path                                        #Use a custom plist/service file
    --sudo-service-user: string                         #When run as root, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Run a service without registering it to launch at login (or boot)
export extern "brew services run" [
    ...services: string                                 #Services to run (or --all)
    --all                                               #Run all services
    --file: path                                        #Use a custom plist/service file
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List information about all managed services
export extern "brew services list" [
    --json                                              #Output as JSON
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Stop a service immediately but keep it registered to launch at login (or boot)
export extern "brew services kill" [
    ...services: string                                 #Services to kill (or --all)
    --all                                               #Kill all services
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List all managed services (alias-like, more detail than `list`)
export extern "brew services info" [
    ...services: string                                 #Services to describe (or --all)
    --all                                               #Show info for all services
    --json                                              #Output as JSON
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove all unused services
export extern "brew services cleanup" [
    --sudo-service-user: string                         #When run as root on macOS, run services as this user
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Bundler for Homebrew/Cask/Mac App Store/VSCode/... dependencies
export extern "brew bundle" [
    subcommand?: string@"nu-complete brew bundle-subcommands" #Bundle subcommand
    --file: path                                        #Read/write the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Install (and upgrade by default) all dependencies from the Brewfile
export extern "brew bundle install" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --no-upgrade                                        #Don't upgrade outdated packages
    --upgrade                                           #Force upgrade outdated packages
    --upgrade-formulae: string                          #Comma-separated formulae to upgrade
    --upgrade-formula: string                           #Alias for --upgrade-formulae
    --jobs: int                                         #Run up to N formula installations in parallel
    --force(-f)                                         #Run with --force/--overwrite
    --cleanup                                           #Ask to perform cleanup after installing
    --force-cleanup                                     #Perform cleanup without prompting
    --zap                                               #Use zap instead of uninstall when cleaning up casks
    --no-vscode                                         #Skip VSCode extension entries
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --debug(-d)                                         #Display debugging information
    --help(-h)                                          #Show usage
]

# Write all installed casks/formulae/taps to a Brewfile
export extern "brew bundle dump" [
    --file: path                                        #Write the Brewfile to this location
    --global(-g)                                        #Write the global Brewfile
    --install                                           #Run install before dumping dependencies
    --force(-f)                                         #Overwrite an existing Brewfile
    --describe                                          #Annotate the Brewfile with package descriptions
    --no-restart                                        #Don't restart services after installing
    --all                                               #Include all dependency types
    --formula                                           #Dump formula entries
    --formulae                                          #Alias of --formula
    --brews                                             #Alias of --formula
    --no-formula                                        #Dump without formula entries
    --no-formulae                                       #Alias of --no-formula
    --no-brews                                          #Alias of --no-formula
    --no-dump-brew                                      #Dump without formula entries
    --cask                                              #Dump cask entries
    --casks                                             #Alias of --cask
    --no-cask                                           #Dump without cask entries
    --no-casks                                          #Alias of --no-cask
    --no-dump-cask                                      #Dump without cask entries
    --tap                                               #Dump tap entries
    --taps                                              #Alias of --tap
    --no-tap                                            #Dump without tap entries
    --no-taps                                           #Alias of --no-tap
    --no-dump-tap                                       #Dump without tap entries
    --mas                                               #Dump Mac App Store entries
    --no-mas                                            #Dump without Mac App Store entries
    --no-dump-mas                                       #Dump without Mac App Store entries
    --vscode                                            #Dump VSCode extensions
    --no-vscode                                         #Dump without VSCode extensions
    --no-dump-vscode                                    #Dump without VSCode extensions
    --go                                                #Dump Go packages
    --no-go                                             #Dump without Go packages
    --no-dump-go                                        #Dump without Go packages
    --cargo                                             #Dump Cargo packages
    --no-cargo                                          #Dump without Cargo packages
    --no-dump-cargo                                     #Dump without Cargo packages
    --uv                                                #Dump uv tools
    --no-uv                                             #Dump without uv tools
    --no-dump-uv                                        #Dump without uv tools
    --flatpak                                           #Dump Flatpak packages (Linux only)
    --no-flatpak                                        #Dump without Flatpak packages
    --no-dump-flatpak                                   #Dump without Flatpak packages
    --winget                                            #Dump WinGet packages (WSL only)
    --no-winget                                         #Dump without WinGet packages
    --no-dump-winget                                    #Dump without WinGet packages
    --krew                                              #Dump Krew plugins
    --no-krew                                           #Dump without Krew plugins
    --no-dump-krew                                      #Dump without Krew plugins
    --npm                                               #Dump npm packages
    --no-npm                                            #Dump without npm packages
    --no-dump-npm                                       #Dump without npm packages
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Uninstall dependencies not present in the Brewfile
export extern "brew bundle cleanup" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before cleaning up
    --force(-f)                                         #Actually perform cleanup (default is dry-run)
    --zap                                               #Clean up casks using the zap command
    --all                                               #Clean up all supported dependency types
    --formula                                           #Clean up formula dependencies
    --formulae                                          #Alias of --formula
    --brews                                             #Alias of --formula
    --no-formula                                        #Clean up without formula dependencies
    --no-formulae                                       #Alias of --no-formula
    --no-brews                                          #Alias of --no-formula
    --no-cleanup-brew                                   #Clean up without formula dependencies
    --cask                                              #Clean up cask dependencies
    --casks                                             #Alias of --cask
    --no-cask                                           #Clean up without cask dependencies
    --no-casks                                          #Alias of --no-cask
    --no-cleanup-cask                                   #Clean up without cask dependencies
    --tap                                               #Clean up tap dependencies
    --taps                                              #Alias of --tap
    --no-tap                                            #Clean up without tap dependencies
    --no-taps                                           #Alias of --no-tap
    --no-cleanup-tap                                    #Clean up without tap dependencies
    --mas                                               #Clean up Mac App Store dependencies
    --no-mas                                            #Clean up without Mac App Store dependencies
    --no-cleanup-mas                                    #Clean up without Mac App Store dependencies
    --vscode                                            #Clean up VSCode extensions
    --no-vscode                                         #Clean up without VSCode extensions
    --no-cleanup-vscode                                 #Clean up without VSCode extensions
    --go                                                #Clean up Go packages
    --no-go                                             #Clean up without Go packages
    --no-cleanup-go                                     #Clean up without Go packages
    --cargo                                             #Clean up Cargo packages
    --no-cargo                                          #Clean up without Cargo packages
    --no-cleanup-cargo                                  #Clean up without Cargo packages
    --uv                                                #Clean up uv tools
    --no-uv                                             #Clean up without uv tools
    --no-cleanup-uv                                     #Clean up without uv tools
    --flatpak                                           #Clean up Flatpak packages (Linux only)
    --no-flatpak                                        #Clean up without Flatpak packages
    --no-cleanup-flatpak                                #Clean up without Flatpak packages
    --winget                                            #Clean up WinGet packages (WSL only)
    --no-winget                                         #Clean up without WinGet packages
    --no-cleanup-winget                                 #Clean up without WinGet packages
    --krew                                              #Clean up Krew plugins
    --no-krew                                           #Clean up without Krew plugins
    --no-cleanup-krew                                   #Clean up without Krew plugins
    --npm                                               #Clean up npm packages
    --no-npm                                            #Clean up without npm packages
    --no-cleanup-npm                                    #Clean up without npm packages
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Check if all dependencies present in the Brewfile are installed
export extern "brew bundle check" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --no-upgrade                                        #Don't consider outdated packages a failure
    --install                                           #Run install before checking dependencies
    --verbose(-v)                                       #Make some output more verbose
    --quiet(-q)                                         #Make some output more quiet
    --debug(-d)                                         #Display debugging information
    --help(-h)                                          #Show usage
]

# List all dependencies present in the Brewfile
export extern "brew bundle list" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before listing dependencies
    --all                                               #List all dependency types
    --formula                                           #List formula entries
    --formulae                                          #Alias of --formula
    --brews                                             #Alias of --formula
    --cask                                              #List cask entries
    --casks                                             #Alias of --cask
    --tap                                               #List tap entries
    --taps                                              #Alias of --tap
    --mas                                               #List Mac App Store entries
    --vscode                                            #List VSCode extensions
    --go                                                #List Go packages
    --cargo                                             #List Cargo packages
    --uv                                                #List uv tools
    --flatpak                                           #List Flatpak packages
    --winget                                            #List WinGet packages
    --krew                                              #List Krew plugins
    --npm                                               #List npm packages
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Run an external command in an isolated `bundle exec` environment
export extern "brew bundle exec" [
    ...command: string                                  #Command to run
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before executing the command
    --services                                          #Temporarily start services while executing
    --check                                             #Check Brewfile dependencies before running
    --no-secrets                                        #Attempt to remove secrets from the environment
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Print the environment variables `bundle exec` would set
export extern "brew bundle env" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before printing the environment
    --check                                             #Check Brewfile dependencies first
    --no-secrets                                        #Attempt to remove secrets from the environment
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Edit the Brewfile in $EDITOR
export extern "brew bundle edit" [
    --file: path                                        #Edit the Brewfile at this location
    --global(-g)                                        #Edit the global Brewfile
    --install                                           #Run install before editing the Brewfile
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Add entries to the Brewfile
export extern "brew bundle add" [
    ...names: string                                    #Names to add
    --file: path                                        #Write the Brewfile to this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before adding entries
    --formula                                           #Add formula entries (default)
    --formulae                                          #Alias of --formula
    --brews                                             #Alias of --formula
    --cask                                              #Add cask entries
    --casks                                             #Alias of --cask
    --tap                                               #Add tap entries
    --taps                                              #Alias of --tap
    --vscode                                            #Add VSCode extension entries
    --go                                                #Add Go package entries
    --cargo                                             #Add Cargo package entries
    --uv                                                #Add uv tool entries
    --flatpak                                           #Add Flatpak package entries (Linux only)
    --krew                                              #Add Krew plugin entries
    --npm                                               #Add npm package entries
    --describe                                          #Add a description comment above each line
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove entries from the Brewfile
export extern "brew bundle remove" [
    ...names: string                                    #Names to remove
    --file: path                                        #Write the Brewfile to this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before removing entries
    --formula                                           #Remove formula entries
    --formulae                                          #Alias of --formula
    --brews                                             #Alias of --formula
    --cask                                              #Remove cask entries
    --casks                                             #Alias of --cask
    --tap                                               #Remove tap entries
    --taps                                              #Alias of --tap
    --mas                                               #Remove Mac App Store entries
    --vscode                                            #Remove VSCode extension entries
    --go                                                #Remove Go package entries
    --cargo                                             #Remove Cargo package entries
    --uv                                                #Remove uv tool entries
    --flatpak                                           #Remove Flatpak package entries
    --winget                                            #Remove WinGet package entries
    --krew                                              #Remove Krew plugin entries
    --npm                                               #Remove npm package entries
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Run the shell in a `bundle exec` environment
export extern "brew bundle sh" [
    --file: path                                        #Read the Brewfile from this location
    --global(-g)                                        #Use the global Brewfile
    --install                                           #Run install before starting the shell
    --services                                          #Temporarily start services while running
    --check                                             #Check Brewfile dependencies first
    --no-secrets                                        #Attempt to remove secrets from the environment
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Control Homebrew's anonymous aggregate analytics
export extern "brew analytics" [
    subcommand?: string@"nu-complete brew analytics-subcommands" #Analytics subcommand
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Display the current state of Homebrew's analytics
export extern "brew analytics state" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Turn analytics on
export extern "brew analytics on" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Turn analytics off
export extern "brew analytics off" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Delete the legacy analytics UUID
export extern "brew analytics regenerate-uuid" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Control whether Homebrew links external tap shell-completion files
export extern "brew completions" [
    subcommand?: string@"nu-complete brew completions-subcommands" #Completions subcommand
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Display the current state of Homebrew's completions
export extern "brew completions state" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Link Homebrew's external tap completions
export extern "brew completions link" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Unlink Homebrew's external tap completions
export extern "brew completions unlink" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Print export statements for `eval`-ing into the shell
export extern "brew shellenv" [
    shell?: string@"nu-complete brew shells"            #bash, csh, fish, pwsh, sh, tcsh or zsh
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List all locally installable formulae
export extern "brew formulae" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# List all locally installable casks
export extern "brew casks" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show or define an alias for a brew command
export extern "brew alias" [
    name?: string                                       #Alias name (or `name=command` to define one)
    command?: string                                    #Command to alias (if defining)
    --edit                                              #Open the aliases file in $EDITOR
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Remove brew command aliases
export extern "brew unalias" [
    ...aliases: string                                  #Aliases to remove
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show lists of built-in and external brew commands
export extern "brew commands" [
    --quiet(-q)                                         #List only command names
    --include-aliases                                   #Include aliases of internal commands
    --debug(-d)                                         #Display debugging information
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Display the path to the file that implements a brew command
export extern "brew command" [
    command: string                                     #brew command to locate
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Show help for a brew command
export extern "brew help" [
    command?: string                                    #Command to look up
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
]

# Open Homebrew's online documentation
export extern "brew docs" [
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Run a command in an environment populated by Homebrew formulae
export extern "brew exec" [
    command: string                                     #Command to run
    ...args: string                                     #Arguments for the command
    --formulae: string                                  #Comma-separated formulae to install and add to PATH
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Re-run the post-install steps for an installed formula
export extern "brew postinstall" [
    ...packages: string                                 #Installed formulae to re-run post-install for
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Find the formula or tap that provides a given binary
export extern "brew which-formula" [
    command: string                                     #Binary to look up
    --explain                                           #Explain in detail
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]

# Read all formulae in the specified or all installed taps
export extern "brew readall" [
    ...taps: string                                     #Taps to read (default: all installed)
    --aliases                                           #Verify aliases as well
    --syntax                                            #Read formula syntax instead of evaluating
    --eval-all                                          #Evaluate all formulae and casks
    --no-simulate                                       #Don't simulate other systems
    --os: string                                        #Operating system to simulate
    --arch: string                                      #CPU architecture to simulate
    --debug(-d)                                         #Display debugging information
    --quiet(-q)                                         #Make some output more quiet
    --verbose(-v)                                       #Make some output more verbose
    --help(-h)                                          #Show usage
]
