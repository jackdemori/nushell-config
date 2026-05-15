def "nu-complete fnm log-level" [] {
    [quiet, error, info]
}

def "nu-complete fnm version-file-strategy" [] {
    [
        {value: "local", description: "Use the local version defined within the current directory"}
        {value: "recursive", description: "Use the version defined within the current directory and all parent directories"}
    ]
}

def "nu-complete fnm shell" [] {
    [bash, zsh, fish, powershell]
}

def "nu-complete fnm progress" [] {
    [
        {value: "auto", description: "Show progress bar automatically"}
        {value: "never", description: "Never show progress bar"}
        {value: "always", description: "Always show progress bar"}
    ]
}

def "nu-complete fnm sort" [] {
    [
        {value: "desc", description: "Sort versions in descending order (latest to earliest)"}
        {value: "asc", description: "Sort versions in ascending order (earliest to latest)"}
    ]
}

def "nu-complete fnm resolve-engines" [] {
    [true, false]
}

export extern "fnm" [
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
    -V
    --version
]

# List all remote Node.js versions
export extern "fnm list-remote" [
    --filter: string
    --lts: string
    --sort: string@"nu-complete fnm sort"
    --latest
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# List all locally installed Node.js versions
export extern "fnm list" [
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Install a new Node.js version
export extern "fnm install" [
    version?: string
    --lts
    --latest
    --progress: string@"nu-complete fnm progress"
    --use
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Change Node.js version
export extern "fnm use" [
    version?: string
    --install-if-missing
    --silent-if-unchanged
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Print and set up required environment variables for fnm
export extern "fnm env" [
    --shell: string@"nu-complete fnm shell"
    --json
    --use-on-cd
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Print shell completions to stdout
export extern "fnm completions" [
    --shell: string@"nu-complete fnm shell"
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Alias a version to a common name
export extern "fnm alias" [
    to_version: string
    name: string
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Remove an alias definition
export extern "fnm unalias" [
    requested_alias: string
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Set a version as the default version
export extern "fnm default" [
    version?: string
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Print the current Node.js version
export extern "fnm current" [
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Run a command within fnm context
export extern "fnm exec" [
    ...arguments: string
    --using: string
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]

# Uninstall a Node.js version
export extern "fnm uninstall" [
    version?: string
    --node-dist-mirror: string
    --fnm-dir: path
    --log-level: string@"nu-complete fnm log-level"
    --arch: string
    --version-file-strategy: string@"nu-complete fnm version-file-strategy"
    --corepack-enabled
    --resolve-engines: string@"nu-complete fnm resolve-engines"
    -h
    --help
]
