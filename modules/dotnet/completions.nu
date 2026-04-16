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

# .NET CLI
export extern "dotnet" [
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
]

# Build and run a .NET project
export extern "dotnet run" [
    ...args: string                                     #Arguments passed to the application
    --configuration(-c): string                         #The configuration to run for (default: Debug)
    --framework(-f): string                             #The target framework to run for
    --project: path                                     #Path of the project file to run
    --file: path                                        #The path to the file-based app to run
    --launch-profile: string                            #The name of the launch profile to use
    --no-launch-profile                                 #Do not attempt to use launchSettings.json
    --no-build                                          #Do not build the project before running
    --no-restore                                        #Do not restore the project before building
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
]

# Run unit tests using the test runner
export extern "dotnet test" [
    project?: path                                      #The project or solution file to test
    --settings(-s): path                                #The settings file to use when running tests
    --list-tests(-t)                                    #List the discovered tests instead of running them
    --environment(-e): string                           #Set an environment variable (NAME="VALUE")
    --filter: string                                    #Run tests that match the given expression
    --configuration(-c): string                         #The configuration to use for running tests
    --framework(-f): string                             #The target framework to run tests for
    --runtime(-r): string                               #The target runtime to test for
    --output(-o): path                                  #The output directory to place built artifacts in
    --no-build                                          #Do not build the project before testing
    --no-restore                                        #Do not restore the project before building
    --collect: string                                   #Enable data collector for the test run
    --blame                                             #Run tests in blame mode
    --logger(-l): string                                #The logger to use for test results
    --results-directory: path                           #The directory where the test results will be placed
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --interactive                                       #Allow the command to stop and wait for user input
    --no-logo                                           #Do not display the startup banner or copyright message
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
    --disable-parallel                                  #Prevent restoring multiple projects in parallel
    --configfile: path                                  #The NuGet configuration file to use
    --no-http-cache                                     #Disable HTTP caching for packages
    --ignore-failed-sources                             #Treat package source failures as warnings
    --force(-f)                                         #Force all dependencies to be resolved
    --no-dependencies                                   #Do not restore project-to-project references
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --disable-build-servers                             #Force the command to ignore any persistent build servers
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
    --version-suffix: string                            #Set the value of the $(VersionSuffix) property
    --interactive                                       #Allow the command to stop and wait for user input
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
    --no-logo                                           #Do not display the startup banner or copyright message
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
    --force                                             #Allow reinstalling an existing template package
]

# Uninstall a template package
export extern "dotnet new uninstall" [
    package: string                                     #The template package to uninstall
]

# List available templates
export extern "dotnet new list" [
    template_name?: string                              #Filter by template name
    --language: string                                  #Filter by template language
    --type: string                                      #Filter by template type
    --tag: string                                       #Filter by template tag
    --columns-all                                       #Display all columns in the output
]

# Search for templates on NuGet.org
export extern "dotnet new search" [
    template_name: string                               #The template name to search for
    --language: string                                  #Filter by template language
    --type: string                                      #Filter by template type
    --tag: string                                       #Filter by template tag
    --columns-all                                       #Display all columns in the output
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
    --no-hot-reload                                     #Suppress hot reload for supported apps
    --non-interactive                                   #Runs dotnet-watch in non-interactive mode
    --verbose(-v)                                       #Show verbose output
    --quiet(-q)                                         #Suppress all output except warnings and errors
]

# Modify Visual Studio solution files
export extern "dotnet solution" [
    sln_file?: path                                     #The solution file to operate on
]

# Add one or more projects to a solution file
export extern "dotnet solution add" [
    ...project_path: path                               #The project files to add
    --in-root                                           #Place the project in the root of the solution
    --solution-folder(-s): string                       #The destination solution folder path
]

# List all projects in a solution file
export extern "dotnet solution list" []

# Remove one or more projects from a solution file
export extern "dotnet solution remove" [
    ...project_path: path                               #The project files to remove
]

# Search for, add, remove, or list package references
export extern "dotnet package" []

# Search for NuGet packages
export extern "dotnet package search" [
    search_term: string                                 #The search term to search for
    --source: string                                    #The NuGet package source to search
    --exact-match                                       #Require an exact match
    --take: int                                         #Number of results to return
    --skip: int                                         #Number of results to skip
    --prerelease                                        #Include prerelease packages
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
]

# List all package references of the project or solution
export extern "dotnet package list" [
    --outdated                                          #List packages that have newer versions available
    --deprecated                                        #List packages that have been deprecated
    --vulnerable                                        #List packages that have known vulnerabilities
    --include-transitive                                #Include transitive packages
    --include-prerelease                                #Consider prerelease packages when looking for updates
    --source(-s): string                                #The NuGet source to use when looking for updates
    --config: path                                      #The NuGet configuration file to use
    --framework: string                                 #Show packages only for the specified framework
    --format: string                                    #The output format (console or json)
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the MSBuild verbosity level
]

# Remove a NuGet package reference from the project
export extern "dotnet package remove" [
    package_name: string                                #The NuGet package to remove
    --interactive                                       #Allow the command to stop and wait for user input
]

# Add, remove, or list project-to-project references
export extern "dotnet reference" [
    --project: path                                     #The project file to operate on
]

# Add a project-to-project reference
export extern "dotnet reference add" [
    ...project_path: path                               #The project references to add
    --framework(-f): string                             #Add the reference only for a specific framework
    --interactive                                       #Allow the command to stop and wait for user input
]

# List all project-to-project references
export extern "dotnet reference list" []

# Remove a project-to-project reference
export extern "dotnet reference remove" [
    ...project_path: path                               #The project references to remove
    --framework(-f): string                             #Remove the reference only for a specific framework
]

# Provides additional NuGet commands
export extern "dotnet nuget" []

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

# Install or manage tools that extend the .NET experience
export extern "dotnet tool" []

# Install a global or local tool
export extern "dotnet tool install" [
    package_id: string                                  #The NuGet package ID of the tool to install
    --global(-g)                                        #Install the tool globally
    --local                                             #Install the tool locally
    --tool-path: path                                   #The directory where the tool will be installed
    --version: string                                   #The version of the tool to install
    --configfile: path                                  #The NuGet configuration file to use
    --tool-manifest: path                               #Path to the manifest file
    --framework: string                                 #The target framework to install the tool for
    --prerelease                                        #Include prerelease packages
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
    package_id: string                                  #The NuGet package ID of the tool to update
    --global(-g)                                        #Update a globally installed tool
    --local                                             #Update a locally installed tool
    --tool-path: path                                   #The directory containing the tool to update
    --version: string                                   #The version to update to
    --configfile: path                                  #The NuGet configuration file to use
    --tool-manifest: path                               #Path to the manifest file
    --framework: string                                 #The target framework to update the tool for
    --prerelease                                        #Include prerelease packages
]

# List installed tools
export extern "dotnet tool list" [
    package_id?: string                                 #The NuGet package ID of the tool
    --global(-g)                                        #List globally installed tools
    --local                                             #List locally installed tools
    --tool-path: path                                   #The directory containing the tools to list
    --tool-manifest: path                               #Path to the manifest file
]

# Run a local tool
export extern "dotnet tool run" [
    command_name: string@"nu-complete dotnet tool list" #The command name of the tool to run
    ...args: string                                     #Arguments to pass to the tool
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
]

# Install or work with workloads
export extern "dotnet workload" [
    --info                                              #Display information about installed workloads
    --version                                           #Display the currently installed workload version
]

# Install one or more workloads
export extern "dotnet workload install" [
    ...workload_id: string                              #The workload IDs to install
    --skip-manifest-update                              #Skip updating the workload manifests
    --temp-dir: path                                    #The temporary directory for downloads
    --include-previews                                  #Include preview workloads
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Update all installed workloads
export extern "dotnet workload update" [
    --temp-dir: path                                    #The temporary directory for downloads
    --include-previews                                  #Include preview workloads
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
]

# Repair workload installations
export extern "dotnet workload repair" [
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
]

# Interact with servers started by a build
export extern "dotnet build-server" []

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
    --manifest(-m): path                                #The manifest file
    --framework(-f): string                             #The target framework
    --runtime(-r): string                               #The target runtime
    --output(-o): path                                  #The output directory
    --skip-optimization                                 #Skip the optimization step
    --skip-symbols                                      #Skip symbol generation
    --verbosity(-v): string@"nu-complete dotnet verbosity" #Set the verbosity level
    --working-dir(-w): path                             #The working directory
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
    ...args: string                                     #Arguments for SDK management
]

# Opens the reference page in a browser for the specified command
export extern "dotnet help" [
    command?: string                                    #The command to get help for
]
