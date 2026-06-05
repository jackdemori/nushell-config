def "nu-complete dotnet verbosity" [] {
    [quiet, minimal, normal, detailed, diagnostic]
}

def "nu-complete dotnet format severity" [] {
    [info, warn, error, hidden]
}

def "nu-complete dotnet new templates" [] {
    ^dotnet new list | lines | skip 4 | where ($it | str trim) != ""
        | parse --regex '(?P<description>.+?)\s{2,}(?P<value>\S+)\s{2,}.*'
}

def "nu-complete dotnet tool list" [] {
    ^dotnet tool list | lines | skip 2
        | parse --regex '(?P<value>\S+)\s+(?P<description>.+)'
}

# Static subcommand completers — keep tab-completion fast and prevent nu from
# falling back to filesystem completion on parent externs (e.g. `dotnet ` or
# `dotnet tool ` should show the subcommand list, not files in the cwd).

def "nu-complete dotnet subcommands" [] {
    [
        {value: "build",         description: "Build a .NET project"}
        {value: "build-server",  description: "Interact with servers started by a build"}
        {value: "clean",         description: "Clean build outputs of a .NET project"}
        {value: "completions",   description: "Generate completion scripts for supported shells"}
        {value: "dev-certs",     description: "Create and manage development certificates"}
        {value: "format",        description: "Apply style preferences to a project or solution"}
        {value: "fsi",           description: "Start F# Interactive / execute F# scripts"}
        {value: "help",          description: "Open the reference page in a browser for a command"}
        {value: "msbuild",       description: "Run Microsoft Build Engine (MSBuild) commands"}
        {value: "new",           description: "Create a new .NET project or file"}
        {value: "nuget",         description: "Additional NuGet commands"}
        {value: "pack",          description: "Create a NuGet package"}
        {value: "package",       description: "Search, add, remove, or list package references"}
        {value: "project",       description: "Convert file-based programs to project-based programs"}
        {value: "publish",       description: "Publish a .NET project for deployment"}
        {value: "purge",         description: "Inspect or uninstall stale .NET SDKs and runtimes (custom)"}
        {value: "reference",     description: "Add, remove, or list project-to-project references"}
        {value: "restore",       description: "Restore dependencies specified in a .NET project"}
        {value: "run",           description: "Build and run a .NET project"}
        {value: "sdk",           description: "Manage .NET SDK installation"}
        {value: "sln",           description: "Modify Visual Studio solution files (alias of solution)"}
        {value: "solution",      description: "Modify Visual Studio solution files"}
        {value: "store",         description: "Store the specified assemblies in the runtime package store"}
        {value: "test",          description: "Run unit tests using the test runner"}
        {value: "tool",          description: "Install or manage tools that extend .NET"}
        {value: "user-jwts",     description: "Manage JSON Web Tokens in development"}
        {value: "user-secrets",  description: "Manage development user secrets"}
        {value: "vstest",        description: "Run Microsoft Test Engine (VSTest) commands"}
        {value: "watch",         description: "Run a command and re-run it when files change"}
        {value: "workload",      description: "Install or work with workloads"}
    ]
}

def "nu-complete dotnet tool subcommands" [] {
    [
        {value: "install",   description: "Install a global or local tool"}
        {value: "uninstall", description: "Uninstall a global or local tool"}
        {value: "update",    description: "Update a global or local tool"}
        {value: "list",      description: "List installed tools"}
        {value: "run",       description: "Run a local tool"}
        {value: "exec",      description: "Execute a tool from source without permanently installing it"}
        {value: "execute",   description: "Long form of `dotnet tool exec`"}
        {value: "search",    description: "Search for tools on NuGet.org"}
        {value: "restore",   description: "Restore tools defined in the local tool manifest"}
    ]
}

def "nu-complete dotnet workload subcommands" [] {
    [
        {value: "install",   description: "Install one or more workloads"}
        {value: "update",    description: "Update all installed workloads"}
        {value: "list",      description: "List available workloads"}
        {value: "search",    description: "Search for available workloads"}
        {value: "uninstall", description: "Uninstall one or more workloads"}
        {value: "repair",    description: "Repair workload installations"}
        {value: "restore",   description: "Restore workloads required for a project"}
        {value: "clean",     description: "Remove leftover workload components"}
        {value: "config",    description: "Modify or display workload configuration values"}
        {value: "history",   description: "Show a history of workload installation actions"}
    ]
}

def "nu-complete dotnet nuget subcommands" [] {
    [
        {value: "push",    description: "Push a NuGet package to the server"}
        {value: "delete",  description: "Delete a NuGet package from the server"}
        {value: "list",    description: "Manage NuGet package sources"}
        {value: "locals",  description: "Clear or list local NuGet resources"}
        {value: "sign",    description: "Sign a NuGet package with a certificate"}
        {value: "trust",   description: "Manage trusted signers for NuGet packages"}
        {value: "verify",  description: "Verify a NuGet package signature"}
        {value: "why",     description: "Show the dependency graph for a package"}
    ]
}

def "nu-complete dotnet nuget trust subcommands" [] {
    [
        {value: "list",        description: "List trusted signers"}
        {value: "author",      description: "Add an author to the trusted signers"}
        {value: "repository",  description: "Add a repository to the trusted signers"}
        {value: "source",      description: "Add trusted signers from a NuGet source"}
        {value: "certificate", description: "Add a certificate to the trusted signers"}
        {value: "remove",      description: "Remove an entry from the trusted signers"}
        {value: "sync",        description: "Sync a trusted signer with the latest certificate"}
    ]
}

def "nu-complete dotnet package subcommands" [] {
    [
        {value: "add",      description: "Add a NuGet package reference to the project"}
        {value: "list",     description: "List package references of the project or solution"}
        {value: "remove",   description: "Remove a NuGet package reference from the project"}
        {value: "search",   description: "Search for NuGet packages"}
        {value: "download", description: "Download a NuGet package to a local folder"}
        {value: "update",   description: "Update referenced packages in a project or solution"}
    ]
}

def "nu-complete dotnet reference subcommands" [] {
    [
        {value: "add",    description: "Add a project-to-project reference"}
        {value: "list",   description: "List all project-to-project references"}
        {value: "remove", description: "Remove a project-to-project reference"}
    ]
}

def "nu-complete dotnet solution subcommands" [] {
    [
        {value: "add",     description: "Add one or more projects to a solution file"}
        {value: "list",    description: "List all projects in a solution file"}
        {value: "remove",  description: "Remove one or more projects from a solution file"}
        {value: "migrate", description: "Generate a .slnx file from a .sln file"}
    ]
}

def "nu-complete dotnet sdk subcommands" [] {
    [{value: "check", description: "Check installed SDKs and runtimes for updates"}]
}

def "nu-complete dotnet build-server subcommands" [] {
    [{value: "shutdown", description: "Shut down build servers"}]
}

def "nu-complete dotnet project subcommands" [] {
    [{value: "convert", description: "Convert a file-based program to a project-based program"}]
}

def "nu-complete dotnet completions subcommands" [] {
    [{value: "script", description: "Generate the completion script for a supported shell"}]
}

# .NET CLI
export extern "dotnet" [
    command?: string@"nu-complete dotnet subcommands"   #Subcommand to run
    --info                                              #Display .NET information
    --list-sdks                                         #Display the installed SDKs
    --list-runtimes                                     #Display the installed runtimes
    --version                                           #Display .NET SDK version in use
    -d                                                  #Enable diagnostic output
    --diagnostics                                       #Enable diagnostic output
    -h                                                  #Show command line help
    --help                                              #Show command line help
]

# Build a .NET project
export extern "dotnet build" [
    project?: path                                      #The project or solution file to build
    --configuration(-c): string                         #The configuration to use for building (default: Debug)
    --framework(-f): string                             #The target framework to build for
    --runtime(-r): string                               #The target runtime to build for
    --output(-o): path                                  #The output directory to place built artifacts in
    --artifacts-path: path                              #The artifacts path for all output
    --no-restore                                        #Do not restore the project before building
    --no-incremental                                    #Do not use incremental building
    --no-dependencies                                   #Do not build project-to-project references
    --self-contained                                    #Publish the .NET runtime with your application
    --no-self-contained                                 #Publish as a framework dependent application
    --use-current-runtime                               #Use current runtime as the target runtime
    --version-suffix: string                            #Set the value of the $(VersionSuffix) property
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --no-logo                                           #Do not display the startup banner or copyright message
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
]

# Build and run a .NET project
export extern "dotnet run" [
    ...args: string                                     #Arguments passed to the application
    --configuration(-c): string                         #The configuration to run for (default: Debug)
    --framework(-f): string                             #The target framework to run for
    --runtime(-r): string                               #The target runtime to run for
    --project: path                                     #Path of the project file to run
    --file: path                                        #The path to the file-based app to run
    --launch-profile: string                            #The name of the launch profile to use
    --no-launch-profile                                 #Do not attempt to use launchSettings.json
    --device: string                                    #Device identifier to use for running
    --list-devices                                      #List available devices for running
    --no-build                                          #Do not build the project before running
    --no-restore                                        #Do not restore the project before building
    --no-cache                                          #Skip up-to-date checks and always rebuild
    --interactive                                       #Allow the command to stop and wait for user input
    --environment(-e): string                           #Set an environment variable (NAME="VALUE")
    --self-contained                                    #Publish the .NET runtime with your application
    --no-self-contained                                 #Publish as a framework dependent application
    --artifacts-path: path                              #The artifacts path for all output
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
]

# Run unit tests using the test runner
export extern "dotnet test" [
    project?: path                                      #The project or solution file to test
    --settings(-s): path                                #The settings file to use when running tests
    --list-tests(-t)                                    #List the discovered tests instead of running them
    --environment(-e): string                           #Set an environment variable (NAME="VALUE")
    --filter: string                                    #Run tests that match the given expression
    --test-adapter-path: path                           #Path to custom test adapters
    --configuration(-c): string                         #The configuration to use for running tests
    --framework(-f): string                             #The target framework to run tests for
    --runtime(-r): string                               #The target runtime to test for
    --output(-o): path                                  #The output directory to place built artifacts in
    --artifacts-path: path                              #The artifacts path for all output
    --diag(-d): path                                    #Enable verbose logging to the specified file
    --no-build                                          #Do not build the project before testing
    --no-restore                                        #Do not restore the project before building
    --collect: string                                   #Enable data collector for the test run
    --blame                                             #Run tests in blame mode
    --blame-crash                                       #Run tests in blame mode and collect a crash dump on failure
    --blame-crash-dump-type: string                     #Crash dump type (full|mini|heap|triage)
    --blame-crash-collect-always                        #Collect a crash dump on expected and unexpected exits
    --blame-hang                                        #Run tests in blame mode and detect hangs
    --blame-hang-dump-type: string                      #Hang dump type (full|mini|heap|triage)
    --blame-hang-timeout: string                        #Per-test timeout before a hang dump is taken
    --logger(-l): string                                #The logger to use for test results
    --results-directory: path                           #The directory where the test results will be placed
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --interactive                                       #Allow the command to stop and wait for user input
    --no-logo                                           #Do not display the startup banner or copyright message
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
]

# Publish a .NET project for deployment
export extern "dotnet publish" [
    project?: path                                      #The project or solution file to publish
    --configuration(-c): string                         #The configuration to use for publishing
    --framework(-f): string                             #The target framework to publish for
    --runtime(-r): string                               #The target runtime to publish for
    --output(-o): path                                  #The output directory to place published artifacts in
    --artifacts-path: path                              #The artifacts path for all output
    --manifest: path                                    #Path to a target manifest file for package exclusion
    --no-build                                          #Do not build the project before publishing
    --no-restore                                        #Do not restore the project before building
    --self-contained                                    #Publish the .NET runtime with your application
    --no-self-contained                                 #Publish as a framework dependent application
    --use-current-runtime                               #Use current runtime as the target runtime
    --version-suffix: string                            #Set the value of the $(VersionSuffix) property
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --no-logo                                           #Do not display the startup banner or copyright message
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
]

# Clean build outputs of a .NET project
export extern "dotnet clean" [
    project?: path                                      #The project or solution file to clean
    --configuration(-c): string                         #The configuration to clean for (default: Debug)
    --framework(-f): string                             #The target framework to clean for
    --runtime(-r): string                               #The target runtime to clean for
    --output(-o): path                                  #The directory containing the build artifacts to clean
    --artifacts-path: path                              #The artifacts path for all output
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --no-logo                                           #Do not display the startup banner or copyright message
    --disable-build-servers                             #Force the command to ignore any persistent build servers
]

# Restore dependencies specified in a .NET project
export extern "dotnet restore" [
    project?: path                                      #The project or solution file to restore
    --source(-s): string                                #The NuGet package source to use for the restore
    --packages: path                                    #The directory to restore packages to
    --use-current-runtime                               #Use current runtime as the target runtime
    --runtime(-r): string                               #The target runtime to restore for
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --configfile: path                                  #The NuGet configuration file to use
    --no-http-cache                                     #Disable HTTP caching for packages
    --ignore-failed-sources                             #Treat package source failures as warnings
    --force(-f)                                         #Force all dependencies to be resolved
    --no-dependencies                                   #Do not restore project-to-project references
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --artifacts-path: path                              #The artifacts path for all output
    --use-lock-file                                     #Enable project lock-file generation
    --locked-mode                                       #Don't allow updating the project lock file
    --lock-file-path: path                              #Output location for the project lock file
    --force-evaluate                                    #Force restore to re-evaluate all dependencies
    --no-logo                                           #Do not display the startup banner or copyright message
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
]

# Create a NuGet package
export extern "dotnet pack" [
    project?: path                                      #The project or solution file to pack
    --configuration(-c): string                         #The configuration to use for packing
    --output(-o): path                                  #The output directory to place built packages in
    --artifacts-path: path                              #The artifacts path for all output
    --no-build                                          #Do not build the project before packing
    --no-restore                                        #Do not restore the project before building
    --include-symbols                                   #Include packages with symbols
    --include-source                                    #Include PDBs and source files
    --serviceable(-s)                                   #Set the serviceable flag in the package
    --version: string                                   #The version of the package to create
    --version-suffix: string                            #Set the value of the $(VersionSuffix) property
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --no-logo                                           #Do not display the startup banner or copyright message
    --use-current-runtime                               #Use current runtime as the target runtime
    --runtime(-r): string                               #The target runtime to build for
    --disable-build-servers                             #Force the command to ignore any persistent build servers
]

# Create a new .NET project or file
export extern "dotnet new" [
    template?: string@"nu-complete dotnet new templates" #A short name of the template to create
    --output(-o): path                                  #Location to place the generated output
    --name(-n): string                                  #The name for the output being created
    --dry-run                                           #Display a summary of what would happen
    --force                                             #Force content to be generated even if it would change existing files
    --no-update-check                                   #Disable checking for template package updates
    --project: path                                     #The project for context evaluation
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Install a template package
export extern "dotnet new install" [
    package: string                                     #The template package to install
    --interactive                                       #Allow the command to stop and wait for user input
    --add-source: string                                #Specify a NuGet source to use during install
    --nuget-source: string                              #Alias for --add-source
    --force                                             #Allow reinstalling an existing template package
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Uninstall a template package
export extern "dotnet new uninstall" [
    package: string                                     #The template package to uninstall
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# List available templates
export extern "dotnet new list" [
    template_name?: string                              #Filter by template name
    --author: string                                    #Filter by template author
    --language: string                                  #Filter by template language
    --type: string                                      #Filter by template type
    --tag: string                                       #Filter by template tag
    --ignore-constraints                                #Disable template constraint checking
    --columns-all                                       #Display all columns in the output
    --columns: string                                   #Comma-separated columns to display (author|language|tags|type)
    --output(-o): path                                  #Location to place the generated output
    --project: path                                     #The project for context evaluation
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Search for templates on NuGet.org
export extern "dotnet new search" [
    template_name: string                               #The template name to search for
    --author: string                                    #Filter by template author
    --language: string                                  #Filter by template language
    --type: string                                      #Filter by template type
    --tag: string                                       #Filter by template tag
    --package: string                                   #Filter by the NuGet package name
    --columns-all                                       #Display all columns in the output
    --columns: string                                   #Comma-separated columns to display
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Instantiate a template with the given short name
export extern "dotnet new create" [
    template_short_name?: string@"nu-complete dotnet new templates" #A short name of the template to create
    ...template_args: string                            #Template-specific options
    --output(-o): path                                  #Location to place the generated output
    --name(-n): string                                  #The name for the output being created
    --dry-run                                           #Display a summary of what would happen
    --force                                             #Force content to be generated
    --no-update-check                                   #Disable checking for template package updates
    --project: path                                     #The project for context evaluation
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Show the details for a specified template package
export extern "dotnet new details" [
    package_identifier: string                          #Package identifier to inspect
    --interactive                                       #Allow the command to stop and wait for user input
    --add-source: string                                #Specify a NuGet source to use
    --nuget-source: string                              #Alias for --add-source
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Check installed template packages for updates and apply them
export extern "dotnet new update" [
    --interactive                                       #Allow the command to stop and wait for user input
    --add-source: string                                #Specify a NuGet source to use
    --nuget-source: string                              #Alias for --add-source
    --check-only                                        #Only check for updates without applying them
    --dry-run                                           #Only check for updates without applying them
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --diagnostics(-d)                                   #Enable diagnostic output
]

# Apply style preferences to a project or solution
export extern "dotnet format" [
    project?: path                                      #The project or solution file to format
    --diagnostics: string                               #Diagnostic ids to use as a filter
    --exclude-diagnostics: string                       #Diagnostic ids to ignore
    --severity: string@"nu-complete dotnet format severity" #The severity of diagnostics to fix
    --no-restore                                        #Do not execute an implicit restore before formatting
    --verify-no-changes                                 #Verify no formatting changes would be performed
    --include: string                                   #Relative file or folder paths to include
    --exclude: string                                   #Relative file or folder paths to exclude
    --include-generated                                 #Format files generated by the SDK
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --binarylog: path                                   #Log project or solution load information to a binary log file
    --report: path                                      #Produce a JSON report in the given directory
    --version                                           #Show version information
]

# Format whitespace
export extern "dotnet format whitespace" [
    project?: path                                      #The project or solution file to format
]

# Run code style analysers and apply fixes
export extern "dotnet format style" [
    project?: path                                      #The project or solution file to format
]

# Run 3rd party analysers and apply fixes
export extern "dotnet format analyzers" [
    project?: path                                      #The project or solution file to format
]

# Start a file watcher that runs a command when files change
export extern "dotnet watch" [
    ...args: string                                     #The command to run (e.g. run, test, build)
    --project: path                                     #Path to the project file to watch
    --file: path                                        #Path to the file-based app to watch
    --launch-profile: string                            #The launch profile to use
    --no-launch-profile                                 #Do not attempt to use launchSettings.json
    --device: string                                    #Device identifier to run on
    --framework(-f): string                             #The target framework to build for
    --configuration(-c): string                         #The configuration to run for
    --runtime(-r): string                               #The target runtime
    --arch(-a): string                                  #The target architecture
    --os: string                                        #The target operating system
    --self-contained                                    #Publish the .NET runtime with your application
    --no-self-contained                                 #Publish as a framework dependent application
    --artifacts-path: path                              #The artifacts path for all output
    --list                                              #List all discovered files without starting the watcher
    --no-hot-reload                                     #Suppress hot reload for supported apps
    --non-interactive                                   #Runs dotnet-watch in non-interactive mode
    --interactive                                       #Allow the command to stop and wait for user input
    --no-restore                                        #Do not restore the project before building
    --disable-build-servers                             #Force the command to ignore any persistent build servers
    --verbose                                           #Show verbose output
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --quiet(-q)                                         #Suppress all output except warnings and errors
    --version                                           #Show version information
]

# Modify Visual Studio solution files
export extern "dotnet solution" [
    subcommand?: string@"nu-complete dotnet solution subcommands" #Solution subcommand
]

# Add one or more projects to a solution file
export extern "dotnet solution add" [
    ...project_path: path                               #The project files to add
    --in-root                                           #Place the project in the root of the solution
    --solution-folder(-s): string                       #The destination solution folder path
    --include-references                                #Recursively add referenced projects too
]

# List all projects in a solution file
export extern "dotnet solution list" [
    --solution-folders                                  #List only the solution folders
]

# Remove one or more projects from a solution file
export extern "dotnet solution remove" [
    ...project_path: path                               #The project files to remove
]

# Generate a .slnx file from a .sln file
export extern "dotnet solution migrate" [
    sln_file?: path                                     #The solution file to migrate
]

# Modify Visual Studio solution files (alias of `dotnet solution`)
export extern "dotnet sln" [
    subcommand?: string@"nu-complete dotnet solution subcommands" #Solution subcommand
]

# Add one or more projects to a solution file
export extern "dotnet sln add" [
    ...project_path: path                               #The project files to add
    --in-root                                           #Place the project in the root of the solution
    --solution-folder(-s): string                       #The destination solution folder path
    --include-references                                #Recursively add referenced projects too
]

# List all projects in a solution file
export extern "dotnet sln list" [
    --solution-folders                                  #List only the solution folders
]

# Generate a .slnx file from a .sln file
export extern "dotnet sln migrate" [
    sln_file?: path                                     #The solution file to migrate
]

# Remove one or more projects from a solution file
export extern "dotnet sln remove" [
    ...project_path: path                               #The project files to remove
]

# Search for, add, remove, or list package references
export extern "dotnet package" [
    subcommand?: string@"nu-complete dotnet package subcommands" #Package subcommand
]

# Search for NuGet packages
export extern "dotnet package search" [
    search_term: string                                 #The search term to search for
    --source: string                                    #The NuGet package source to search
    --exact-match                                       #Require an exact match
    --take: int                                         #Number of results to return
    --skip: int                                         #Number of results to skip
    --prerelease                                        #Include prerelease packages
    --interactive                                       #Allow the command to stop and wait for user input
    --configfile: path                                  #The NuGet configuration file to use
    --format: string                                    #Output format (table | json)
    --verbosity: string                                 #Display this amount of detail in the output
]

# Add a NuGet package reference to the project
export extern "dotnet package add" [
    package_id: string                                  #The NuGet package to add
    --version: string                                   #The version of the package to add
    --framework(-f): string                             #Add the reference only to a specific framework
    --no-restore                                        #Do not restore after adding the reference
    --source(-s): string                                #The NuGet package source to use
    --package-directory: path                           #The directory to restore packages to
    --prerelease                                        #Use the latest prerelease package
    --interactive                                       #Allow the command to stop and wait for user input
    --project: path                                     #The project file to operate on
    --file: path                                        #The file-based app to operate on
]

# List all package references of the project or solution
export extern "dotnet package list" [
    --outdated                                          #List packages that have newer versions available
    --deprecated                                        #List packages that have been deprecated
    --vulnerable                                        #List packages that have known vulnerabilities
    --include-transitive                                #Include transitive packages
    --include-prerelease                                #Consider prerelease packages when looking for updates
    --highest-patch                                     #Consider only packages with a matching major and minor version
    --highest-minor                                     #Consider only packages with a matching major version
    --source(-s): string                                #The NuGet source to use when looking for updates
    --config: path                                      #The NuGet configuration file to use
    --configfile: path                                  #The NuGet configuration file to use
    --framework(-f): string                             #Show packages only for the specified framework
    --format: string                                    #The output format (console or json)
    --output-version: string                            #Version of the output format to use
    --interactive                                       #Allow the command to stop and wait for user input
    --no-restore                                        #Do not restore before running the command
    --project: path                                     #The project file to operate on
    --file: path                                        #The file-based app to operate on
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
]

# Remove a NuGet package reference from the project
export extern "dotnet package remove" [
    package_name: string                                #The NuGet package to remove
    --interactive                                       #Allow the command to stop and wait for user input
    --project: path                                     #The project file to operate on
    --file: path                                        #The file-based app to operate on
]

# Download a NuGet package to a local folder without requiring a project file
export extern "dotnet package download" [
    ...packages: string                                 #Package id or 'id@version' to download
    --allow-insecure-connections                        #Allow downloading from HTTP sources
    --configfile: path                                  #The NuGet configuration file to use
    --interactive                                       #Allow the command to stop and wait for user input
    --output(-o): path                                  #Directory where the package will be downloaded
    --source(-s): string                                #The NuGet source to use
    --prerelease                                        #Allow prerelease packages to be downloaded
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Update referenced packages in a project or solution
export extern "dotnet package update" [
    ...packages: string                                 #Package id or 'id@version' to update
    --project: path                                     #Path to a project, solution or project directory
    --file: path                                        #Path to a project, solution or project directory
    --vulnerable                                        #Upgrade packages with known vulnerabilities
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Add, remove, or list project-to-project references
export extern "dotnet reference" [
    subcommand?: string@"nu-complete dotnet reference subcommands" #Reference subcommand
    --project: path                                     #The project file to operate on
]

# Add a project-to-project reference
export extern "dotnet reference add" [
    ...project_path: path                               #The project references to add
    --framework(-f): string                             #Add the reference only for a specific framework
    --interactive                                       #Allow the command to stop and wait for user input
    --project: path                                     #The project file to operate on
]

# List all project-to-project references
export extern "dotnet reference list" [
    --project: path                                     #The project file to operate on
]

# Remove a project-to-project reference
export extern "dotnet reference remove" [
    ...project_path: path                               #The project references to remove
    --framework(-f): string                             #Remove the reference only for a specific framework
    --project: path                                     #The project file to operate on
]

# Provides additional NuGet commands
export extern "dotnet nuget" [
    subcommand?: string@"nu-complete dotnet nuget subcommands" #NuGet subcommand
]

# Push a NuGet package to the server
export extern "dotnet nuget push" [
    package: path                                       #The package file to push
    --source(-s): string                                #The server URL
    --symbol-source: string                             #The symbol server URL
    --timeout(-t): int                                  #Timeout in seconds
    --api-key(-k): string                               #The API key for the server
    --symbol-api-key: string                            #The API key for the symbol server
    --disable-buffering(-d)                             #Disable buffering when pushing to an HTTP(S) server
    --no-symbols(-n)                                    #Do not push symbols
    --force-english-output                              #Force the application to run using English culture
    --no-service-endpoint                               #Do not append "api/v2/package" to the source URL
    --interactive                                       #Allow the command to stop and wait for user input
    --skip-duplicate                                    #Skip packages that already exist on the server
    --configfile: path                                  #The NuGet configuration file to use
]

# Delete a NuGet package from the server
export extern "dotnet nuget delete" [
    package_name?: string                               #The package to delete
    package_version?: string                            #The version of the package to delete
    --source(-s): string                                #The server URL
    --non-interactive                                   #Do not prompt for user input
    --api-key(-k): string                               #The API key for the server
    --force-english-output                              #Force the application to run using English culture
    --no-service-endpoint                               #Do not append "api/v2/package" to the source URL
    --interactive                                       #Allow the command to stop and wait for user input
]

# List configured NuGet sources
export extern "dotnet nuget list source" [
    --format: string                                    #Output format (short or detailed)
    --configfile: path                                  #The NuGet configuration file to use
]

# Clear or list local NuGet resources
export extern "dotnet nuget locals" [
    cache_location?: string                             #The cache location (all, http-cache, global-packages, temp, plugins-cache)
    --list(-l)                                          #List the specified cache location
    --clear(-c)                                         #Clear the specified cache location
    --force-english-output                              #Force the application to run using English culture
]

# Sign a NuGet package with a certificate
export extern "dotnet nuget sign" [
    ...package_paths: path                              #NuGet packages to sign
    --output(-o): path                                  #Output directory for the signed packages
    --certificate-path: path                            #Path to the certificate file
    --certificate-store-name: string                    #Certificate store name
    --certificate-store-location: string                #Certificate store location
    --certificate-subject-name: string                  #Subject name of the certificate
    --certificate-fingerprint: string                   #Fingerprint of the certificate
    --certificate-password: string                      #Password for the certificate
    --hash-algorithm: string                            #Hash algorithm for signing
    --timestamper: string                               #URL of the trusted timestamping authority
    --timestamp-hash-algorithm: string                  #Hash algorithm for the timestamp
    --overwrite                                         #Allow overwriting an existing signature
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Manage trusted signers for NuGet packages
export extern "dotnet nuget trust" [
    subcommand?: string@"nu-complete dotnet nuget trust subcommands" #Trust subcommand
    --configfile: path                                  #The NuGet configuration file to use
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# List trusted signers
export extern "dotnet nuget trust list" []

# Add an author to the trusted signers
export extern "dotnet nuget trust author" [
    name: string                                        #The trusted signer name
    package: path                                       #Path to the signed package
]

# Add a repository to the trusted signers
export extern "dotnet nuget trust repository" [
    name: string                                        #The trusted signer name
    package: path                                       #Path to the signed package
]

# Add trusted signers from a NuGet source
export extern "dotnet nuget trust source" [
    name: string                                        #The trusted signer name
]

# Add a certificate to the trusted signers
export extern "dotnet nuget trust certificate" [
    name: string                                        #The trusted signer name
    fingerprint: string                                 #The certificate fingerprint
]

# Remove an entry from the trusted signers
export extern "dotnet nuget trust remove" [
    name: string                                        #The trusted signer to remove
]

# Sync a trusted signer with the latest certificate from a repository
export extern "dotnet nuget trust sync" [
    name: string                                        #The trusted signer to sync
]

# Verify a NuGet package signature
export extern "dotnet nuget verify" [
    ...package_paths: path                              #NuGet packages to verify
    --all                                               #Verify all certificate properties
    --certificate-fingerprint: string                   #Required certificate fingerprint
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Show the dependency graph for a particular package
export extern "dotnet nuget why" [
    project_or_solution: path                           #Project, solution file, file-based app, or project directory
    package: string                                     #The package name to look up
    --framework(-f): string                             #Target framework(s) for which to show graphs
]

# Manage NuGet package sources
export extern "dotnet nuget list" []

# Install or manage tools that extend the .NET experience
export extern "dotnet tool" [
    subcommand?: string@"nu-complete dotnet tool subcommands" #Tool subcommand
]

# Install a global or local tool
export extern "dotnet tool install" [
    package_id: string                                  #The NuGet package ID of the tool to install
    --global(-g)                                        #Install the tool globally
    --local                                             #Install the tool locally
    --tool-path: path                                   #The directory where the tool will be installed
    --version: string                                   #The version of the tool to install
    --configfile: path                                  #The NuGet configuration file to use
    --tool-manifest: path                               #Path to the manifest file
    --add-source: string                                #Add an additional NuGet package source
    --source: string                                    #Replace all NuGet package sources with this one
    --framework: string                                 #The target framework to install the tool for
    --prerelease                                        #Include prerelease packages
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --allow-downgrade                                   #Allow downgrade when installing a tool package
    --allow-roll-forward                                #Allow rolling forward to newer .NET runtime versions
    --arch(-a): string                                  #The target architecture
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --create-manifest-if-needed                         #Create the tool manifest if it does not exist
]

# Uninstall a global or local tool
export extern "dotnet tool uninstall" [
    package_id: string                                  #The NuGet package ID of the tool to uninstall
    --global(-g)                                        #Uninstall a globally installed tool
    --local                                             #Uninstall a locally installed tool
    --tool-path: path                                   #The directory containing the tool to uninstall
    --tool-manifest: path                               #Path to the manifest file
]

# Update a global or local tool
export extern "dotnet tool update" [
    package_id?: string                                 #The NuGet package ID of the tool to update
    --global(-g)                                        #Update a globally installed tool
    --local                                             #Update a locally installed tool
    --tool-path: path                                   #The directory containing the tool to update
    --version: string                                   #The version to update to
    --configfile: path                                  #The NuGet configuration file to use
    --tool-manifest: path                               #Path to the manifest file
    --add-source: string                                #Add an additional NuGet package source
    --source: string                                    #Replace all NuGet package sources with this one
    --framework: string                                 #The target framework to update the tool for
    --prerelease                                        #Include prerelease packages
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --allow-downgrade                                   #Allow package downgrade
    --all                                               #Update all tools (when paired with --global or --local)
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# List installed tools
export extern "dotnet tool list" [
    package_id?: string                                 #The NuGet package ID of the tool
    --global(-g)                                        #List globally installed tools
    --local                                             #List locally installed tools
    --tool-path: path                                   #The directory containing the tools to list
    --tool-manifest: path                               #Path to the manifest file
    --format: string                                    #Output format (json | table)
]

# Run a local tool
export extern "dotnet tool run" [
    command_name: string@"nu-complete dotnet tool list" #The command name of the tool to run
    ...args: string                                     #Arguments to pass to the tool
    --allow-roll-forward                                #Allow rolling forward to newer .NET runtime versions
]

# Search for tools in NuGet.org
export extern "dotnet tool search" [
    search_term: string                                 #The search term
    --detail                                            #Show detailed results
    --skip: int                                         #Number of results to skip
    --take: int                                         #Number of results to return
    --prerelease                                        #Include prerelease packages
]

# Restore tools defined in the local tool manifest
export extern "dotnet tool restore" [
    --configfile: path                                  #The NuGet configuration file to use
    --tool-manifest: path                               #Path to the manifest file
    --add-source: string                                #Add an additional NuGet package source
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Execute a tool from source without permanently installing it
export extern "dotnet tool exec" [
    package_id: string                                  #The NuGet package ID of the tool to run
    ...command_arguments: string                        #Arguments forwarded to the tool
    --version: string                                   #The version of the tool package to install
    --allow-roll-forward                                #Allow rolling forward to newer .NET runtime versions
    --prerelease                                        #Include prerelease packages
    --configfile: path                                  #The NuGet configuration file to use
    --source: string                                    #Replace all NuGet sources with this one
    --add-source: string                                #Add an additional NuGet source
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
]

# Long form of `dotnet tool exec`
export extern "dotnet tool execute" [
    package_id: string                                  #The NuGet package ID of the tool to run
    ...command_arguments: string                        #Arguments forwarded to the tool
    --version: string                                   #The version of the tool package to install
    --allow-roll-forward                                #Allow rolling forward to newer .NET runtime versions
    --prerelease                                        #Include prerelease packages
    --configfile: path                                  #The NuGet configuration file to use
    --source: string                                    #Replace all NuGet sources with this one
    --add-source: string                                #Add an additional NuGet source
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
]

# Install or work with workloads
export extern "dotnet workload" [
    subcommand?: string@"nu-complete dotnet workload subcommands" #Workload subcommand
    --info                                              #Display information about installed workloads
    --version                                           #Display the currently installed workload version
]

# Install one or more workloads
export extern "dotnet workload install" [
    ...workload_id: string                              #The workload IDs to install
    --skip-manifest-update                              #Skip updating the workload manifests
    --temp-dir: path                                    #The temporary directory for downloads
    --configfile: path                                  #The NuGet configuration file to use
    --source(-s): string                                #The NuGet package source to use during the restore
    --include-previews                                  #Include preview workloads
    --version: string                                   #A workload version to install
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Update all installed workloads
export extern "dotnet workload update" [
    --temp-dir: path                                    #The temporary directory for downloads
    --configfile: path                                  #The NuGet configuration file to use
    --source(-s): string                                #The NuGet package source to use during the restore
    --include-previews                                  #Include preview workloads
    --version: string                                   #A workload version to install
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --from-previous-sdk                                 #Include workloads installed with earlier SDK versions
    --advertising-manifests-only                        #Only update advertising manifests
    --from-history: string                              #Update workloads to a previous version from history
    --manifests-only: string                            #Update to the workload versions specified
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# List available workloads
export extern "dotnet workload list" []

# Search for available workloads
export extern "dotnet workload search" [
    search_string?: string                              #The workload search string
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Uninstall one or more workloads
export extern "dotnet workload uninstall" [
    ...workload_id: string                              #The workload IDs to uninstall
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Repair workload installations
export extern "dotnet workload repair" [
    --configfile: path                                  #The NuGet configuration file to use
    --source(-s): string                                #The NuGet package source to use during the restore
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Restore workloads required for a project
export extern "dotnet workload restore" [
    ...project: path                                    #The project or solution file to operate on
    --temp-dir: path                                    #Temporary directory for downloads and extraction
    --configfile: path                                  #The NuGet configuration file to use
    --source(-s): string                                #The NuGet package source to use during the restore
    --include-previews                                  #Allow prerelease workload manifests
    --version: string                                   #A workload version to restore
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --ignore-failed-sources                             #Treat package source failures as warnings
    --no-http-cache                                     #Do not cache packages and HTTP requests
    --interactive                                       #Allow the command to stop and wait for user input
    --skip-manifest-update                              #Skip updating the workload manifests
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Remove workload components left behind from previous updates and uninstalls
export extern "dotnet workload clean" [
    --all                                               #Remove and uninstall all workload components from all SDK versions
]

# Modify or display workload configuration values
export extern "dotnet workload config" [
    --update-mode: string                               #Update mode: manifests | workload-set
]

# Show a history of workload installation actions
export extern "dotnet workload history" []

# Interact with servers started by a build
export extern "dotnet build-server" [
    subcommand?: string@"nu-complete dotnet build-server subcommands" #Build-server subcommand
]

# Shut down build servers
export extern "dotnet build-server shutdown" [
    --msbuild                                           #Shut down the MSBuild build server
    --vbcscompiler                                      #Shut down the VB/C# compiler build server
    --razor                                             #Shut down the Razor build server
]

# Run Microsoft Build Engine (MSBuild) commands
export extern "dotnet msbuild" [
    ...args: string                                     #Arguments passed to MSBuild
]

# Store the specified assemblies in the runtime package store
export extern "dotnet store" [
    --manifest(-m): path                                #The manifest file (XML listing packages to store)
    --framework(-f): string                             #The target framework
    --framework-version: string                         #The Microsoft.NETCore.App package version
    --runtime(-r): string                               #The target runtime
    --output(-o): path                                  #The output directory
    --skip-optimization                                 #Skip the optimization step
    --skip-symbols                                      #Skip symbol generation
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --working-dir(-w): path                             #The working directory
    --use-current-runtime                               #Use current runtime as the target runtime
    --no-logo                                           #Do not display the startup banner
    --disable-build-servers                             #Force the command to ignore any persistent build servers
]

# Run Microsoft Test Engine (VSTest) commands
export extern "dotnet vstest" [
    ...args: string                                     #Arguments passed to VSTest
]

# Create and manage development certificates
export extern "dotnet dev-certs" [
    ...args: string                                     #Arguments for certificate management
]

# Start F# Interactive / execute F# scripts
export extern "dotnet fsi" [
    ...args: string                                     #Arguments passed to F# Interactive
]

# Manage JSON Web Tokens in development
export extern "dotnet user-jwts" [
    ...args: string                                     #Arguments for JWT management
]

# Manage development user secrets
export extern "dotnet user-secrets" [
    ...args: string                                     #Arguments for user secrets management
]

# Manage .NET SDK installation
export extern "dotnet sdk" [
    subcommand?: string@"nu-complete dotnet sdk subcommands" #SDK subcommand
]

# Check the .NET SDKs and runtimes installed on the machine for updates
export extern "dotnet sdk check" []

# Opens the reference page in a browser for the specified command
export extern "dotnet help" [
    command?: string                                    #The command to get help for
]

# Convert file-based programs to a project-based program
export extern "dotnet project" [
    subcommand?: string@"nu-complete dotnet project subcommands" #Project subcommand
]

# Convert a file-based program to a project-based program
export extern "dotnet project convert" [
    file: path                                          #Path to the file-based program
    --output(-o): path                                  #Location to place the generated output
    --force                                             #Force conversion even if there are malformed directives
    --interactive                                       #Allow the command to stop and wait for user input
    --dry-run                                           #Determine changes without modifying the file system
    --delete-source                                     #Delete all source files after conversion
]

# Commands for generating and registering completions for supported shells
export extern "dotnet completions" [
    subcommand?: string@"nu-complete dotnet completions subcommands" #Completions subcommand
]

# Generate the completion script for a supported shell
export extern "dotnet completions script" [
    shell?: string                                      #bash, fish, nushell, pwsh or zsh
]
