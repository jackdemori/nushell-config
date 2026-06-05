def "nu-complete docker containers" [] {
    ^docker ps -a --format "{{.ID}} {{.Names}}" | lines
        | parse "{value} {description}"
}

def "nu-complete docker images" [] {
    ^docker images --format "{{.ID}} {{.Repository}}" | lines
        | parse "{value} {description}"
}

def "nu-complete docker run" [] {
    (nu-complete docker images)
    | append (nu-complete docker containers)
}

def "nu-complete docker pull" [] {
    [always, missing, never]
}

def "nu-complete docker remove image" [] {
    [local, all]
}

def "nu-complete local files" [] {
    ^ls | lines
}

def "nu-complete docker compose ps" [] {
    ^docker compose ps -a --format "{{.ID}} {{.Names}}" | lines
        | parse "{value} {description}"
}

def "nu-complete docker compose service status" [] {
    [paused restarting removing running dead created exited]
}

# Static subcommand completers — prevent nu from falling back to filesystem
# completion on parent externs (`docker `, `docker compose `, `docker container `,
# `docker image `, `docker system `).

def "nu-complete docker subcommands" [] {
    [
        {value: "run",         description: "Create and run a new container from an image"}
        {value: "exec",        description: "Execute a command in a running container"}
        {value: "ps",          description: "List containers"}
        {value: "build",       description: "Build an image from a Dockerfile"}
        {value: "pull",        description: "Download an image from a registry"}
        {value: "push",        description: "Upload an image to a registry"}
        {value: "images",      description: "List images"}
        {value: "login",       description: "Authenticate to a registry"}
        {value: "logout",      description: "Log out from a registry"}
        {value: "search",      description: "Search Docker Hub for images"}
        {value: "version",     description: "Show the Docker version information"}
        {value: "info",        description: "Display system-wide information"}
        {value: "builder",     description: "Manage builds"}
        {value: "buildx",      description: "Extended build capabilities with BuildKit"}
        {value: "checkpoint",  description: "Manage checkpoints"}
        {value: "compose",     description: "Define and run multi-container apps"}
        {value: "container",   description: "Manage containers"}
        {value: "context",     description: "Manage contexts"}
        {value: "image",       description: "Manage images"}
        {value: "manifest",    description: "Manage Docker image manifests and lists"}
        {value: "network",     description: "Manage networks"}
        {value: "plugin",      description: "Manage plugins"}
        {value: "system",      description: "Manage Docker"}
        {value: "volume",      description: "Manage volumes"}
        {value: "config",      description: "Manage Swarm configs"}
        {value: "node",        description: "Manage Swarm nodes"}
        {value: "secret",      description: "Manage Swarm secrets"}
        {value: "service",     description: "Manage Swarm services"}
        {value: "stack",       description: "Manage Swarm stacks"}
        {value: "swarm",       description: "Manage Swarm"}
        {value: "stop",        description: "Stop one or more running containers"}
        {value: "start",       description: "Start one or more stopped containers"}
        {value: "restart",     description: "Restart one or more containers"}
        {value: "kill",        description: "Kill one or more running containers"}
        {value: "rm",          description: "Remove one or more containers"}
        {value: "rmi",         description: "Remove one or more images"}
        {value: "logs",        description: "Fetch the logs of a container"}
        {value: "inspect",     description: "Return low-level information on Docker objects"}
        {value: "cp",          description: "Copy files/folders between a container and the local filesystem"}
        {value: "tag",         description: "Create a tag that refers to a source image"}
        {value: "history",     description: "Show the history of an image"}
        {value: "save",        description: "Save one or more images to a tar archive"}
        {value: "load",        description: "Load an image from a tar archive or STDIN"}
        {value: "import",      description: "Import the contents from a tarball as a filesystem image"}
        {value: "export",      description: "Export a container's filesystem as a tar archive"}
        {value: "diff",        description: "Inspect changes to files or directories on a container's filesystem"}
        {value: "create",      description: "Create a new container"}
        {value: "commit",      description: "Create a new image from a container's changes"}
        {value: "attach",      description: "Attach local I/O streams to a running container"}
        {value: "wait",        description: "Block until containers stop, then print their exit codes"}
        {value: "top",         description: "Display the running processes of a container"}
        {value: "stats",       description: "Display a live stream of container(s) resource usage"}
        {value: "port",        description: "List port mappings for the container"}
        {value: "rename",      description: "Rename a container"}
        {value: "pause",       description: "Pause all processes within one or more containers"}
        {value: "unpause",     description: "Unpause all processes within one or more containers"}
        {value: "update",      description: "Update configuration of one or more containers"}
        {value: "events",      description: "Get real time events from the server"}
    ]
}

def "nu-complete docker compose subcommands" [] {
    [
        {value: "up",        description: "Create and start containers"}
        {value: "down",      description: "Stop and remove containers, networks"}
        {value: "ps",        description: "List containers"}
        {value: "ls",        description: "List running compose projects"}
        {value: "logs",      description: "View output from containers"}
        {value: "build",     description: "Build or rebuild services"}
        {value: "create",    description: "Create containers for a service"}
        {value: "start",     description: "Start services"}
        {value: "stop",      description: "Stop services"}
        {value: "restart",   description: "Restart service containers"}
        {value: "kill",      description: "Force stop service containers"}
        {value: "rm",        description: "Remove stopped service containers"}
        {value: "pause",     description: "Pause services"}
        {value: "unpause",   description: "Unpause services"}
        {value: "exec",      description: "Execute a command in a running container"}
        {value: "run",       description: "Run a one-off command on a service"}
        {value: "attach",    description: "Attach to a service's running container"}
        {value: "pull",      description: "Pull service images"}
        {value: "push",      description: "Push service images"}
        {value: "config",    description: "Parse, resolve and render the compose file"}
        {value: "events",    description: "Receive real time events from containers"}
        {value: "images",    description: "List images used by the created containers"}
        {value: "port",      description: "Print the public port for a port binding"}
        {value: "scale",     description: "Scale services"}
        {value: "stats",     description: "Display a live stream of resource usage stats"}
        {value: "top",       description: "Display the running processes"}
        {value: "wait",      description: "Block until containers of all services stop"}
        {value: "watch",     description: "Watch for file changes and rebuild/refresh containers"}
        {value: "version",   description: "Show the Docker Compose version information"}
        {value: "publish",   description: "Publish compose application"}
        {value: "commit",    description: "Create a new image from a service container's changes"}
        {value: "cp",        description: "Copy files between a service container and the local filesystem"}
        {value: "export",    description: "Export a service container's filesystem as a tar archive"}
        {value: "volumes",   description: "List volumes"}
        {value: "bridge",    description: "Convert compose files into another model"}
    ]
}

def "nu-complete docker container subcommands" [] {
    [
        {value: "attach",   description: "Attach local I/O streams to a running container"}
        {value: "commit",   description: "Create a new image from a container's changes"}
        {value: "cp",       description: "Copy files between a container and the local filesystem"}
        {value: "create",   description: "Create a new container"}
        {value: "diff",     description: "Inspect changes to files on a container's filesystem"}
        {value: "exec",     description: "Execute a command in a running container"}
        {value: "export",   description: "Export a container's filesystem as a tar archive"}
        {value: "inspect",  description: "Display detailed information on one or more containers"}
        {value: "kill",     description: "Kill one or more running containers"}
        {value: "logs",     description: "Fetch the logs of a container"}
        {value: "ls",       description: "List containers"}
        {value: "pause",    description: "Pause all processes within one or more containers"}
        {value: "port",     description: "List port mappings for the container"}
        {value: "prune",    description: "Remove all stopped containers"}
        {value: "rename",   description: "Rename a container"}
        {value: "restart",  description: "Restart one or more containers"}
        {value: "rm",       description: "Remove one or more containers"}
        {value: "run",      description: "Create and run a new container from an image"}
        {value: "start",    description: "Start one or more stopped containers"}
        {value: "stats",    description: "Display a live stream of resource usage stats"}
        {value: "stop",     description: "Stop one or more running containers"}
        {value: "top",      description: "Display the running processes of a container"}
        {value: "unpause",  description: "Unpause all processes within one or more containers"}
        {value: "update",   description: "Update configuration of one or more containers"}
        {value: "wait",     description: "Block until containers stop, then print exit codes"}
    ]
}

def "nu-complete docker image subcommands" [] {
    [
        {value: "build",    description: "Build an image from a Dockerfile"}
        {value: "history",  description: "Show the history of an image"}
        {value: "import",   description: "Import the contents from a tarball as a filesystem image"}
        {value: "inspect",  description: "Display detailed information on one or more images"}
        {value: "load",     description: "Load an image from a tar archive or STDIN"}
        {value: "ls",       description: "List images"}
        {value: "prune",    description: "Remove unused images"}
        {value: "pull",     description: "Download an image from a registry"}
        {value: "push",     description: "Upload an image to a registry"}
        {value: "rm",       description: "Remove one or more images"}
        {value: "save",     description: "Save one or more images to a tar archive"}
        {value: "tag",      description: "Create a tag that refers to a source image"}
    ]
}

def "nu-complete docker system subcommands" [] {
    [
        {value: "df",      description: "Show Docker disk usage"}
        {value: "events",  description: "Get real time events from the server"}
        {value: "info",    description: "Display system-wide information"}
        {value: "prune",   description: "Remove unused data"}
        {value: "dial-stdio", description: "Proxy the stdio stream to the daemon connection"}
    ]
}

# Log in to a Docker registry
export extern "docker login" [
    server?: string                                     #Docker registry URL
    --password(-p): string                              #Password
    --password-stdin                                    #Take the password from stdin
    --username(-u): string                              #Username
]

# Log out from a Docker registry
export extern "docker logout" [
    server?: string                                     #Docker registry URL
]

# Search Docker Hub for images
export extern "docker search" [
    term?: string
    --filter(-f): string                                #Filter output based on conditions provided
    --format: string                                    #Pretty-print search using a Go template
    --limit: int                                        #Max number of search results
    --no-trunc                                          #Don't truncate output
]

# Show the docker  version information
export extern "docker version" [
    --format(-f): string                                #Format the output using the given Go template
    --kubeconfig: string                                #Kubernetes config file
]

# Manage Docker
export extern "docker system" [
    subcommand?: string@"nu-complete docker system subcommands" #System subcommand
]

# Get real time events from the server
export extern "docker system events" [
    --filter(-f): string                                #Filter output based on conditions provided
    --format: string                                    #Pretty-print images using a Go template
    --since: string                                     #Show all events created since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
    --until: string                                     #Stream events until this timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
]

# Show Docker disk usage
export extern "docker system df" [
    --format: string                                    #Format output using a custom template
    --verbose(-v)                                       #Show detailed information on space usage
]

# Display system-wide information
export extern "docker system info" [
    --format(-f): string                                #Format output using a custom template
]

# Remove unused data
export extern "docker system prune" [
    --all(-a)                                           #Remove all unused images not just dangling ones
    --filter: string                                    #Provide filter values (e.g. "label=<key>=<value>")
    --force(-f)                                         #Do not prompt for confirmation
    --volumes                                           #Prune anonymous volumes
]

# Manage containers
export extern "docker container" [
    subcommand?: string@"nu-complete docker container subcommands" #Container subcommand
]

# Manage images
export extern "docker image" [
    subcommand?: string@"nu-complete docker image subcommands" #Image subcommand
]

# Define and run multi-container Docker applications
export extern "docker compose" [
    subcommand?: string@"nu-complete docker compose subcommands" #Compose subcommand
    --file(-f): path                                    #Compose configuration files
    --project-name(-p): string                          #Project name
    --profile: string                                   #Specify a profile to enable
    --env-file: path                                    #Specify an alternate environment file
    --project-directory: path                           #Specify an alternate working directory
    --parallel: int                                     #Control max parallelism, -1 for unlimited
    --progress: string                                  #Set type of progress output (auto, tty, plain, json, quiet)
    --ansi: string                                      #Control when to print ANSI control characters (never, always, auto)
    --all-resources                                     #Include all resources, even those not used by services
    --compatibility                                     #Run compose in backward compatibility mode
    --dry-run                                           #Execute command in dry-run mode
    --verbose                                           #Show more output
    --no-ansi                                           #Do not print ANSI control characters (DEPRECATED)
]

# Attach local standard input, output, and error streams to a running container
export extern "docker container attach" [
    container?: string@"nu-complete docker containers"
    --detach-keys:string                                #Override the key sequence for detaching a container
    --no-stdin                                          #Do not attach STDIN
    --sig-proxy                                         #Proxy all received signals to the process
]

# Create a new image from a container's changes
export extern "docker container commit" [
    container?: string@"nu-complete docker containers"
    --author(-a): string                                #Author (e.g., "John Hannibal Smith <hannibal@a-team.com>"
    --change(-c): string                                #Apply Dockerfile instruction to the created image
    --message(-m): string                               #Commit message
    --pause(-p)                                         #Pause container during commit (default true)
    --no-pause                                          #Disable pausing container during commit
]

# Copy files/folders between a container and the local filesystem
export extern "docker container cp" [
    src?: string                                        #Source path (e.g. container:path or local path)
    dest?: string                                       #Destination path (e.g. container:path or local path)
    --archive(-a)                                       #Archive mode (copy all uid/gid information)
    --follow-link(-L)                                   #Always follow symbol link in SRC_PATH
    --quiet(-q)                                         #Suppress progress output during copy
]

# Create a new container
export extern "docker container create" [
    image?: string@"nu-complete docker images"          #The image to create the container from
    command?: string                                     #Command to run inside the container
    ...args: string
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --annotation: string                                #Add an annotation to the container (passed through to the OCI runtime) (default map[])
    --attach: string                                    #Attach to STDIN, STDOUT or STDERR
    --blkio-weight: int                                 #Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
    --blkio-weight-device: string                       #Block IO weight (relative device weight) (default [])
    --cap-add: string                                   #Add Linux capabilities
    --cap-drop: string                                  #Drop Linux capabilities
    --cgroup-parent: string                             #Optional parent cgroup for the container
    --cgroupns: string                                  #Cgroup namespace to use (host|private)
    --cidfile: string                                   #Write the container ID to the file
    --cpu-period: int                                   #Limit CPU CFS (Completely Fair Scheduler) period
    --cpu-quota: int                                    #Limit CPU CFS (Completely Fair Scheduler) quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpu-count: int                                    #CPU count (Windows only)
    --cpu-percent: int                                  #CPU percent (Windows only)
    --cpus: int                                         #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution (0-3, 0,1)
    --cpuset-mems: string                               #MEMs in which to allow execution (0-3, 0,1)
    --detach(-d)                                        #Run container in background and print container ID
    --detach-keys: string                               #Override the key sequence for detaching a container
    --device: string                                    #Add a host device to the container
    --device-cgroup-rule: string                        #Add a rule to the cgroup allowed devices list
    --device-read-bps: int                              #Limit read rate (bytes per second) from a device (default [])
    --device-read-iops: int                             #Limit read rate (IO per second) from a device (default [])
    --device-write-bps: int                             #Limit write rate (bytes per second) to a device (default [])
    --device-write-iops: int                            #Limit write rate (IO per second) to a device (default [])
    --disable-content-trust                             #Skip image verification (default true)
    --dns: int                                          #Set custom DNS servers
    --dns-option: string                                #Set DNS options
    --dns-search: string                                #Set custom DNS search domains
    --domainname: string                                #Container NIS domain name
    --entrypoint: string                                #Overwrite the default ENTRYPOINT of the image
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --expose: string                                    #Expose a port or a range of ports
    --gpus: string                                      #GPU devices to add to the container ('all' to pass all GPUs)
    --group-add: string                                 #Add additional groups to join
    --health-cmd: string                                #Command to run to check health
    --health-interval: duration                         #Time between running the check (ms|s|m|h) (default 0s)
    --health-retries: int                               #Consecutive failures needed to report unhealthy
    --health-start-interval: duration                   #Time between running the check during the start period (ms|s|m|h) (default 0s)
    --health-start-period: duration                     #Start period for the container to initialize before starting health-retries countdown (ms|s|m|h) (default 0s)
    --health-timeout: duration                          #Maximum time to allow one check to run (ms|s|m|h) (default 0s)
    --help                                              #Print usage
    --hostname(-h): string                              #Container host name
    --init                                              #Run an init inside the container that forwards signals and reaps processes
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --io-maxbandwidth: int                              #Maximum IO bandwidth limit for the system drive (Windows only)
    --io-maxiops: int                                   #Maximum IOps limit for the system drive (Windows only)
    --ip: string                                        #IPv4 address (e.g., 172.30.100.104)
    --ip6: string                                       #IPv6 address (e.g., 2001:db8::33)
    --ipc: string                                       #IPC mode to use
    --isolation: string                                 #Container isolation technology
    --kernel-memory: int                                #Kernel memory limit
    --label(-l): string                                 #Set meta data on a container
    --label-file: string                                #Read in a line delimited file of labels
    --link: string                                      #Add link to another container
    --link-local-ip: string                             #Container IPv4/IPv6 link-local addresses
    --log-driver: string                                #Logging driver for the container
    --log-opt: string                                   #Log driver options
    --mac-address: string                               #Container MAC address (e.g., 92:d0:c6:0a:29:33)
    --memory(-m): int                                   #Memory limit
    --memory-reservation: int                           #Memory soft limit
    --memory-swap: int                                  #Swap limit equal to memory plus swap: '-1' to enable unlimited swap
    --memory-swappiness: int                            #Tune container memory swappiness (0 to 100) (default -1)
    --mount: string                                     #Attach a filesystem mount to the container
    --name: string                                      #Assign a name to the container
    --network: string                                   #Connect a container to a network
    --network-alias: string                             #Add network-scoped alias for the container
    --no-healthcheck                                    #Disable any container-specified HEALTHCHECK
    --oom-kill-disable                                  #Disable OOM Killer
    --oom-score-adj: int                                #Tune host's OOM preferences (-1000 to 1000)
    --pid: string                                       #PID namespace to use
    --pids-limit: int                                   #Tune container pids limit (set -1 for unlimited)
    --platform: string                                  #Set platform if server is multi-platform capable
    --privileged                                        #Give extended privileges to this container
    --publish(-p): string                               #Publish a container's port(s) to the host
    --publish-all(-P)                                   #Publish all exposed ports to random ports
    --pull: string@"nu-complete docker pull"            #Pull image before running ("always", "missing", "never") (default "missing")
    --quiet(-q)                                         #Suppress the pull output
    --read-only                                         #Mount the container's root filesystem as read only
    --restart: string                                   #Restart policy to apply when a container #exits (default "no")
    --rm                                                #Automatically remove the container when it exits
    --runtime: string                                   #Runtime to use for this container
    --security-opt: string                              #Security Options
    --shm-size: int                                     #Size of /dev/shm
    --sig-proxy                                         #Proxy received signals to the process (default true)
    --stop-signal: string                               #Signal to stop the container
    --stop-timeout: int                                 #Timeout (in seconds) to stop a container
    --storage-opt: string                               #Storage driver options for the container
    --sysctl: string                                    #Sysctl options (default map[])
    --tmpfs: string                                     #Mount a tmpfs directory
    --tty(-t)                                           #Allocate a pseudo-TTY
    --ulimit: int                                       #Ulimit options (default [])
    --use-api-socket                                    #Bind mount Docker API socket and required auth
    --user(-u): string                                  #Username or UID (format: <name|uid>[:<group|gid>])
    --userns: string                                    #User namespace to use
    --uts: string                                       #UTS namespace to use
    --volume(-v): string                                #Bind mount a volume
    --volume-driver: string                             #Optional volume driver for the container
    --volumes-from: string                              #Mount volumes from the specified container(s)
    --workdir(-w): string                               #Working directory inside the container
]

# Inspect changes to files or directories on a container's filesystem
export extern "docker container diff" [
    container?: string@"nu-complete docker containers"
]

# Run a command in a running container
export extern "docker container exec" [
    container?: string@"nu-complete docker containers"
    --detach(-d)                                        #Detached mode: run command in the background
    --detach-keys: string                               #Override the key sequence for detaching a container
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --privileged                                        #Give extended privileges to the command
    --tty(-t)                                           #Allocate a pseudo-TTY
    --user(-u): string                                  #Username or UID (format: <name|uid>[:<group|gid>])
    --workdir(-w): string                               #Working directory inside the container
]

# Export a container's filesystem as a tar archive
export extern "docker container export" [
    container?: string@"nu-complete docker containers"
    --output(-o): string                                #Write to a file, instead of STDOUT
]

# Display detailed information on one or more containers
export extern "docker container inspect" [
    container?: string@"nu-complete docker containers"
    --format(-f):string                                 #Format the output using the given Go template
    --size(-s)                                          #Display total file sizes
    --type:string                                       #Return JSON for specified type
]

# Kill one or more running containers
export extern "docker container kill" [
    container?: string@"nu-complete docker containers"
    --signal(-s):string                                 #Signal to send to the container
]

# Fetch the logs of a container
export extern "docker container logs" [
    container?: string@"nu-complete docker containers"
    --details                                           #Show extra details provided to logs
    --follow(-f)                                        #Follow log output
    --since: string                                     #Show logs since timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
    --tail(-n): string                                  #Number of lines to show from the end of the logs
    --timestamps(-t)                                    #Show timestamps
    --until: string                                     #Show logs before a timestamp (e.g. 2013-01-02T13:23:37) or relative (e.g. 42m for 42 minutes)
]

# List containers
export extern "docker container ls" [
    --all(-a)                                           #Show all containers (default shows just running)
    --filter: string                                    #Filter output based on conditions provided
    --format: string                                    #Pretty-print containers using a Go template
    --last(-n): int                                     #Show n last created containers (includes all states) (default -1)
    --latest(-l)                                        #Show the latest created container (includes all states)
    --no-trunc                                          #Don't truncate output
    --quiet(-q)                                         #Only display numeric IDs
    --size(-s)                                          #Display total file sizes
]

# Pause all processes within one or more containers
export extern "docker container pause" [
    container?: string@"nu-complete docker containers"
]

# Remove all stopped containers
export extern "docker container prune" [
    --filter: string                                    #Provide filter values (e.g. 'until=24h')
    --force(-f)                                         #Do not prompt for confirmation
]

# List port mappings or a specific mapping for the container
export extern "docker container port" [
    container?: string@"nu-complete docker containers"
]

# Rename a container
export extern "docker container rename" [
    container?: string@"nu-complete docker containers"
    name?: string
]

# Restart one or more containers
export extern "docker container restart" [
    container?: string@"nu-complete docker containers"
    --time(-t): int                                     #Seconds to wait for stop before killing the container
    --signal(-s): string                                #Signal to stop the container
]

# Remove one or more containers
export extern "docker container rm" [
    container?: string@"nu-complete docker containers"
    --force(-f)                                         #Force the removal of a running container (uses SIGKILL)
    --link(-l)                                          #Remove the specified link
    --volumes(-v)                                       #Remove anonymous volumes associated with the container
]

# Run a command in a new container
export extern "docker container run" [
    image?: string@"nu-complete docker run"             #The image to create the container from
    command?: string                                    #Command to run inside the container
    ...args: string
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --annotation: string                                #Add an annotation to the container (passed through to the OCI runtime) (default map[])
    --attach: string                                    #Attach to STDIN, STDOUT or STDERR
    --blkio-weight: int                                 #Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
    --blkio-weight-device: string                       #Block IO weight (relative device weight) (default [])
    --cap-add: string                                   #Add Linux capabilities
    --cap-drop: string                                  #Drop Linux capabilities
    --cgroup-parent: string                             #Optional parent cgroup for the container
    --cgroupns: string                                  #Cgroup namespace to use (host|private)
    --cidfile: string                                   #Write the container ID to the file
    --cpu-period: int                                   #Limit CPU CFS (Completely Fair Scheduler) period
    --cpu-quota: int                                    #Limit CPU CFS (Completely Fair Scheduler) quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpu-count: int                                    #CPU count (Windows only)
    --cpu-percent: int                                  #CPU percent (Windows only)
    --cpus: int                                         #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution (0-3, 0,1)
    --cpuset-mems: string                               #MEMs in which to allow execution (0-3, 0,1)
    --detach(-d)                                        #Run container in background and print container ID
    --detach-keys: string                               #Override the key sequence for detaching a container
    --device: string                                    #Add a host device to the container
    --device-cgroup-rule: string                        #Add a rule to the cgroup allowed devices int
    --device-read-bps: int                              #Limit read rate (bytes per second) from a device (default [])
    --device-read-iops: int                             #Limit read rate (IO per second) from a device (default [])
    --device-write-bps: int                             #Limit write rate (bytes per second) to a device (default [])
    --device-write-iops: int                            #Limit write rate (IO per second) to a device (default [])
    --disable-content-trust                             #Skip image verification (default true)
    --dns: int                                          #Set custom DNS servers
    --dns-option: string                                #Set DNS options
    --dns-search: string                                #Set custom DNS search domains
    --domainname: string                                #Container NIS domain name
    --entrypoint: string                                #Overwrite the default ENTRYPOINT of the image
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --expose: string                                    #Expose a port or a range of ports
    --gpus: string                                      #GPU devices to add to the container ('all' to pass all GPUs)
    --group-add: string                                 #Add additional groups to join
    --health-cmd: string                                #Command to run to check health
    --health-interval: duration                         #Time between running the check (ms|s|m|h) (default 0s)
    --health-retries: int                               #Consecutive failures needed to report unhealthy
    --health-start-interval: duration                   #Time between running the check during the start period (ms|s|m|h) (default 0s)
    --health-start-period: duration                     #Start period for the container to initialize before starting health-retries countdown (ms|s|m|h) (default 0s)
    --health-timeout: duration                          #Maximum time to allow one check to run (ms|s|m|h) (default 0s)
    --help                                              #Print usage
    --hostname(-h): string                              #Container host name
    --init                                              #Run an init inside the container that forwards signals and reaps processes
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --io-maxbandwidth: int                              #Maximum IO bandwidth limit for the system drive (Windows only)
    --io-maxiops: int                                   #Maximum IOps limit for the system drive (Windows only)
    --ip: string                                        #IPv4 address (e.g., 172.30.100.104)
    --ip6: string                                       #IPv6 address (e.g., 2001:db8::33)
    --ipc: string                                       #IPC mode to use
    --isolation: string                                 #Container isolation technology
    --kernel-memory: int                                #Kernel memory limit
    --label(-l): string                                 #Set meta data on a container
    --label-file: string                                #Read in a line delimited file of labels
    --link: string                                      #Add link to another container
    --link-local-ip: string                             #Container IPv4/IPv6 link-local addresses
    --log-driver: string                                #Logging driver for the container
    --log-opt: string                                   #Log driver options
    --mac-address: string                               #Container MAC address (e.g., 92:d0:c6:0a:29:33)
    --memory(-m): int                                   #Memory limit
    --memory-reservation: int                           #Memory soft limit
    --memory-swap: int                                  #Swap limit equal to memory plus swap: '-1' to enable unlimited swap
    --memory-swappiness: int                            #Tune container memory swappiness (0 to 100) (default -1)
    --mount: string                                     #Attach a filesystem mount to the container
    --name: string                                      #Assign a name to the container
    --network: string                                   #Connect a container to a network
    --network-alias: string                             #Add network-scoped alias for the container
    --no-healthcheck                                    #Disable any container-specified HEALTHCHECK
    --oom-kill-disable                                  #Disable OOM Killer
    --oom-score-adj: int                                #Tune host's OOM preferences (-1000 to 1000)
    --pid: string                                       #PID namespace to use
    --pids-limit: int                                   #Tune container pids limit (set -1 for unlimited)
    --platform: string                                  #Set platform if server is multi-platform capable
    --privileged                                        #Give extended privileges to this container
    --publish(-p): string                               #Publish a container's port(s) to the host
    --publish-all(-P)                                   #Publish all exposed ports to random ports
    --pull: string@"nu-complete docker pull"            #Pull image before running ("always", "missing", "never") (default "missing")
    --quiet(-q)                                         #Suppress the pull output
    --read-only                                         #Mount the container's root filesystem as read only
    --restart: string                                   #Restart policy to apply when a container #exits (default "no")
    --rm                                                #Automatically remove the container when it exits
    --runtime: string                                   #Runtime to use for this container
    --security-opt: string                              #Security Options
    --shm-size: int                                     #Size of /dev/shm
    --sig-proxy                                         #Proxy received signals to the process (default true)
    --stop-signal: string                               #Signal to stop the container
    --stop-timeout: int                                 #Timeout (in seconds) to stop a container
    --storage-opt: string                               #Storage driver options for the container
    --sysctl: string                                    #Sysctl options (default map[])
    --tmpfs: string                                     #Mount a tmpfs directory
    --tty(-t)                                           #Allocate a pseudo-TTY
    --ulimit: int                                       #Ulimit options (default [])
    --use-api-socket                                    #Bind mount Docker API socket and required auth
    --user(-u): string                                  #Username or UID (format: <name|uid>[:<group|gid>])
    --userns: string                                    #User namespace to use
    --uts: string                                       #UTS namespace to use
    --volume(-v): string                                #Bind mount a volume
    --volume-driver: string                             #Optional volume driver for the container
    --volumes-from: string                              #Mount volumes from the specified container(s)
    --workdir(-w): string                               #Working directory inside the container
]

# Start one or more stopped containers
export extern "docker container start" [
    container?: string@"nu-complete docker containers"
    --attach(-a)                                        #Attach STDOUT/STDERR and forward signals
    --checkpoint: string                                #Restore from this checkpoint
    --checkpoint-dir: string                            #Use a custom checkpoint storage directory
    --interactive(-i)                                   #Attach container's STDIN
    --detach-keys: string                               #Override the key sequence for detaching a container
]

# Display a live stream of container(s) resource usage statistics
export extern "docker container stats" [
    container?: string@"nu-complete docker containers"
    --all(-a)                                           #Show all containers (default shows just running)
    --format: string                                    #Pretty-print images using a Go template
    --no-stream                                         #Disable streaming stats and only pull the first result
    --no-trunc                                          #Do not truncate output
]

# Stop one or more running containers
export extern "docker container stop" [
    container?: string@"nu-complete docker containers"
    --time(-t): int                                     #Seconds to wait for stop before killing the container
    --signal(-s): int                                   #Signal to stop the container
]

# Display the running processes of a container
export extern "docker container top" [
    container?: string@"nu-complete docker containers"
]

# Unpause all processes within one or more containers
export extern "docker container unpause" [
    container?: string@"nu-complete docker containers"
]

# Update configuration of one or more containers
export extern "docker container update" [
    container?: string@"nu-complete docker containers"
    --blkio-weight: int                                 #Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
    --cpu-period: int                                   #Limit CPU CFS (Completely Fair Scheduler) period
    --cpu-quota: int                                    #Limit CPU CFS (Completely Fair Scheduler) quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpus: float                                       #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution (0-3, 0,1)
    --cpuset-mems: string                               #MEMs in which to allow execution (0-3, 0,1)
    --memory(-m): binary                                #Memory limit
    --memory-reservation: binary                        #Memory soft limit
    --memory-swap: binary                               #Swap limit equal to memory plus swap: '-1' to enable unlimited swap
    --pids-limit: int                                   #Tune container pids limit (set -1 for unlimited)
    --restart: string                                   #Restart policy to apply when a container #exits (default "no")
]

# Block until one or more containers stop, then print their exit codes
export extern "docker container wait" [
    container?: string@"nu-complete docker containers"
]

# Build an image from a Dockerfile
export extern "docker image build" [
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --allow: string                                     #Allow extra privileged entitlement
    --annotation: string                                #Add annotation to the image
    --attest: string                                    #Attestation parameters (format: type=...)
    --build-arg: string                                 #Set build-time variables
    --build-context: string                             #Additional build contexts (e.g. name=path)
    --builder: string                                   #Override the configured builder instance
    --cache-from: string                                #External cache sources (e.g. user/app:cache)
    --cache-to: string                                  #Cache export destinations (e.g. user/app:cache)
    --call: string                                      #Set method for evaluating build (check|outline|targets)
    --cgroup-parent: string                             #Optional parent cgroup for the container
    --check                                             #Shorthand for "--call=check"
    --compress                                          #Compress the build context using gzip
    --debug(-D)                                         #Enable debug logging
    --file(-f): string@"nu-complete local files"        #Name of the Dockerfile (Default is 'PATH/Dockerfile')
    --iidfile: string                                   #Write the image ID to the file
    --isolation: string                                 #Container isolation technology
    --label: string                                     #Set metadata for an image
    --load                                              #Shorthand for "--output=type=docker"
    --metadata-file: string                             #Write build result metadata to a file
    --network: string                                   #Set the networking mode for the RUN instructions during build (default "default")
    --no-cache                                          #Do not use cache when building the image
    --no-cache-filter: string                           #Do not cache specified stages
    --output(-o): string                                #Output destination (format: type=local,dest=path)
    --platform: string                                  #Set platform if server is multi-platform capable
    --policy: string                                    #Policy configuration (format: id=...)
    --progress: string                                  #Set type of progress output (auto, plain, tty). Use plain to show container output
    --provenance: string                                #Shorthand for "--attest=type=provenance"
    --pull                                              #Always attempt to pull a newer version of the image
    --push                                              #Shorthand for "--output=type=registry"
    --quiet(-q)                                         #Suppress the build output and print image ID on success
    --sbom: string                                      #Shorthand for "--attest=type=sbom"
    --secret: string                                    #Secret file to expose to the build (only if BuildKit enabled): id=mysecret,src=/local/secret
    --shm-size: int                                     #Shared memory size for build containers
    --ssh: string                                       #SSH agent socket or keys to expose to the build (only if BuildKit enabled)
    --tag(-t): string                                   #Name and optionally a tag in the 'name:tag' format
    --target: string                                    #Set the target build stage to build
    --ulimit: string                                    #Ulimit options (default [])
]

# Show the history of an images
export extern "docker image history" [
    image?: string@"nu-complete docker images"
    --format: string                                    #Pretty-print images using a Go template
    --human(-H)                                         #Print sizes and dates in human readable format
    --no-trunc                                          #Don't truncate output
    --platform: string                                  #Show history for the given platform
    --quiet(-q)                                         #Only show numeric IDs
]

# Import the contents from a tarball as a filesystem image
export extern "docker image import" [
    file?: string                                       #Source tarball file or URL
    repository?: string                                 #Target repository[:tag]
    --change(-c): string                                #Apply Dockerfile instruction to the created image
    --message(-m): string                               #Set commit message for imported image
    --platform: string                                  #Set platform if server is multi-platform capable
]

# Display detailed information on one or more images
export extern "docker image inspect" [
    ...image: string@"nu-complete docker images"
    --format(-f): string                                #Format output using a custom template
    --platform: string                                  #Inspect a specific platform of the multi-platform image
]

# Load an image from a tar archive or STDIN
export extern "docker image load" [
    --input(-i): string                                 #Read from tar archive file, instead of STDIN
    --platform: string                                  #Load only the given platform(s)
    --quiet(-q)                                         #Suppress the load output
]

# Remove unused images
export extern "docker image prune" [
    --all(-a)                                           #Remove all unused images, not just dangling ones
    --filter: string                                    #Provide filter values (e.g. "until=<timestamp>")
    --force(-f)                                         #Do not prompt for confirmation
]

# Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
export extern "docker image tag" [
    source?: string@"nu-complete docker images"
    target?: string@"nu-complete docker images"
]

# List images
export extern "docker image ls" [
    --all(-a)                                           #Show all images (default hides intermediate images)
    --digests                                           #Show digests
    --filter: string                                    #Filter output based on conditions provided
    --format: string                                    #Pretty-print images using a Go template
    --no-trunc                                          #Don't truncate output
    --quiet(-q)                                         #Only show numeric IDs
    --tree                                              #List multi-platform images as a tree (EXPERIMENTAL)
]

# Download an image from a registry
export extern "docker image pull" [
    image?: string@"nu-complete docker images"
    --all-tags(-a)                                      #Download all tagged images in the repository
    --disable-content-trust                             #Skip image verification (default true)
    --platform: string                                  #Set platform if server is multi-platform capable
    --quiet(-q)                                         #Suppress verbose output
]

# Upload an image to a registry
export extern "docker image push" [
    image?: string@"nu-complete docker images"
    --all-tags(-a)                                      #Push all tags of the specified image
    --disable-content-trust                             #Skip image verification (default true)
    --platform: string                                  #Push a platform-specific manifest as a single-platform image
    --quiet(-q)                                         #Suppress verbose output
]

# Save one or more images to a tar archive (streamed to STDOUT by default)
export extern "docker image save" [
    image?: string@"nu-complete docker images"
    --output(-o): string                                #Write to a file, instead of STDOUT
    --platform: string                                  #Save only the given platform(s)
]

# Delete one or more docker image
export extern "docker image rm" [
    ...image: string@"nu-complete docker images"
    --force(-f)                                         #Force removal of the image
    --no-prune                                          #Do not delete untagged parents
    --platform: string                                  #Remove only the given platform variant
]

# Extended build capabilities with BuildKit
export extern "docker buildx" [
    --builder: string                                   #Override the configured builder instance (default "default")
    --debug(-D)                                         #Enable debug logging
]

# Stop and remove containers, networks
export extern "docker compose down" [
    --dry-run                                           #Execute command in dry run mode
    --remove-orphans                                    #Remove containers for services not defined in the Compose file
    --rmi: string@"nu-complete docker remove image"     #Remove images used by services. "local" remove only images that don't have a custom tag ("local"|"all")
    --timeout(-t): int                                  #Specify a shutdown timeout in seconds
    --volumes(-v)                                       #Remove named volumes declared in the "volumes" section of the Compose file and anonymous volumes attached to containers
]

# List containers
export extern "docker compose ps" [
    --all(-a)                                           #Show all stopped containers (including those created by the run command)
    --dry-run                                           #Execute command in dry run mode
    --filter: string                                    #Filter services by a property (supported filters: status)
    --format: string                                    #Format output using a custom template: 'table': Print output in table; format with column headers (default) 'table TEMPLATE': Print output in table; format using the given Go template 'json': Print in JSON format; 'TEMPLATE': Print output using the given Go template; Refer to https://docs.docker.com/go/formatting/ for more information about formatting output with templates (default "table")
    --no-truncate                                       #Don't truncate output
    --no-trunc                                          #Don't truncate output
    --orphans                                           #Include orphaned services (not declared by project) (default true)
    --quiet(-q)                                         #Only display IDs
    --services                                          #Display services
    --status: string@"nu-complete docker compose service status" #Filter services by status. Values: [paused | restarting | removing | running | dead | created | exited]
]

# Stop containers
export extern "docker compose stop" [
    --dry-run                                           #Execute command in dry run mode
    --timeout(-t): int                                  #Specify a shutdown timeout in seconds
]

# Restart service containers
export extern "docker compose restart" [
    --dry-run                                           #Execute command in dry run mode
    --no-deps                                           #Don't restart dependent services
    --timeout(-t): int                                  #Specify a shutdown timeout in seconds
]

# Create and start containers
export extern "docker compose up" [
    --abort-on-container-exit                           #Stops all containers if any container was stopped. Incompatible with -d/--detach
    --abort-on-container-failure                        #Stops all containers if any container had a non-zero exit code. Incompatible with -d/--detach
    --always-recreate-deps                              #Recreate dependent containers. Incompatible with --no-recreate
    --attach: string                                    #Restrict attaching to the specified services. Incompatible with --attach-dependencies
    --attach-dependencies                               #Automatically attach to log output of all dependent services
    --build                                             #Build images before starting containers
    --detach(-d)                                        #Detached mode: Run containers in the background
    --dry-run                                           #Execute command in dry run mode
    --exit-code-from: string                            #Return the exit code of the selected service container. Implies --abort-on-container-exit
    --force-recreate                                    #Recreate containers even if their configuration and image haven't changed
    --menu                                              #Enable interactive shortcuts when running attached. Incompatible with --detach. Can also be enable/disable
    --no-attach: string                                 #Do not attach (stream logs) to the specified services
    --no-build                                          #Don't build an image, even if it's policy
    --no-color                                          #Produce monochrome output
    --no-deps                                           #Don't start linked services
    --no-log-prefix                                     #Don't print prefix in logs
    --no-recreate                                       #If containers already exist, don't recreate them. Incompatible with --force-recreate
    --no-start                                          #Don't start the services after creating them
    --pull: string@"nu-complete docker pull"            #Pull image before running ("always"|"missing"|"never") (default "policy")
    --quiet-build                                       #Suppress the build output
    --quiet-pull                                        #Pull without printing progress information
    --remove-orphans                                    #Remove containers for services not defined in the Compose file
    --renew-anon-volumes(-V)                            #Recreate anonymous volumes instead of retrieving data from the previous containers
    --scale: string                                     #Scale SERVICE to NUM instances. Overrides the scale setting in the Compose file if present
    --timeout(-t): int                                  #Use this timeout in seconds for container shutdown when attached or when containers are already running
    --timestamps                                        #Show timestamps
    --wait                                              #Wait for services to be running|healthy. Implies detached mode
    --wait-timeout: int                                 #Maximum duration to wait for the project to be running|healthy
    --watch(-w)                                         #Watch source code and rebuild|refresh containers when files are updated
    --yes(-y)                                           #Assume "yes" as answer to all prompts
]

# Attach local standard input, output, and error streams to a running container
export extern "docker compose attach" [
    --detach-keys: string                               #Override the key sequence for detaching from container
    --dry-run                                           #Execute command in dry run mode
    --index: int                                        #Index of the container if service has multiple replicas
    --no-stdin                                          #Do not attach STDIN
    --sig-proxy                                         #Proxy all received signals to the process
]

# Build or rebuild services
export extern "docker compose build" [
    --build-arg: string                                 #Set build-time variables for services
    --builder: string                                   #Set builder to use
    --check                                             #Check build configuration
    --dry-run                                           #Execute command in dry run mode
    --memory(-m): int                                   #Set memory limit for the build container
    --no-cache                                          #Do not use cache when building the image
    --print                                             #Print equivalent bake file
    --provenance: string                                #Add a provenance attestation
    --pull                                              #Always attempt to pull a newer version of the image
    --push                                              #Push service images
    --quiet(-q)                                         #Suppress the build output
    --sbom: string                                      #Add a SBOM attestation
    --ssh: string                                       #Set SSH authentications used when building service images
    --with-dependencies                                 #Also build dependencies (transitively)
]

# Create a new image from a service container's changes
export extern "docker compose commit" [
    --author(-a): string                                #Author
    --change(-c): string                                #Apply Dockerfile instruction to the created image
    --dry-run                                           #Execute command in dry run mode
    --index: int                                        #Index of the container if service has multiple replicas
    --message(-m): string                               #Commit message
    --pause(-p)                                         #Pause container during commit (default true)
]

# Parse, resolve and render the compose file
export extern "docker compose config" [
    --dry-run                                           #Execute command in dry run mode
    --environment                                       #Print environment used for interpolation
    --format: string                                    #Format the output (yaml|json)
    --hash: string                                      #Print the service config hash, one per line
    --images                                            #Print the image names, one per line
    --lock-image-digests                                #Produces an override file with image digests
    --models                                            #Print the model names, one per line
    --networks                                          #Print the network names, one per line
    --no-consistency                                    #Don't check model consistency
    --no-env-resolution                                 #Don't resolve service env files
    --no-interpolate                                    #Don't interpolate environment variables
    --no-normalize                                      #Don't normalize compose model
    --no-path-resolution                                #Don't resolve file paths
    --output(-o): string                                #Save to file (default to stdout)
    --profiles                                          #Print the profile names, one per line
    --quiet(-q)                                         #Only validate the configuration, don't print anything
    --resolve-image-digests                             #Pin image tags to digests
    --services                                          #Print the service names, one per line
    --variables                                         #Print model variables and default values
    --volumes                                           #Print the volume names, one per line
]

# Copy files between a service container and the local filesystem
export extern "docker compose cp" [
    src?: string                                        #Source path
    dest?: string                                       #Destination path
    --all                                               #Include containers created by the run command
    --archive(-a)                                       #Archive mode (copy all uid/gid information)
    --dry-run                                           #Execute command in dry run mode
    --follow-link(-L)                                   #Always follow symbol link in SRC_PATH
    --index: int                                        #Index of the container if service has multiple replicas
]

# Create containers for a service
export extern "docker compose create" [
    --build                                             #Build images before starting containers
    --dry-run                                           #Execute command in dry run mode
    --force-recreate                                    #Recreate containers even if their configuration hasn't changed
    --no-build                                          #Don't build an image, even if it's policy
    --no-recreate                                       #If containers already exist, don't recreate
    --pull: string@"nu-complete docker pull"            #Pull image before running
    --quiet-pull                                        #Pull without printing progress information
    --remove-orphans                                    #Remove containers for services not defined in the Compose file
    --scale: string                                     #Scale SERVICE to NUM instances
    --yes(-y)                                           #Assume "yes" as answer to all prompts and run non-interactively
]

# Receive real time events from containers
export extern "docker compose events" [
    --dry-run                                           #Execute command in dry run mode
    --json                                              #Output events as a stream of json objects
    --since: string                                     #Show all events created since timestamp
    --until: string                                     #Stream events until this timestamp
]

# Execute a command in a running container
export extern "docker compose exec" [
    --detach(-d)                                        #Detached mode: Run command in the background
    --dry-run                                           #Execute command in dry run mode
    --env(-e): string                                   #Set environment variables
    --index: int                                        #Index of the container if service has multiple replicas
    --no-TTY(-T)                                        #Disable pseudo-TTY allocation
    --privileged                                        #Give extended privileges to the process
    --user(-u): string                                  #Run the command as this user
    --workdir(-w): string                               #Path to workdir directory for this command
]

# Export a service container's filesystem as a tar archive
export extern "docker compose export" [
    --dry-run                                           #Execute command in dry run mode
    --index: int                                        #Index of the container if service has multiple replicas
    --output(-o): string                                #Write to a file, instead of STDOUT
]

# List images used by the created containers
export extern "docker compose images" [
    --dry-run                                           #Execute command in dry run mode
    --format: string                                    #Format the output (table|json)
    --quiet(-q)                                         #Only display IDs
]

# Force stop service containers
export extern "docker compose kill" [
    --dry-run                                           #Execute command in dry run mode
    --remove-orphans                                    #Remove containers for services not defined in the Compose file
    --signal(-s): string                                #SIGNAL to send to the container (default "SIGKILL")
]

# View output from containers
export extern "docker compose logs" [
    --dry-run                                           #Execute command in dry run mode
    --follow(-f)                                        #Follow log output
    --index: int                                        #Index of the container if service has multiple replicas
    --no-color                                          #Produce monochrome output
    --no-log-prefix                                     #Don't print prefix in logs
    --since: string                                     #Show logs since timestamp
    --tail(-n): string                                  #Number of lines to show from the end of the logs
    --timestamps(-t)                                    #Show timestamps
    --until: string                                     #Show logs before a timestamp
]

# List running compose projects
export extern "docker compose ls" [
    --all(-a)                                           #Show all stopped Compose projects
    --dry-run                                           #Execute command in dry run mode
    --filter: string                                    #Filter output based on conditions provided
    --format: string                                    #Format the output (table|json)
    --quiet(-q)                                         #Only display project names
]

# Pause services
export extern "docker compose pause" [
    --dry-run                                           #Execute command in dry run mode
]

# Print the public port for a port binding
export extern "docker compose port" [
    --dry-run                                           #Execute command in dry run mode
    --index: int                                        #Index of the container if service has multiple replicas
    --protocol: string                                  #tcp or udp (default "tcp")
]

# Publish compose application
export extern "docker compose publish" [
    --app                                               #Published compose application (includes images)
    --dry-run                                           #Execute command in dry run mode
    --oci-version: string                               #OCI image/artifact specification version
    --resolve-image-digests                             #Pin image tags to digests
    --with-env                                          #Include environment variables in the published artifact
    --yes(-y)                                           #Assume "yes" as answer to all prompts
]

# Pull service images
export extern "docker compose pull" [
    --dry-run                                           #Execute command in dry run mode
    --ignore-buildable                                  #Ignore images that can be built
    --ignore-pull-failures                              #Pull what it can and ignores images with pull failures
    --include-deps                                      #Also pull services declared as dependencies
    --policy: string                                    #Apply pull policy ("missing"|"always")
    --quiet(-q)                                         #Pull without printing progress information
]

# Push service images
export extern "docker compose push" [
    --dry-run                                           #Execute command in dry run mode
    --ignore-push-failures                              #Push what it can and ignores images with push failures
    --include-deps                                      #Also push images of services declared as dependencies
    --quiet(-q)                                         #Push without printing progress information
]

# Remove stopped service containers
export extern "docker compose rm" [
    --dry-run                                           #Execute command in dry run mode
    --force(-f)                                         #Don't ask to confirm removal
    --stop(-s)                                          #Stop the containers, if required, before removing
    --volumes(-v)                                       #Remove any anonymous volumes attached to containers
]

# Run a one-off command on a service
export extern "docker compose run" [
    --build                                             #Build image before starting container
    --cap-add: string                                   #Add Linux capabilities
    --cap-drop: string                                  #Drop Linux capabilities
    --detach(-d)                                        #Run container in background and print container ID
    --dry-run                                           #Execute command in dry run mode
    --entrypoint: string                                #Override the entrypoint of the image
    --env(-e): string                                   #Set environment variables
    --env-from-file: string                             #Set environment variables from file
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --label(-l): string                                 #Add or override a label
    --name: string                                      #Assign a name to the container
    --no-TTY(-T)                                        #Disable pseudo-TTY allocation
    --no-deps                                           #Don't start linked services
    --publish(-p): string                               #Publish a container's port(s) to the host
    --pull: string@"nu-complete docker pull"            #Pull image before running
    --quiet(-q)                                         #Don't print anything to STDOUT
    --quiet-build                                       #Suppress progress output from the build
    --quiet-pull                                        #Pull without printing progress information
    --remove-orphans                                    #Remove containers for services not defined in the Compose file
    --rm                                                #Automatically remove the container
    --service-ports(-P)                                 #Run command with all service's ports enabled
    --use-aliases                                       #Use the service's network useAliases
    --user(-u): string                                  #Run as specified username or uid
    --volume(-v): string                                #Bind mount a volume
    --workdir(-w): string                               #Working directory inside the container
]

# Scale services
export extern "docker compose scale" [
    --dry-run                                           #Execute command in dry run mode
    --no-deps                                           #Don't start linked services
]

# Start services
export extern "docker compose start" [
    --dry-run                                           #Execute command in dry run mode
    --wait                                              #Wait for services to be running|healthy
    --wait-timeout: int                                 #Maximum duration in seconds to wait for the project to be running|healthy
]

# Display a live stream of resource usage stats
export extern "docker compose stats" [
    --all(-a)                                           #Show all containers (default shows just running)
    --dry-run                                           #Execute command in dry run mode
    --format: string                                    #Format output using a custom template
    --no-stream                                         #Disable streaming stats and only pull the first result
    --no-trunc                                          #Do not truncate output
]

# Display the running processes
export extern "docker compose top" [
    --dry-run                                           #Execute command in dry run mode
]

# Unpause services
export extern "docker compose unpause" [
    --dry-run                                           #Execute command in dry run mode
]

# Show the Docker Compose version information
export extern "docker compose version" [
    --dry-run                                           #Execute command in dry run mode
    --format(-f): string                                #Format the output (pretty|json)
    --short                                             #Shows only Compose's version number
]

# List volumes
export extern "docker compose volumes" [
    --dry-run                                           #Execute command in dry run mode
    --format: string                                    #Format output using a custom template
    --quiet(-q)                                         #Only display volume names
]

# Block until containers of all services stop
export extern "docker compose wait" [
    --down-project                                      #Drops project when the first container stops
    --dry-run                                           #Execute command in dry run mode
]

# Watch for file changes and rebuild/refresh containers
export extern "docker compose watch" [
    --dry-run                                           #Execute command in dry run mode
    --no-up                                             #Do not build & start services before watching
    --prune                                             #Prune dangling images on rebuild (default true)
    --quiet                                             #Hide build output
]

# An open-source container management platform.
export extern "docker" [
    command?: string@"nu-complete docker subcommands"   #Subcommands
    --config: string                                    #Location of client config files (default "/root/.docker")
    --context(-c): string                               #Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker context use")
    --debug(-D)                                         #Enable debug mode
    --host(-H): string                                  #Daemon socket(s) to connect to
    --log-level(-l): string                             #Set the logging level ("debug"|"info"|"warn"|"error"|"fatal")
    --tls                                               #Use TLS; implied by --tlsverify
    --tlscacert: string                                 #Trust certs signed only by this CA
    --tlscert: string                                   #Path to TLS certificate file
    --tlskey: string                                    #Path to TLS key file
    --tlsverify                                         #Use TLS and verify the remote
    --version(-v)                                       #Print version information and quit
]

# Top-level aliases for `docker container *` and `docker image *` commands.
# These mirror the flag sets of the corresponding subcommand externs.

# Attach local standard input, output, and error streams to a running container
export extern "docker attach" [
    container?: string@"nu-complete docker containers"
    --detach-keys: string                               #Override the key sequence for detaching a container
    --no-stdin                                          #Do not attach STDIN
    --sig-proxy                                         #Proxy all received signals to the process
]

# Create a new image from a container's changes
export extern "docker commit" [
    container?: string@"nu-complete docker containers"
    --author(-a): string                                #Author
    --change(-c): string                                #Apply Dockerfile instruction to the created image
    --message(-m): string                               #Commit message
    --pause(-p)                                         #Pause container during commit (default true)
    --no-pause                                          #Disable pausing container during commit
]

# Copy files/folders between a container and the local filesystem
export extern "docker cp" [
    src?: string                                        #Source path (e.g. container:path or local path)
    dest?: string                                       #Destination path (e.g. container:path or local path)
    --archive(-a)                                       #Archive mode (copy all uid/gid information)
    --follow-link(-L)                                   #Always follow symbol link in SRC_PATH
    --quiet(-q)                                         #Suppress progress output during copy
]

# Create a new container
export extern "docker create" [
    image?: string@"nu-complete docker images"          #The image to create the container from
    command?: string                                    #Command to run inside the container
    ...args: string
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --annotation: string                                #Add an annotation to the container
    --attach: string                                    #Attach to STDIN, STDOUT or STDERR
    --blkio-weight: int                                 #Block IO (relative weight)
    --blkio-weight-device: string                       #Block IO weight (relative device weight)
    --cap-add: string                                   #Add Linux capabilities
    --cap-drop: string                                  #Drop Linux capabilities
    --cgroup-parent: string                             #Optional parent cgroup for the container
    --cgroupns: string                                  #Cgroup namespace to use (host|private)
    --cidfile: string                                   #Write the container ID to the file
    --cpu-period: int                                   #Limit CPU CFS period
    --cpu-quota: int                                    #Limit CPU CFS quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpu-count: int                                    #CPU count (Windows only)
    --cpu-percent: int                                  #CPU percent (Windows only)
    --cpus: int                                         #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution
    --cpuset-mems: string                               #MEMs in which to allow execution
    --detach(-d)                                        #Run container in background
    --detach-keys: string                               #Override the key sequence for detaching a container
    --device: string                                    #Add a host device to the container
    --device-cgroup-rule: string                        #Add a rule to the cgroup allowed devices list
    --device-read-bps: int                              #Limit read rate (bytes per second) from a device
    --device-read-iops: int                             #Limit read rate (IO per second) from a device
    --device-write-bps: int                             #Limit write rate (bytes per second) to a device
    --device-write-iops: int                            #Limit write rate (IO per second) to a device
    --disable-content-trust                             #Skip image verification (default true)
    --dns: int                                          #Set custom DNS servers
    --dns-option: string                                #Set DNS options
    --dns-search: string                                #Set custom DNS search domains
    --domainname: string                                #Container NIS domain name
    --entrypoint: string                                #Overwrite the default ENTRYPOINT of the image
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --expose: string                                    #Expose a port or a range of ports
    --gpus: string                                      #GPU devices to add to the container
    --group-add: string                                 #Add additional groups to join
    --health-cmd: string                                #Command to run to check health
    --health-interval: duration                         #Time between running the check
    --health-retries: int                               #Consecutive failures needed to report unhealthy
    --health-start-interval: duration                   #Time between running the check during the start period
    --health-start-period: duration                     #Start period for the container to initialize
    --health-timeout: duration                          #Maximum time to allow one check to run
    --hostname(-h): string                              #Container host name
    --init                                              #Run an init inside the container that forwards signals and reaps processes
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --io-maxbandwidth: int                              #Maximum IO bandwidth limit for the system drive (Windows only)
    --io-maxiops: int                                   #Maximum IOps limit for the system drive (Windows only)
    --ip: string                                        #IPv4 address
    --ip6: string                                       #IPv6 address
    --ipc: string                                       #IPC mode to use
    --isolation: string                                 #Container isolation technology
    --kernel-memory: int                                #Kernel memory limit
    --label(-l): string                                 #Set meta data on a container
    --label-file: string                                #Read in a line delimited file of labels
    --link: string                                      #Add link to another container
    --link-local-ip: string                             #Container IPv4/IPv6 link-local addresses
    --log-driver: string                                #Logging driver for the container
    --log-opt: string                                   #Log driver options
    --mac-address: string                               #Container MAC address
    --memory(-m): int                                   #Memory limit
    --memory-reservation: int                           #Memory soft limit
    --memory-swap: int                                  #Swap limit equal to memory plus swap
    --memory-swappiness: int                            #Tune container memory swappiness (0 to 100)
    --mount: string                                     #Attach a filesystem mount to the container
    --name: string                                      #Assign a name to the container
    --network: string                                   #Connect a container to a network
    --network-alias: string                             #Add network-scoped alias for the container
    --no-healthcheck                                    #Disable any container-specified HEALTHCHECK
    --oom-kill-disable                                  #Disable OOM Killer
    --oom-score-adj: int                                #Tune host's OOM preferences
    --pid: string                                       #PID namespace to use
    --pids-limit: int                                   #Tune container pids limit
    --platform: string                                  #Set platform if server is multi-platform capable
    --privileged                                        #Give extended privileges to this container
    --publish(-p): string                               #Publish a container's port(s) to the host
    --publish-all(-P)                                   #Publish all exposed ports to random ports
    --pull: string@"nu-complete docker pull"            #Pull image before running
    --quiet(-q)                                         #Suppress the pull output
    --read-only                                         #Mount the container's root filesystem as read only
    --restart: string                                   #Restart policy to apply when a container exits
    --rm                                                #Automatically remove the container when it exits
    --runtime: string                                   #Runtime to use for this container
    --security-opt: string                              #Security Options
    --shm-size: int                                     #Size of /dev/shm
    --sig-proxy                                         #Proxy received signals to the process
    --stop-signal: string                               #Signal to stop the container
    --stop-timeout: int                                 #Timeout (in seconds) to stop a container
    --storage-opt: string                               #Storage driver options for the container
    --sysctl: string                                    #Sysctl options
    --tmpfs: string                                     #Mount a tmpfs directory
    --tty(-t)                                           #Allocate a pseudo-TTY
    --ulimit: int                                       #Ulimit options
    --use-api-socket                                    #Bind mount Docker API socket and required auth
    --user(-u): string                                  #Username or UID
    --userns: string                                    #User namespace to use
    --uts: string                                       #UTS namespace to use
    --volume(-v): string                                #Bind mount a volume
    --volume-driver: string                             #Optional volume driver for the container
    --volumes-from: string                              #Mount volumes from the specified container(s)
    --workdir(-w): string                               #Working directory inside the container
]

# Inspect changes to files or directories on a container's filesystem
export extern "docker diff" [
    container?: string@"nu-complete docker containers"
]

# Get real time events from the server
export extern "docker events" [
    --filter(-f): string                                #Filter output based on conditions provided
    --format: string                                    #Pretty-print events using a Go template
    --since: string                                     #Show all events created since timestamp
    --until: string                                     #Stream events until this timestamp
]

# Run a command in a running container
export extern "docker exec" [
    container?: string@"nu-complete docker containers"
    --detach(-d)                                        #Detached mode: run command in the background
    --detach-keys: string                               #Override the key sequence for detaching a container
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --privileged                                        #Give extended privileges to the command
    --tty(-t)                                           #Allocate a pseudo-TTY
    --user(-u): string                                  #Username or UID
    --workdir(-w): string                               #Working directory inside the container
]

# Export a container's filesystem as a tar archive
export extern "docker export" [
    container?: string@"nu-complete docker containers"
    --output(-o): string                                #Write to a file, instead of STDOUT
]

# Return low-level information on Docker objects
export extern "docker inspect" [
    ...object: string                                   #Container, image, or other object
    --format(-f): string                                #Format the output using the given Go template
    --size(-s)                                          #Display total file sizes (containers only)
    --type: string                                      #Return JSON for specified type
]

# Kill one or more running containers
export extern "docker kill" [
    container?: string@"nu-complete docker containers"
    --signal(-s): string                                #Signal to send to the container
]

# Fetch the logs of a container
export extern "docker logs" [
    container?: string@"nu-complete docker containers"
    --details                                           #Show extra details provided to logs
    --follow(-f)                                        #Follow log output
    --since: string                                     #Show logs since timestamp
    --tail(-n): string                                  #Number of lines to show from the end of the logs
    --timestamps(-t)                                    #Show timestamps
    --until: string                                     #Show logs before a timestamp
]

# Pause all processes within one or more containers
export extern "docker pause" [
    container?: string@"nu-complete docker containers"
]

# List port mappings or a specific mapping for the container
export extern "docker port" [
    container?: string@"nu-complete docker containers"
]

# Rename a container
export extern "docker rename" [
    container?: string@"nu-complete docker containers"
    name?: string
]

# Restart one or more containers
export extern "docker restart" [
    container?: string@"nu-complete docker containers"
    --time(-t): int                                     #Seconds to wait for stop before killing the container
    --signal(-s): string                                #Signal to stop the container
]

# Remove one or more containers
export extern "docker rm" [
    container?: string@"nu-complete docker containers"
    --force(-f)                                         #Force the removal of a running container (uses SIGKILL)
    --link(-l)                                          #Remove the specified link
    --volumes(-v)                                       #Remove anonymous volumes associated with the container
]

# Run a command in a new container
export extern "docker run" [
    image?: string@"nu-complete docker run"             #The image to create the container from
    command?: string                                    #Command to run inside the container
    ...args: string
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --annotation: string                                #Add an annotation to the container
    --attach: string                                    #Attach to STDIN, STDOUT or STDERR
    --blkio-weight: int                                 #Block IO (relative weight)
    --blkio-weight-device: string                       #Block IO weight (relative device weight)
    --cap-add: string                                   #Add Linux capabilities
    --cap-drop: string                                  #Drop Linux capabilities
    --cgroup-parent: string                             #Optional parent cgroup for the container
    --cgroupns: string                                  #Cgroup namespace to use (host|private)
    --cidfile: string                                   #Write the container ID to the file
    --cpu-period: int                                   #Limit CPU CFS period
    --cpu-quota: int                                    #Limit CPU CFS quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpu-count: int                                    #CPU count (Windows only)
    --cpu-percent: int                                  #CPU percent (Windows only)
    --cpus: int                                         #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution
    --cpuset-mems: string                               #MEMs in which to allow execution
    --detach(-d)                                        #Run container in background
    --detach-keys: string                               #Override the key sequence for detaching a container
    --device: string                                    #Add a host device to the container
    --device-cgroup-rule: string                        #Add a rule to the cgroup allowed devices list
    --device-read-bps: int                              #Limit read rate (bytes per second) from a device
    --device-read-iops: int                             #Limit read rate (IO per second) from a device
    --device-write-bps: int                             #Limit write rate (bytes per second) to a device
    --device-write-iops: int                            #Limit write rate (IO per second) to a device
    --disable-content-trust                             #Skip image verification (default true)
    --dns: int                                          #Set custom DNS servers
    --dns-option: string                                #Set DNS options
    --dns-search: string                                #Set custom DNS search domains
    --domainname: string                                #Container NIS domain name
    --entrypoint: string                                #Overwrite the default ENTRYPOINT of the image
    --env(-e): string                                   #Set environment variables
    --env-file: string                                  #Read in a file of environment variables
    --expose: string                                    #Expose a port or a range of ports
    --gpus: string                                      #GPU devices to add to the container
    --group-add: string                                 #Add additional groups to join
    --health-cmd: string                                #Command to run to check health
    --health-interval: duration                         #Time between running the check
    --health-retries: int                               #Consecutive failures needed to report unhealthy
    --health-start-interval: duration                   #Time between running the check during the start period
    --health-start-period: duration                     #Start period for the container to initialize
    --health-timeout: duration                          #Maximum time to allow one check to run
    --hostname(-h): string                              #Container host name
    --init                                              #Run an init inside the container
    --interactive(-i)                                   #Keep STDIN open even if not attached
    --io-maxbandwidth: int                              #Maximum IO bandwidth limit for the system drive (Windows only)
    --io-maxiops: int                                   #Maximum IOps limit for the system drive (Windows only)
    --ip: string                                        #IPv4 address
    --ip6: string                                       #IPv6 address
    --ipc: string                                       #IPC mode to use
    --isolation: string                                 #Container isolation technology
    --kernel-memory: int                                #Kernel memory limit
    --label(-l): string                                 #Set meta data on a container
    --label-file: string                                #Read in a line delimited file of labels
    --link: string                                      #Add link to another container
    --link-local-ip: string                             #Container IPv4/IPv6 link-local addresses
    --log-driver: string                                #Logging driver for the container
    --log-opt: string                                   #Log driver options
    --mac-address: string                               #Container MAC address
    --memory(-m): int                                   #Memory limit
    --memory-reservation: int                           #Memory soft limit
    --memory-swap: int                                  #Swap limit equal to memory plus swap
    --memory-swappiness: int                            #Tune container memory swappiness
    --mount: string                                     #Attach a filesystem mount to the container
    --name: string                                      #Assign a name to the container
    --network: string                                   #Connect a container to a network
    --network-alias: string                             #Add network-scoped alias for the container
    --no-healthcheck                                    #Disable any container-specified HEALTHCHECK
    --oom-kill-disable                                  #Disable OOM Killer
    --oom-score-adj: int                                #Tune host's OOM preferences
    --pid: string                                       #PID namespace to use
    --pids-limit: int                                   #Tune container pids limit
    --platform: string                                  #Set platform if server is multi-platform capable
    --privileged                                        #Give extended privileges to this container
    --publish(-p): string                               #Publish a container's port(s) to the host
    --publish-all(-P)                                   #Publish all exposed ports to random ports
    --pull: string@"nu-complete docker pull"            #Pull image before running
    --quiet(-q)                                         #Suppress the pull output
    --read-only                                         #Mount the container's root filesystem as read only
    --restart: string                                   #Restart policy to apply when a container exits
    --rm                                                #Automatically remove the container when it exits
    --runtime: string                                   #Runtime to use for this container
    --security-opt: string                              #Security Options
    --shm-size: int                                     #Size of /dev/shm
    --sig-proxy                                         #Proxy received signals to the process
    --stop-signal: string                               #Signal to stop the container
    --stop-timeout: int                                 #Timeout (in seconds) to stop a container
    --storage-opt: string                               #Storage driver options for the container
    --sysctl: string                                    #Sysctl options
    --tmpfs: string                                     #Mount a tmpfs directory
    --tty(-t)                                           #Allocate a pseudo-TTY
    --ulimit: int                                       #Ulimit options
    --use-api-socket                                    #Bind mount Docker API socket and required auth
    --user(-u): string                                  #Username or UID
    --userns: string                                    #User namespace to use
    --uts: string                                       #UTS namespace to use
    --volume(-v): string                                #Bind mount a volume
    --volume-driver: string                             #Optional volume driver for the container
    --volumes-from: string                              #Mount volumes from the specified container(s)
    --workdir(-w): string                               #Working directory inside the container
]

# Start one or more stopped containers
export extern "docker start" [
    container?: string@"nu-complete docker containers"
    --attach(-a)                                        #Attach STDOUT/STDERR and forward signals
    --checkpoint: string                                #Restore from this checkpoint
    --checkpoint-dir: string                            #Use a custom checkpoint storage directory
    --interactive(-i)                                   #Attach container's STDIN
    --detach-keys: string                               #Override the key sequence for detaching a container
]

# Display a live stream of container(s) resource usage statistics
export extern "docker stats" [
    container?: string@"nu-complete docker containers"
    --all(-a)                                           #Show all containers (default shows just running)
    --format: string                                    #Pretty-print stats using a Go template
    --no-stream                                         #Disable streaming stats and only pull the first result
    --no-trunc                                          #Do not truncate output
]

# Stop one or more running containers
export extern "docker stop" [
    container?: string@"nu-complete docker containers"
    --time(-t): int                                     #Seconds to wait for stop before killing the container
    --signal(-s): int                                   #Signal to stop the container
]

# Display the running processes of a container
export extern "docker top" [
    container?: string@"nu-complete docker containers"
]

# Unpause all processes within one or more containers
export extern "docker unpause" [
    container?: string@"nu-complete docker containers"
]

# Update configuration of one or more containers
export extern "docker update" [
    container?: string@"nu-complete docker containers"
    --blkio-weight: int                                 #Block IO (relative weight)
    --cpu-period: int                                   #Limit CPU CFS period
    --cpu-quota: int                                    #Limit CPU CFS quota
    --cpu-rt-period: int                                #Limit CPU real-time period in microseconds
    --cpu-rt-runtime: int                               #Limit CPU real-time runtime in microseconds
    --cpu-shares(-c): int                               #CPU shares (relative weight)
    --cpus: float                                       #Number of CPUs
    --cpuset-cpus: string                               #CPUs in which to allow execution
    --cpuset-mems: string                               #MEMs in which to allow execution
    --memory(-m): binary                                #Memory limit
    --memory-reservation: binary                        #Memory soft limit
    --memory-swap: binary                               #Swap limit equal to memory plus swap
    --pids-limit: int                                   #Tune container pids limit
    --restart: string                                   #Restart policy to apply when a container exits
]

# Block until one or more containers stop, then print their exit codes
export extern "docker wait" [
    container?: string@"nu-complete docker containers"
]

# Build an image from a Dockerfile
export extern "docker build" [
    --add-host: string                                  #Add a custom host-to-IP mapping (host:ip)
    --allow: string                                     #Allow extra privileged entitlement
    --annotation: string                                #Add annotation to the image
    --attest: string                                    #Attestation parameters (format: type=...)
    --build-arg: string                                 #Set build-time variables
    --build-context: string                             #Additional build contexts
    --builder: string                                   #Override the configured builder instance
    --cache-from: string                                #External cache sources
    --cache-to: string                                  #Cache export destinations
    --call: string                                      #Set method for evaluating build
    --cgroup-parent: string                             #Set the parent cgroup for the "RUN" instructions during build
    --check                                             #Shorthand for "--call=check"
    --compress                                          #Compress the build context using gzip
    --debug(-D)                                         #Enable debug logging
    --file(-f): string@"nu-complete local files"        #Name of the Dockerfile
    --iidfile: string                                   #Write the image ID to a file
    --isolation: string                                 #Container isolation technology
    --label: string                                     #Set metadata for an image
    --load                                              #Shorthand for "--output=type=docker"
    --metadata-file: string                             #Write build result metadata to a file
    --network: string                                   #Set the networking mode for the RUN instructions during build
    --no-cache                                          #Do not use cache when building the image
    --no-cache-filter: string                           #Do not cache specified stages
    --output(-o): string                                #Output destination
    --platform: string                                  #Set target platform for build
    --policy: string                                    #Policy configuration
    --progress: string                                  #Set type of progress output
    --provenance: string                                #Shorthand for "--attest=type=provenance"
    --pull                                              #Always attempt to pull all referenced images
    --push                                              #Shorthand for "--output=type=registry"
    --quiet(-q)                                         #Suppress the build output and print image ID on success
    --sbom: string                                      #Shorthand for "--attest=type=sbom"
    --secret: string                                    #Secret to expose to the build
    --shm-size: int                                     #Shared memory size for build containers
    --ssh: string                                       #SSH agent socket or keys to expose to the build
    --tag(-t): string                                   #Image identifier
    --target: string                                    #Set the target build stage to build
    --ulimit: string                                    #Ulimit options
]

# Show the history of an image
export extern "docker history" [
    image?: string@"nu-complete docker images"
    --format: string                                    #Pretty-print images using a Go template
    --human(-H)                                         #Print sizes and dates in human readable format
    --no-trunc                                          #Don't truncate output
    --platform: string                                  #Show history for the given platform
    --quiet(-q)                                         #Only show numeric IDs
]

# Import the contents from a tarball as a filesystem image
export extern "docker import" [
    file?: string                                       #Source tarball file or URL
    repository?: string                                 #Target repository[:tag]
    --change(-c): string                                #Apply Dockerfile instruction to the created image
    --message(-m): string                               #Set commit message for imported image
    --platform: string                                  #Set platform if server is multi-platform capable
]

# Load an image from a tar archive or STDIN
export extern "docker load" [
    --input(-i): string                                 #Read from tar archive file, instead of STDIN
    --platform: string                                  #Load only the given platform(s)
    --quiet(-q)                                         #Suppress the load output
]

# Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
export extern "docker tag" [
    source?: string@"nu-complete docker images"
    target?: string@"nu-complete docker images"
]

# List images
export extern "docker images" [
    --all(-a)                                           #Show all images (default hides intermediate images)
    --digests                                           #Show digests
    --filter: string                                    #Filter output based on conditions provided
    --format: string                                    #Pretty-print images using a Go template
    --no-trunc                                          #Don't truncate output
    --quiet(-q)                                         #Only show numeric IDs
    --tree                                              #List multi-platform images as a tree (EXPERIMENTAL)
]

# Remove one or more images
export extern "docker rmi" [
    ...image: string@"nu-complete docker images"
    --force(-f)                                         #Force removal of the image
    --no-prune                                          #Do not delete untagged parents
    --platform: string                                  #Remove only the given platform variant
]

# Download an image from a registry
export extern "docker pull" [
    image?: string@"nu-complete docker images"
    --all-tags(-a)                                      #Download all tagged images in the repository
    --disable-content-trust                             #Skip image verification (default true)
    --platform: string                                  #Set platform if server is multi-platform capable
    --quiet(-q)                                         #Suppress verbose output
]

# Upload an image to a registry
export extern "docker push" [
    image?: string@"nu-complete docker images"
    --all-tags(-a)                                      #Push all tags of the specified image
    --disable-content-trust                             #Skip image verification (default true)
    --platform: string                                  #Push a platform-specific manifest as a single-platform image
    --quiet(-q)                                         #Suppress verbose output
]

# Save one or more images to a tar archive (streamed to STDOUT by default)
export extern "docker save" [
    image?: string@"nu-complete docker images"
    --output(-o): string                                #Write to a file, instead of STDOUT
    --platform: string                                  #Save only the given platform(s)
]
