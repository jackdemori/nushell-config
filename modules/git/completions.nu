# nu-version: 0.102.0

module git-completion-utils {
  export const GIT_SKIPABLE_FLAGS = ['--version', '-h', '--help', '--paginate', '--no-pager', '--no-replace-objects', '--bare']

  # Helper function to append token if non-empty
  def append-non-empty [token: string]: list<string> -> list<string> {
    if ($token | is-empty) { $in } else { $in | append $token }
  }

  # Split a string to list of args, taking quotes into account.
  # Code is copied and modified from https://github.com/nushell/nushell/issues/14582#issuecomment-2542596272
  export def args-split []: string -> list<string> {
    # Define our states
    const STATE_NORMAL = 0
    const STATE_IN_SINGLE_QUOTE = 1
    const STATE_IN_DOUBLE_QUOTE = 2
    const STATE_ESCAPE = 3
    const WHITESPACES = [" " "\t" "\n" "\r"]

    # Initialize variables
    mut state = $STATE_NORMAL
    mut current_token = ""
    mut result: list<string> = []
    mut prev_state = $STATE_NORMAL

    # Process each character
    for char in ($in | split chars) {
      if $state == $STATE_ESCAPE {
        # Handle escaped character
        $current_token = $current_token + $char
        $state = $prev_state
      } else if $char == '\' {
        # Enter escape state
        $prev_state = $state
        $state = $STATE_ESCAPE
      } else if $state == $STATE_NORMAL {
        if $char == "'" {
          $state = $STATE_IN_SINGLE_QUOTE
        } else if $char == '"' {
          $state = $STATE_IN_DOUBLE_QUOTE
        } else if ($char in $WHITESPACES) {
          # Whitespace in normal state means token boundary
          $result = $result | append-non-empty $current_token
          $current_token = ""
        } else {
          $current_token = $current_token + $char
        }
      } else if $state == $STATE_IN_SINGLE_QUOTE {
        if $char == "'" {
          $state = $STATE_NORMAL
        } else {
          $current_token = $current_token + $char
        }
      } else if $state == $STATE_IN_DOUBLE_QUOTE {
        if $char == '"' {
          $state = $STATE_NORMAL
        } else {
          $current_token = $current_token + $char
        }
      }
    }
    # Handle the last token
    $result = $result | append-non-empty $current_token
    # Return the result
    $result
  }

  # Get changed files which can be restored by `git checkout --`
  export def get-changed-files []: nothing -> list<string> {
    ^git status -uno --porcelain=2 | lines
    | where $it =~ '^1 [.MD]{2}'
    | each { split row ' ' -n 9 | last }
  }

  # Get files which can be retrieved from a branch/commit by `git checkout <tree-ish>`
  export def get-checkoutable-files []: nothing -> list<string> {
    # Relevant statuses are .M", "MM", "MD", ".D", "UU"
    ^git status -uno --porcelain=2 | lines
    | where $it =~ '^1 ([.MD]{2}|UU)'
    | each { split row ' ' -n 9 | last }
  }

  export def get-all-git-local-refs []: nothing -> list<record<ref: string, obj: string, upstream: string, subject: string>> {
    ^git for-each-ref --format '%(refname:lstrip=2)%09%(objectname:short)%09%(upstream:remotename)%(upstream:track)%09%(contents:subject)' refs/heads | lines | parse "{ref}\t{obj}\t{upstream}\t{subject}"
  }

  export def get-all-git-remote-refs []: nothing -> list<record<ref: string, obj: string, subject: string>> {
    ^git for-each-ref --format '%(refname:lstrip=2)%09%(objectname:short)%09%(contents:subject)' refs/remotes | lines | parse "{ref}\t{obj}\t{subject}"
  }

  # Get local branches, remote branches which can be passed to `git merge`
  export def get-mergable-sources []: nothing -> list<record<value: string, description: string>> {
    let local = get-all-git-local-refs | each {|x| {value: $x.ref description: $'Branch, Local, ($x.obj) ($x.subject), (if ($x.upstream | is-not-empty) { $x.upstream } else { "no upstream" } )'} } | insert style 'light_blue'
    let remote = get-all-git-remote-refs | each {|x| {value: $x.ref description: $'Branch, Remote, ($x.obj) ($x.subject)'} } | insert style 'blue_italic'
    $local | append $remote
  }
}

def "nu-complete git available upstream" [] {
  ^git for-each-ref --format '%(refname:short)' refs/heads refs/remotes | lines
}

def "nu-complete git remotes" [] {
  ^git remote --verbose
  | parse --regex '(?<value>\S+)\s+(?<description>\S+)'
  | uniq-by value # Deduplicate where fetch and push remotes are the same
}

def "nu-complete git log" [] {
  ^git log --pretty=%h | lines | each { |line| $line | str trim }
}

# Yield all existing commits in descending chronological order.
def "nu-complete git commits all" [] {
  ^git rev-list --all --remotes --pretty=oneline | lines | parse "{value} {description}"
}

# Yield commits of current branch only. This is useful for e.g. cut points in
# `git rebase`.
def "nu-complete git commits current branch" [] {
  ^git log --pretty="%h %s" | lines | parse "{value} {description}"
}

# Yield local branches like `main`, `feature/typo_fix`
def "nu-complete git local branches" [] {
  ^git for-each-ref --format '%(refname:short)' refs/heads | lines
}

# Yield remote branches like `origin/main`, `upstream/feature-a`
def "nu-complete git remote branches with prefix" [] {
  ^git for-each-ref --format='%(refname:lstrip=2)' refs/remotes | lines
}

# Yield local and remote branch names which can be passed to `git merge`
def "nu-complete git mergable sources" [] {
  use git-completion-utils *
  let branches = get-mergable-sources
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: $branches
  }
}

def "nu-complete git switch" [] {
  use git-completion-utils *
  let branches = get-mergable-sources
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: $branches
  }
}

def "nu-complete git checkout" [context: string, position?:int] {
  use git-completion-utils *
  let preceding = $context | str substring ..$position
  # See what user typed before, like 'git checkout a-branch a-path'.
  # We exclude some flags from previous tokens, to detect if  a branch name has been used as the first argument.
  # FIXME: This method is still naive, though.
  let prev_tokens = $preceding | str trim | args-split | where ($it not-in $GIT_SKIPABLE_FLAGS)
  # In these scenarios, we suggest only file paths, not branch:
  # - After '--'
  # - First arg is a branch
  # If before '--' is just 'git checkout' (or its alias), we suggest "dirty" files only (user is about to reset file).
  if $prev_tokens.2? == '--' {
    return (get-changed-files)
  }
  if '--' in $prev_tokens {
    return (get-checkoutable-files)
  }
  # Already typed first argument.
  if ($prev_tokens | length) > 2 and $preceding ends-with ' ' {
    # If we are creating a new branch, we may want to specify a start point
    if ("-b" not-in $prev_tokens) and ("-B" not-in $prev_tokens) and ("--orphan" not-in $prev_tokens) {
      return (get-checkoutable-files)
    }
  }
  # The first argument can be local branches, remote branches, files and commits
  # Get local and remote branches
  let branches = get-mergable-sources
  let files = (get-checkoutable-files) | wrap value | insert description 'File' | insert style green
  let commits = ^git rev-list -n 400 --remotes --oneline | lines | split column -n 2 ' ' value description | upsert description {|x| $'Commit, ($x.value) ($x.description)' } | insert style 'light_cyan_dimmed'
  {
    options: {
        case_sensitive: false,
        completion_algorithm: prefix,
        sort: false,
    },
    completions: [...$branches, ...$files, ...$commits]
  }
}

# Arguments to `git rebase --onto <arg1> <arg2>`
def "nu-complete git rebase" [] {
  (nu-complete git local branches)
  | parse "{value}"
  | insert description "local branch"
  | append (nu-complete git remote branches with prefix
            | parse "{value}"
            | insert description "remote branch")
  | append (nu-complete git commits all)
}

def "nu-complete git stash-list" [] {
  git stash list | lines | parse "{value}: {description}"
}

def "nu-complete git tags" [] {
  ^git tag --no-color | lines
}

# See `man git-status` under "Short Format"
# This is incomplete, but should cover the most common cases.
const short_status_descriptions = {
  ".D": "Deleted"
  ".M": "Modified"
  "!" : "Ignored"
  "?" : "Untracked"
  "AU": "Staged, not merged"
  "MD": "Some modifications staged, file deleted in work tree"
  "MM": "Some modifications staged, some modifications untracked"
  "R.": "Renamed"
  "UU": "Both modified (in merge conflict)"
}

def "nu-complete git files" [] {
  let relevant_statuses = ["?",".M", "MM", "MD", ".D", "UU"]
  ^git status -uall --porcelain=2
  | lines
  | each { |$it|
    if $it starts-with "1 " {
      $it | parse --regex "1 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "2 " {
      $it | parse --regex "2 (?P<short_status>\\S+) (?:\\S+\\s?){6} (?P<value>\\S+)"
    } else if $it starts-with "u " {
      $it | parse --regex "u (?P<short_status>\\S+) (?:\\S+\\s?){8} (?P<value>\\S+)"
    } else if $it starts-with "? " {
      $it | parse --regex "(?P<short_status>.{1}) (?P<value>.+)"
    } else {
      { short_status: 'unknown', value: $it }
    }
  }
  | flatten
  | where $it.short_status in $relevant_statuses
  | insert "description" { |e| $short_status_descriptions | get $e.short_status}
}

def "nu-complete git built-in-refs" [] {
  [HEAD FETCH_HEAD ORIG_HEAD]
}

def "nu-complete git refs" [] {
  nu-complete git local branches
  | parse "{value}"
  | insert description Branch
  | append (nu-complete git tags | parse "{value}" | insert description Tag)
  | append (nu-complete git built-in-refs)
}

def "nu-complete git files-or-refs" [] {
  nu-complete git local branches
  | parse "{value}"
  | insert description Branch
  | append (nu-complete git files | where description == "Modified" | select value)
  | append (nu-complete git tags | parse "{value}" | insert description Tag)
  | append (nu-complete git built-in-refs)
}

def "nu-complete git aliases" [] {
  ^git config --get-regexp ^alias\.
  | lines
  | parse "alias.{value} {description}"
}

def "nu-complete git subcommands" [] {
  ^git help -a | lines | where $it starts-with "   " | parse -r '\s*(?P<value>[^ ]+) \s*(?P<description>\w.*)'
  | append (nu-complete git aliases)
  | uniq-by value
}

# Static subcommand completers for git command groups — prevents nu from
# falling back to filesystem completion on parent externs (e.g. `git config `
# or `git stash `).

def "nu-complete git config subcommands" [] {
  [
    {value: "list",           description: "List all variables in the config files"}
    {value: "get",            description: "Read the value of a config variable"}
    {value: "set",            description: "Set the value of a config variable"}
    {value: "unset",          description: "Remove a config variable"}
    {value: "rename-section", description: "Rename a config section"}
    {value: "remove-section", description: "Remove a config section"}
    {value: "edit",           description: "Open the config file in $EDITOR"}
  ]
}

def "nu-complete git bisect subcommands" [] {
  [
    {value: "start",     description: "Begin a bisection session"}
    {value: "good",      description: "Mark commits as good (don't have the bug)"}
    {value: "bad",       description: "Mark commits as bad (have the bug)"}
    {value: "terms",     description: "Show or set the new/old terms used by bisect"}
    {value: "skip",      description: "Skip commits that cannot be tested"}
    {value: "next",      description: "Pick the next commit to test"}
    {value: "reset",     description: "End the bisection and return to the original HEAD"}
    {value: "visualize", description: "Show remaining candidate commits"}
    {value: "replay",    description: "Replay a bisection log file"}
    {value: "log",       description: "Print the bisection log to stdout"}
    {value: "run",       description: "Bisect by running a test script on each commit"}
  ]
}

def "nu-complete git stash subcommands" [] {
  [
    {value: "list",   description: "List stashes"}
    {value: "show",   description: "Show the changes in a stash"}
    {value: "drop",   description: "Drop a stash"}
    {value: "pop",    description: "Apply a stash and drop it"}
    {value: "apply",  description: "Apply a stash without dropping it"}
    {value: "branch", description: "Create a new branch from a stash"}
    {value: "push",   description: "Save changes to a new stash"}
    {value: "save",   description: "Save changes to a new stash (legacy form)"}
    {value: "clear",  description: "Drop all stashes"}
    {value: "create", description: "Create a stash entry without storing it in refs"}
    {value: "store",  description: "Store a stash created with `stash create`"}
  ]
}

def "nu-complete git remote subcommands" [] {
  [
    {value: "add",           description: "Add a remote named NAME for the repository at URL"}
    {value: "rename",        description: "Rename the remote OLD to NEW"}
    {value: "remove",        description: "Remove the remote NAME"}
    {value: "set-head",      description: "Set or delete the default branch for a remote"}
    {value: "show",          description: "Show information about a remote"}
    {value: "prune",          description: "Delete stale references for a remote"}
    {value: "update",        description: "Fetch updates for a named set of remotes"}
    {value: "set-branches",  description: "Change the list of tracked branches for a remote"}
    {value: "get-url",       description: "Get the URL for a remote"}
    {value: "set-url",       description: "Change URLs for a remote"}
  ]
}

def "nu-complete git worktree subcommands" [] {
  [
    {value: "add",    description: "Create a new working tree"}
    {value: "list",   description: "List details of each working tree"}
    {value: "lock",   description: "Prevent a working tree from being pruned"}
    {value: "move",   description: "Move a working tree to a new location"}
    {value: "prune",  description: "Remove working tree information for missing directories"}
    {value: "remove", description: "Remove a working tree"}
    {value: "repair", description: "Repair working tree administrative files"}
    {value: "unlock", description: "Unlock a working tree previously locked"}
  ]
}

def "nu-complete git add" [] {
  nu-complete git files
}

def "nu-complete git pull rebase" [] {
  ["false","true","merges","interactive"]
}

def "nu-complete git merge strategies" [] {
  ['ort', 'octopus']
}

def "nu-complete git merge strategy options" [] {
  ['ours', 'theirs']
}


# Check out git branches and files
export extern "git checkout" [
  ...targets: string@"nu-complete git checkout"   # name of the branch or files to checkout
  --conflict: string                              # conflict style (merge or diff3)
  --detach(-d)                                    # detach HEAD at named commit
  --force(-f)                                     # force checkout (throw away local modifications)
  --guess                                         # second guess 'git checkout <no-such-branch>' (default)
  --ignore-other-worktrees                        # do not check if another worktree is holding the given ref
  --ignore-skip-worktree-bits                     # do not limit pathspecs to sparse entries only
  --merge(-m)                                     # perform a 3-way merge with the new branch
  --orphan: string                                # new unparented branch
  --ours(-2)                                      # checkout our version for unmerged files
  --overlay                                       # use overlay mode (default)
  --overwrite-ignore                              # update ignored files (default)
  --patch(-p)                                     # select hunks interactively
  --pathspec-from-file: string                    # read pathspec from file
  --pathspec-file-nul                             # pathspec elements separated with NUL character
  --progress                                      # force progress reporting
  --quiet(-q)                                     # suppress progress reporting
  --recurse-submodules                            # control recursive updating of submodules
  --theirs(-3)                                    # checkout their version for unmerged files
  --track(-t)                                     # set upstream info for new branch
  -b                                              # create and checkout a new branch
  -B: string                                      # create/reset and checkout a branch
  -l                                              # create reflog for new branch
]

export extern "git reset" [
  ...targets: string@"nu-complete git checkout"      # name of commit, branch, or files to reset to
  --hard                                          # reset HEAD, index and working tree
  --keep                                          # reset HEAD but keep local changes
  --merge                                         # reset HEAD, index and working tree
  --mixed                                         # reset HEAD and index
  --patch(-p)                                     # select hunks interactively
  --quiet(-q)                                     # be quiet, only report errors
  --soft                                          # reset only HEAD
  --pathspec-from-file: string                    # read pathspec from file
  --pathspec-file-nul                             # with --pathspec-from-file, pathspec elements are separated with NUL character
  --no-refresh                                    # skip refreshing the index after reset
  --refresh                                       # opposite of --no-refresh
  --recurse-submodules                            # control recursive updating of submodules (optional `=<reset>`)
  --no-recurse-submodules                         # don't recurse into submodules
  --intent-to-add(-N)                             # record only the fact that removed paths will be added later
]

# Download objects and refs from another repository
export extern "git fetch" [
  repository?: string@"nu-complete git remotes" # name of the branch to fetch
  --all                                         # Fetch all remotes
  --append(-a)                                  # Append ref names and object names to .git/FETCH_HEAD
  --atomic                                      # Use an atomic transaction to update local refs.
  --depth: int                                  # Limit fetching to n commits from the tip
  --deepen: int                                 # Limit fetching to n commits from the current shallow boundary
  --shallow-since: string                       # Deepen or shorten the history by date
  --shallow-exclude: string                     # Deepen or shorten the history by branch/tag
  --unshallow                                   # Fetch all available history
  --update-shallow                              # Update .git/shallow to accept new refs
  --negotiation-tip: string                     # Specify which commit/glob to report while fetching
  --negotiate-only                              # Do not fetch, only print common ancestors
  --dry-run                                     # Show what would be done
  --write-fetch-head                            # Write fetched refs in FETCH_HEAD (default)
  --no-write-fetch-head                         # Do not write FETCH_HEAD
  --force(-f)                                   # Always update the local branch
  --keep(-k)                                    # Keep downloaded pack
  --multiple                                    # Allow several arguments to be specified
  --auto-maintenance                            # Run 'git maintenance run --auto' at the end (default)
  --no-auto-maintenance                         # Don't run 'git maintenance' at the end
  --auto-gc                                     # Run 'git maintenance run --auto' at the end (default)
  --no-auto-gc                                  # Don't run 'git maintenance' at the end
  --write-commit-graph                          # Write a commit-graph after fetching
  --no-write-commit-graph                       # Don't write a commit-graph after fetching
  --prefetch                                    # Place all refs into the refs/prefetch/ namespace
  --prune(-p)                                   # Remove obsolete remote-tracking references
  --prune-tags(-P)                              # Remove any local tags that do not exist on the remote
  --no-tags(-n)                                 # Disable automatic tag following
  --refmap: string                              # Use this refspec to map the refs to remote-tracking branches
  --tags(-t)                                    # Fetch all tags
  --recurse-submodules                          # Fetch new commits of populated submodules (optional `=<on-demand>`)
  --jobs(-j): int                               # Number of parallel children
  --no-recurse-submodules                       # Disable recursive fetching of submodules
  --set-upstream                                # Add upstream (tracking) reference
  --submodule-prefix: string                    # Prepend to paths printed in informative messages
  --upload-pack: string                         # Non-default path for remote command
  --quiet(-q)                                   # Silence internally used git commands
  --verbose(-v)                                 # Be verbose
  --progress                                    # Report progress on stderr
  --server-option(-o): string                   # Pass options for the server to handle
  --show-forced-updates                         # Check if a branch is force-updated
  --no-show-forced-updates                      # Don't check if a branch is force-updated
  -4                                            # Use IPv4 addresses, ignore IPv6 addresses
  -6                                            # Use IPv6 addresses, ignore IPv4 addresses
  --porcelain                                   # machine-readable output
  --update-head-ok(-u)                          # allow updating of HEAD ref
  --refetch                                     # re-fetch without negotiating common commits
  --filter: string                              # object filtering
  --stdin                                       # accept refspecs from stdin
]

# Yield local branches and (if remote is specified) remote branches with colon prefix
def "nu-complete git push" [context: string, position: int] {
  use git-completion-utils *
  let preceding = $context | str substring ..$position
  let tokens = $preceding | str trim | args-split | where ($it not-in $GIT_SKIPABLE_FLAGS)

  # Check if we have a remote argument (2nd token, 1st is 'git', 2nd is 'push', 3rd is remote)
  # BUT, args-split might be different depending on how it's called.
  # "git push origin" -> ["git", "push", "origin"]
  # If we have at least 3 tokens, the 3rd one IS likely the remote.
  # We should double check if the 3rd token is actually a remote.
  
  mut remote = ""
  if ($tokens | length) >= 3 {
    $remote = $tokens.2
  }

  let local_branches = (nu-complete git local branches)
  
  if ($remote | is-empty) {
    return $local_branches
  }

  # If we have a remote, find branches for that remote
  # Use plumbing command to get remote branches, excluding HEAD
  let remote_branches = (^git for-each-ref --format='%(refname:lstrip=3)' $'refs/remotes/($remote)' | lines | where $it != 'HEAD')
  
  # Prefix them with :
  let deletion_candidates = ($remote_branches | each { |it| $":($it)" })

  $local_branches | append $deletion_candidates
}

# Push changes
export extern "git push" [
  remote?: string@"nu-complete git remotes",         # the name of the remote
  ...refs: string@"nu-complete git push"             # the branch / refspec
  --all                                              # push all refs
  --atomic                                           # request atomic transaction on remote side
  --delete(-d)                                       # delete refs
  --dry-run(-n)                                      # dry run
  --exec: string                                     # receive pack program
  --follow-tags                                      # push missing but relevant tags
  --force-with-lease                                 # require old value of ref to be at this value
  --force(-f)                                        # force updates
  --ipv4(-4)                                         # use IPv4 addresses only
  --ipv6(-6)                                         # use IPv6 addresses only
  --mirror                                           # mirror all refs
  --no-verify                                        # bypass pre-push hook
  --porcelain                                        # machine-readable output
  --progress                                         # force progress reporting
  --prune                                            # prune locally removed refs
  --push-option(-o): string                          # option to transmit
  --quiet(-q)                                        # be more quiet
  --receive-pack: string                             # receive pack program
  --recurse-submodules: string                       # control recursive pushing of submodules
  --repo: string                                     # repository
  --set-upstream(-u)                                 # set upstream for git pull/status
  --signed                                           # GPG sign the push (optional `=<yes|no|if-asked>`)
  --tags                                             # push tags (can't be used with --all or --mirror)
  --thin                                             # use thin pack
  --verbose(-v)                                      # be more verbose
  --branches                                         # alias of --all
  --force-if-includes                                # require remote updates to be integrated locally
  --verify                                           # opposite of --no-verify
]

# Pull changes
export extern "git pull" [
  remote?: string@"nu-complete git remotes",         # the name of the remote
  ...refs: string@"nu-complete git local branches",  # the branch / refspec
  --rebase(-r)                                       # rebase current branch on top of upstream after fetching (optional `=<false|true|merges|interactive>`)
  --quiet(-q)                                        # suppress output during transfer and merge
  --verbose(-v)                                      # be more verbose
  --commit                                           # perform the merge and commit the result
  --no-commit                                        # perform the merge but do not commit the result
  --edit(-e)                                         # edit the merge commit message
  --no-edit                                          # use the auto-generated merge commit message
  --cleanup: string                                  # specify how to clean up the merge commit message
  --ff                                               # fast-forward if possible
  --no-ff                                            # create a merge commit in all cases
  --gpg-sign(-S)                                     # GPG-sign the resulting merge commit
  --no-gpg-sign                                      # do not GPG-sign the resulting merge commit
  --log                                              # include log messages from merged commits (optional `=<n>`)
  --no-log                                           # do not include log messages from merged commits
  --signoff                                          # add Signed-off-by trailer
  --no-signoff                                       # do not add Signed-off-by trailer
  --stat(-n)                                         # show a diffstat at the end of the merge
  --no-stat                                          # do not show a diffstat at the end of the merge
  --squash                                           # produce working tree and index state as if a merge happened
  --no-squash                                        # perform the merge and commit the result
  --verify                                           # run pre-merge and commit-msg hooks
  --no-verify                                        # do not run pre-merge and commit-msg hooks
  --strategy(-s): string                             # use the given merge strategy
  --strategy-option(-X): string                      # pass merge strategy-specific option
  --verify-signatures                                # verify the tip commit of the side branch being merged
  --no-verify-signatures                             # do not verify the tip commit of the side branch being merged
  --summary                                          # show a summary of the merge
  --no-summary                                       # do not show a summary of the merge
  --autostash                                        # create a temporary stash entry before the operation
  --no-autostash                                     # do not create a temporary stash entry before the operation
  --allow-unrelated-histories                        # allow merging histories without a common ancestor
  --no-rebase                                        # do not rebase the current branch on top of the upstream branch
  --all                                              # fetch all remotes
  --append(-a)                                       # append fetched refs to existing contents of FETCH_HEAD
  --atomic                                           # use an atomic transaction to update local refs
  --depth: int                                       # limit fetching to the specified number of commits
  --deepen: int                                      # deepen the history by the specified number of commits
  --shallow-since: string                            # deepen or shorten the history since a specified date
  --shallow-exclude: string                          # exclude commits reachable from a specified branch or tag
  --unshallow                                        # convert a shallow repository to a complete one
  --update-shallow                                   # update .git/shallow with new refs
  --tags(-t)                                         # fetch all tags from the remote
  --jobs(-j)                                         # number of parallel children for fetching (optional `=<n>`)
  --set-upstream                                     # add upstream (tracking) reference
  --upload-pack: string                              # specify non-default path for upload-pack on the remote
  --progress                                         # force progress status even if stderr is not a terminal
  --server-option(-o): string                        # transmit the given string to the server
  --recurse-submodules                               # control for recursive fetching of submodules (optional `=<on-demand>`)
  --ff-only                                          # abort if fast-forward is not possible
  --force(-f)                                        # force overwrite of local branch
  --prune(-p)                                        # prune remote-tracking branches no longer on remote
  --dry-run                                          # dry run
  --keep(-k)                                         # keep downloaded pack
  --refmap: string                                   # specify fetch refmap
  --ipv4(-4)                                         # use IPv4 addresses only
  --ipv6(-6)                                         # use IPv6 addresses only
  --negotiation-tip: string                          # report only objects reachable from this object
  --show-forced-updates                              # check for forced-updates on all updated branches
]

# Switch between branches and commits
export extern "git switch" [
  switch?: string@"nu-complete git switch"        # name of branch to switch to
  start_point?: string@"nu-complete git rebase"   # name of the start point
  --create(-c)                                    # create a new branch
  --detach(-d): string@"nu-complete git log"      # switch to a commit in a detached state
  --force-create(-C): string                      # forces creation of new branch, if it exists then the existing branch will be reset to starting point
  --force(-f)                                     # alias for --discard-changes
  --guess                                         # if there is no local branch which matches then name but there is a remote one then this is checked out
  --ignore-other-worktrees                        # switch even if the ref is held by another worktree
  --merge(-m)                                     # attempts to merge changes when switching branches if there are local changes
  --no-guess                                      # do not attempt to match remote branch names
  --no-progress                                   # do not report progress
  --no-recurse-submodules                         # do not update the contents of sub-modules
  --no-track                                      # do not set "upstream" configuration
  --orphan: string                                # create a new orphaned branch
  --progress                                      # report progress status
  --quiet(-q)                                     # suppress feedback messages
  --recurse-submodules                            # update the contents of sub-modules
  --track(-t)                                     # set "upstream" configuration
  --discard-changes                               # throw away local modifications
  --conflict: string                              # conflict style (merge, diff3, or zdiff3)
  --overwrite-ignore                              # update ignored files (default)
]

# Apply the change introduced by an existing commit
export extern "git cherry-pick" [
  commit?: string@"nu-complete git commits all" # The commit ID to be cherry-picked
  --edit(-e)                                    # Edit the commit message prior to committing
  --no-commit(-n)                               # Apply changes without making any commit
  --signoff(-s)                                 # Add Signed-off-by line to the commit message
  --ff                                          # Fast-forward if possible
  --continue                                    # Continue the operation in progress
  --abort                                       # Cancel the operation
  --skip                                        # Skip the current commit and continue with the rest of the sequence
  --quit                                        # end revert or cherry-pick sequence
  --cleanup: string                             # how to strip spaces and #comments from message
  --commit                                      # opposite of --no-commit
  --mainline(-m): int                           # select mainline parent
  --rerere-autoupdate                           # update the index with reused conflict resolution if possible
  --strategy: string                            # merge strategy
  --strategy-option(-X): string                 # option for merge strategy
  --gpg-sign(-S)                                # GPG sign commit
  -x                                            # append commit name
  --allow-empty                                 # preserve initially empty commits
  --allow-empty-message                         # allow commits with empty messages
  --keep-redundant-commits                      # deprecated: use --empty=keep instead
  --empty: string                               # how to handle commits that become empty
]

# Rebase the current branch
export extern "git rebase" [
  branch?: string@"nu-complete git rebase"    # name of the branch to rebase onto
  upstream?: string@"nu-complete git rebase"  # upstream branch to compare against
  --continue                                  # restart rebasing process after editing/resolving a conflict
  --abort                                     # abort rebase and reset HEAD to original branch
  --quit                                      # abort rebase but do not reset HEAD
  --interactive(-i)                           # rebase interactively with list of commits in editor
  --onto: string@"nu-complete git rebase"     # starting point at which to create the new commits
  --root                                      # start rebase from root commit
  --keep-base                                 # use the merge-base of upstream and branch as the current base
  --no-verify                                 # allow pre-rebase hook to run
  --verify                                    # opposite of --no-verify
  --quiet(-q)                                 # be quiet, implies --no-stat
  --verbose(-v)                               # display a diffstat of what changed upstream
  --no-stat(-n)                               # do not show diffstat of what changed upstream
  --stat                                      # opposite of --no-stat
  --signoff                                   # add a Signed-off-by trailer to each commit
  --committer-date-is-author-date             # make committer date match author date
  --reset-author-date                         # ignore author date and use current date
  -C: int                                     # passed to 'git apply'
  --ignore-whitespace                         # ignore changes in whitespace
  --whitespace: string                        # passed to 'git apply'
  --force-rebase(-f)                          # cherry-pick all commits, even if unchanged
  --no-ff                                     # cherry-pick all commits, even if unchanged
  --ff                                        # opposite of --no-ff
  --skip                                      # skip current patch and continue
  --edit-todo                                 # edit the todo list during an interactive rebase
  --show-current-patch                        # show the patch file being applied or merged
  --apply                                     # use apply strategies to rebase
  --merge(-m)                                 # use merging strategies to rebase
  --rerere-autoupdate                         # update the index with reused conflict resolution if possible
  --empty: string                             # how to handle commits that become empty
  --autosquash                                # move commits that begin with squash!/fixup! under -i
  --update-refs                               # update branches that point to commits that are being rebased
  --gpg-sign(-S)                              # GPG-sign commits
  --autostash                                 # automatically stash/stash pop before and after
  --exec(-x): string                          # add exec lines after each commit of the editable list
  --rebase-merges(-r)                         # try to rebase merges instead of skipping them (optional `=<mode>`)
  --fork-point                                # use 'merge-base --fork-point' to refine upstream
  --strategy(-s): string                      # use the given merge strategy
  --strategy-option(-X): string               # pass the argument through to the merge strategy
  --reschedule-failed-exec                    # automatically re-schedule any exec that fails
  --reapply-cherry-picks                      # apply all changes, even those already present upstream
]

# Merge from a branch
export extern "git merge" [
  # For now, to make it simple, we only complete branches (not commits) and support single-parent case.
  branch?: string@"nu-complete git mergable sources"         # The source branch
  --edit(-e)                                                 # Edit the commit message prior to committing
  --no-edit                                                  # Do not edit commit message
  --no-commit(-n)                                            # Apply changes without making any commit
  --signoff                                                  # Add Signed-off-by line to the commit message
  --ff                                                       # Fast-forward if possible
  --continue                                                 # Continue after resolving a conflict
  --abort                                                    # Abort resolving conflict and go back to original state
  --quit                                                     # Forget about the current merge in progress
  --strategy(-s): string@"nu-complete git merge strategies"  # Merge strategy
  -X: string@"nu-complete git merge strategy options"        # Option for merge strategy
  --verbose(-v)
  --help
  --stat                                                     # show a diffstat at the end of the merge
  --summary                                                  # synonym to --stat
  --log                                                      # add entries from shortlog to merge commit message (optional `=<n>`)
  --squash                                                   # create a single commit instead of doing a merge
  --cleanup: string                                          # how to strip spaces and #comments from message
  --ff-only                                                  # abort if fast-forward is not possible
  --rerere-autoupdate                                        # update the index with reused conflict resolution if possible
  --verify-signatures                                        # verify that the named commit has a valid GPG signature
  --message(-m): string                                      # merge commit message (for a non-fast-forward merge)
  --file(-F): path                                           # read message from file
  --into-name: string                                        # use <name> instead of the real target
  --quiet(-q)                                                # be more quiet
  --allow-unrelated-histories                                # allow merging unrelated histories
  --progress                                                 # force progress reporting
  --gpg-sign(-S)                                             # GPG sign commit
  --autostash                                                # automatically stash/stash pop before and after
  --overwrite-ignore                                         # update ignored files (default)
  --no-verify                                                # bypass pre-merge-commit and commit-msg hooks
  --verify                                                   # opposite of --no-verify
]

# List or change branches
export extern "git branch" [
  ...branch: string@"nu-complete git local branches"             # name of branch (or branches) to operate on
  --abbrev                                                       # use short commit hash prefixes
  --edit-description                                             # open editor to edit branch description
  --merged                                                       # list reachable branches
  --no-merged                                                    # list unreachable branches
  --set-upstream-to: string@"nu-complete git available upstream" # set upstream for branch
  --unset-upstream                                               # remote upstream for branch
  --all                                                          # list both remote and local branches
  --copy                                                         # copy branch together with config and reflog
  --format                                                       # specify format for listing branches
  --move                                                         # rename branch
  --points-at                                                    # list branches that point at an object
  --show-current                                                 # print the name of the current branch
  --verbose                                                      # show commit and upstream for each branch
  --color                                                        # use color in output
  --quiet                                                        # suppress messages except errors
  --delete(-d)                                                   # delete branch
  -D                                                             # force delete branch
  --list                                                         # list branches
  --contains: string@"nu-complete git commits all"               # show only branches that contain the specified commit
  --no-contains                                                  # show only branches that don't contain specified commit
  --track(-t)                                                    # when creating a branch, set upstream
  --remotes(-r)                                                  # act on remote-tracking branches
  -M                                                             # move/rename a branch, even if target exists
  --omit-empty                                                   # do not output a newline after empty formatted refs
  -C                                                             # copy a branch, even if target exists
  --create-reflog                                                # create the branch's reflog
  --force(-f)                                                    # force creation, move/rename, deletion
  --column                                                       # list branches in columns
  --sort: string                                                 # field name to sort on
  --ignore-case(-i)                                              # sorting and filtering are case insensitive
  --recurse-submodules                                           # recurse through submodules
]

# Get and set repository or global options
export extern "git config" [
  subcommand?: string@"nu-complete git config subcommands" # Config subcommand
]

# List all variables set in config file, along with their values.
export extern "git config list" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
  --null(-z)                                          # terminate values with NUL byte
  --name-only                                         # show variable names only
  --show-origin                                       # show origin of config
  --show-scope                                        # show scope of config
  --show-names                                        # show config keys in addition to their values
  --type(-t): string                                  # value is given this type
  --bool                                              # value is "true" or "false"
  --int                                               # value is decimal number
  --bool-or-int                                       # value is --bool or --int
  --bool-or-str                                       # value is --bool or string
  --path                                              # value is a path (file or directory name)
  --expiry-date                                       # value is an expiry date
  --includes                                          # respect include directives on lookup
]

# Emits the value of the specified key.
export extern "git config get" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
  --all                                               # return all values for multi-valued config options
  --regexp                                            # interpret the name as a regular expression
  --value: string                                     # show config with values matching the pattern
  --fixed-value                                       # use string equality when comparing values to value pattern
  --url: string                                       # show config matching the given URL
  --null(-z)                                          # terminate values with NUL byte
  --name-only                                         # show variable names only
  --show-origin                                       # show origin of config
  --show-scope                                        # show scope of config
  --show-names                                        # show config keys in addition to their values
  --type(-t): string                                  # value is given this type
  --bool                                              # value is "true" or "false"
  --int                                               # value is decimal number
  --bool-or-int                                       # value is --bool or --int
  --bool-or-str                                       # value is --bool or string
  --path                                              # value is a path (file or directory name)
  --expiry-date                                       # value is an expiry date
  --includes                                          # respect include directives on lookup
  --default: string                                   # use default value when missing entry
]

# Set value for one or more config options.
export extern "git config set" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
  --type(-t): string                                  # value is given this type
  --bool                                              # value is "true" or "false"
  --int                                               # value is decimal number
  --bool-or-int                                       # value is --bool or --int
  --bool-or-str                                       # value is --bool or string
  --path                                              # value is a path (file or directory name)
  --expiry-date                                       # value is an expiry date
  --all                                               # replace multi-valued config option with new value
  --value: string                                     # show config with values matching the pattern
  --fixed-value                                       # use string equality when comparing values to value pattern
  --comment: string                                   # human-readable comment string
  --append                                            # add a new line without altering any existing values
]

# Unset value for one or more config options.
export extern "git config unset" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
  --all                                               # replace multi-valued config option with new value
  --value: string                                     # show config with values matching the pattern
  --fixed-value                                       # use string equality when comparing values to value pattern
]

# Rename the given section to a new name.
export extern "git config rename-section" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
]

# Remove the given section from the configuration file.
export extern "git config remove-section" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
]

# Opens an editor to modify the specified config file
export extern "git config edit" [
  --global                                            # use global config file
  --system                                            # use system config file
  --local                                             # use repository config file
  --worktree                                          # use per-worktree config file
  --file(-f): path                                    # use given config file
  --blob: string                                      # read config from given blob object
]

# List or change tracked repositories
export extern "git remote" [
  subcommand?: string@"nu-complete git remote subcommands" # Remote subcommand
  --verbose(-v)                            # Show URL for remotes
]

# Add a new tracked repository
export extern "git remote add" [
  --fetch(-f)                                          # fetch the remote branches
  --tags                                               # import all tags and associated objects when fetching
  --track(-t): string                                  # branch(es) to track
  --master(-m): string                                 # master branch
  --mirror                                             # set up remote as a mirror to push to or fetch from (optional `=<push|fetch>`)
]

# Rename a tracked repository
export extern "git remote rename" [
  remote: string@"nu-complete git remotes"             # remote to rename
  new_name: string                                     # new name for remote
  --progress                                           # force progress reporting
]

# Remove a tracked repository
export extern "git remote remove" [
  remote: string@"nu-complete git remotes"             # remote to remove
]

# Get the URL for a tracked repository
export extern "git remote get-url" [
  remote: string@"nu-complete git remotes"             # remote to get URL for
  --push                                               # query push URLs rather than fetch URLs
  --all                                                # return all URLs
]

# Set the URL for a tracked repository
export extern "git remote set-url" [
  remote: string@"nu-complete git remotes"             # remote to set URL for
  url: string                                          # new URL for remote
  --push                                               # manipulate push URLs
  --add                                                # add new URL instead of replacing
  --delete                                             # delete URLs matching the regex
]

# Set or delete the default branch for a remote
export extern "git remote set-head" [
  name: string@"nu-complete git remotes"               # remote name
  branch?: string                                      # branch to set as HEAD
  --auto(-a)                                           # query the remote for its HEAD
  --delete(-d)                                         # delete the symbolic-ref HEAD
]

# Delete stale references for a remote
export extern "git remote prune" [
  name: string@"nu-complete git remotes"               # remote to prune
  --dry-run(-n)                                        # show what would be pruned
]

# Change the list of tracked branches for a remote
export extern "git remote set-branches" [
  name: string@"nu-complete git remotes"               # remote to operate on
  ...branches: string                                  # branches to track
  --add                                                # add to the existing tracked branches
]

# Show changes between commits, working tree etc
export extern "git diff" [
  rev1_or_file?: string@"nu-complete git files-or-refs"
  rev2?: string@"nu-complete git refs"
  --cached                                             # show staged changes
  --name-only                                          # only show names of changed files
  --name-status                                        # show changed files and kind of change
  --no-color                                           # disable color output
  -z                                                   # output diff-raw with lines terminated with NUL
  -p                                                   # output patch format
  -u                                                   # synonym for -p
  --patch-with-raw                                     # output both a patch and the diff-raw format
  --stat                                               # show diffstat instead of patch
  --numstat                                            # show numeric diffstat instead of patch
  --patch-with-stat                                    # output a patch and prepend its diffstat
  --full-index                                         # show full object name on index lines
  --abbrev                                             # abbreviate object names in diff-tree header and diff-raw (optional `=<n>`)
  -R                                                   # swap input file pairs
  -B                                                   # detect complete rewrites
  -M                                                   # detect renames
  -C                                                   # detect copies
  --find-copies-harder                                 # try unchanged files as candidate for copy detection
  -l: int                                              # limit rename attempts up to <n> paths
  -O: path                                             # reorder diffs according to the <file>
  -S: string                                           # find filepair whose only one side contains the string
  --pickaxe-all                                        # show all files diff when -S is used and hit is found
  -a                                                   # treat all files as text
]

# Commit changes
export extern "git commit" [
  --all(-a)                                           # automatically stage all modified and deleted files
  --amend                                             # amend the previous commit rather than adding a new one
  --message(-m): string                               # specify the commit message rather than opening an editor
  --reuse-message(-C): string                         # reuse the message from a previous commit
  --reedit-message(-c): string                        # reuse and edit message from a commit
  --fixup: string                                     # create a fixup/amend commit
  --squash: string                                    # squash commit for autosquash rebase
  --reset-author                                      # reset author information
  --short                                             # short-format output for dry-run
  --branch                                            # show branch info in short-format
  --porcelain                                         # porcelain-ready format for dry-run
  --long                                              # long-format output for dry-run
  --null(-z)                                          # use NUL instead of LF in output
  --file(-F): string                                  # read commit message from file
  --author: string                                    # override commit author
  --date: string                                      # override author date
  --template(-t): string                              # use commit message template file
  --signoff(-s)                                       # add Signed-off-by trailer
  --no-signoff                                        # do not add Signed-off-by trailer
  --trailer: string                                   # add trailer to commit message
  --no-verify(-n)                                     # bypass pre-commit and commit-msg hooks
  --verify                                            # do not bypass pre-commit and commit-msg hooks
  --allow-empty                                       # allow commit with no changes
  --allow-empty-message                               # allow commit with empty message
  --cleanup: string                                   # cleanup commit message
  --edit(-e)                                          # edit commit message
  --no-edit                                           # do not edit commit message
  --include(-i)                                       # include given paths in commit
  --only(-o)                                          # commit only specified paths
  --pathspec-from-file: string                        # read pathspec from file
  --pathspec-file-nul                                 # use NUL character for pathspec file
  --untracked-files(-u)                               # show untracked files (optional `=<mode>`)
  --verbose(-v)                                       # show diff in commit message template
  --quiet(-q)                                         # suppress commit summary
  --dry-run                                           # show paths to be committed without committing
  --status                                            # include git-status output in commit message
  --no-status                                         # do not include git-status output
  --gpg-sign(-S)                                      # GPG-sign commit
  --no-gpg-sign                                       # do not GPG-sign commit
  --interactive                                       # interactively add files
  --patch(-p)                                         # interactively add changes
  --ahead-behind                                      # compute full ahead/behind values
  --no-post-rewrite                                   # bypass post-rewrite hook
  --post-rewrite                                      # opposite of --no-post-rewrite
  ...pathspec: string                                 # commit files matching pathspec
]

# List commits
export extern "git log" [
  # Ideally we'd allow completion of revisions here, but that would make completion of filenames not work.
  -U                                                  # show diffs
  --follow                                            # show history beyond renames (single file only)
  --grep: string                                      # show log entries matching supplied regular expression
  --quiet(-q)                                         # suppress diff output
  --source                                            # show source
  --use-mailmap                                       # use mail map file
  --mailmap                                           # alias of --use-mailmap
  --clear-decorations                                 # clear all previously-defined decoration filters
  --decorate-refs: string                             # only decorate refs that match <pattern>
  --decorate-refs-exclude: string                     # do not decorate refs that match <pattern>
  --decorate                                          # decorate options
  -L: string                                          # trace the evolution of line range
]

# Show or change the reflog
export extern "git reflog" [
]

# Stage files
export extern "git add" [
  ...file: string@"nu-complete git add"               # file to add
  --all(-A)                                           # add all files
  --dry-run(-n)                                       # don't actually add the file(s), just show if they exist and/or will be ignored
  --edit(-e)                                          # open the diff vs. the index in an editor and let the user edit it
  --force(-f)                                         # allow adding otherwise ignored files
  --interactive(-i)                                   # add modified contents in the working tree interactively to the index
  --patch(-p)                                         # interactively choose hunks to stage
  --verbose(-v)                                       # be verbose
  --update(-u)                                        # update tracked files
  --renormalize                                       # renormalize EOL of tracked files (implies -u)
  --intent-to-add(-N)                                 # record only the fact that the path will be added later
  --ignore-removal                                    # ignore paths removed in the working tree (same as --no-all)
  --refresh                                           # don't add, only refresh the index
  --ignore-errors                                     # skip files which cannot be added because of errors
  --ignore-missing                                    # check if even missing files are ignored in dry run
  --sparse                                            # allow updating entries outside of the sparse-checkout cone
  --chmod: string                                     # override the executable bit of the listed files (+|-)x
  --pathspec-from-file: string                        # read pathspec from file
  --pathspec-file-nul                                 # pathspec elements separated with NUL character
]

# Delete file from the working tree and the index
export extern "git rm" [
  -r                                                   # recursive
  --force(-f)                                          # override the up-to-date check
  --dry-run(-n)                                        # Don't actually remove any file(s)
  --cached                                             # unstage and remove paths only from the index
  --quiet(-q)                                          # do not list removed files
  --ignore-unmatch                                     # exit with a zero status even if nothing matched
  --sparse                                             # allow updating entries outside of the sparse-checkout cone
  --pathspec-from-file: string                         # read pathspec from file
  --pathspec-file-nul                                  # pathspec elements separated with NUL character
]

# Show the working tree status
export extern "git status" [
  --verbose(-v)                                       # be verbose
  --short(-s)                                         # show status concisely
  --branch(-b)                                        # show branch information
  --show-stash                                        # show stash information
  --ahead-behind                                      # compute full ahead/behind values
  --porcelain                                         # machine-readable output (optional `=<version>`)
  --long                                              # show status in long format (default)
  --null(-z)                                          # terminate entries with NUL
  --untracked-files(-u)                               # show untracked files (optional `=<mode>`)
  --ignored                                           # show ignored files (optional `=<mode>`)
  --ignore-submodules                                 # ignore changes to submodules (optional `=<when>`)
  --column                                            # list untracked files in columns (optional `=<style>`)
  --no-renames                                        # do not detect renames
  --renames                                           # opposite of --no-renames
  --find-renames(-M)                                  # detect renames (optional `=<n>` similarity index)
]

# Stash the changes in a dirty working directory away
export extern "git stash" [
  subcommand?: string@"nu-complete git stash subcommands" # Stash subcommand
]

# Stash changes for later
export extern "git stash push" [
  --patch(-p)                                         # interactively choose hunks to stash
  --keep-index(-k)                                    # keep index
  --staged(-S)                                        # stash staged changes only
  --quiet(-q)                                         # quiet mode
  --include-untracked(-u)                             # include untracked files in stash
  --all(-a)                                           # include ignore files
  --message(-m): string                               # stash message
  --pathspec-from-file: string                        # read pathspec from file
  --pathspec-file-nul                                 # pathspec elements separated with NUL character
]

# Unstash previously stashed changes
export extern "git stash pop" [
  stash?: string@"nu-complete git stash-list"          # stash to pop
  --index(-i)                                          # try to reinstate not only the working tree's changes, but also the index's ones
  --quiet(-q)                                          # be quiet, only report errors
]

# List stashed changes
export extern "git stash list" [
]

# Show a stashed change
export extern "git stash show" [
  stash?: string@"nu-complete git stash-list"
  -U                                                  # show diff
  --include-untracked(-u)                             # include untracked files in the stash
  --only-untracked                                    # only show untracked files in the stash
]

# Drop a stashed change
export extern "git stash drop" [
  stash?: string@"nu-complete git stash-list"
  --quiet(-q)                                   # be quiet, only report errors
]

# Apply a stash without dropping it
export extern "git stash apply" [
  stash?: string@"nu-complete git stash-list"
  --index                                       # try to reinstate the index's changes too
  --quiet(-q)                                   # be quiet, only report errors
]

# Create a new branch from a stash
export extern "git stash branch" [
  branchname: string                            # name for the new branch
  stash?: string@"nu-complete git stash-list"   # stash to branch from
]

# Save the changes to a new stash (legacy form of push)
export extern "git stash save" [
  message?: string                              # message describing the stash
  --patch(-p)                                   # interactively choose hunks
  --staged(-S)                                  # stash only staged changes
  --keep-index(-k)                              # keep the index untouched
  --quiet(-q)                                   # quiet mode
  --include-untracked(-u)                       # include untracked files
  --all(-a)                                     # include ignored files
  --message(-m): string                         # stash message
]

# Drop all stashes
export extern "git stash clear" []

# Create a stash entry without storing it in the stash ref
export extern "git stash create" [
  message?: string                              # message describing the stash
]

# Store a stash created with `stash create` into the stash ref
export extern "git stash store" [
  commit: string                                # commit produced by `stash create`
  --message(-m): string                         # message describing the stash
  --quiet(-q)                                   # be quiet
]

# Create a new git repository
export extern "git init" [
  --initial-branch(-b): string                         # initial branch name
  --template: string                                   # directory from which templates will be used
  --bare                                               # create a bare repository
  --shared                                             # specify that the git repository is to be shared
  --quiet(-q)                                          # be quiet
  --separate-git-dir: string                           # separate git dir from working tree
  --object-format: string                              # specify the hash algorithm to use
  --ref-format: string                                 # specify the reference format to use
]

# List or manipulate tags
export extern "git tag" [
  --delete(-d): string@"nu-complete git tags"         # delete a tag
  --list(-l)                                          # list tag names
  -n                                                  # print lines of each tag message (optional `<n>`)
  --verify(-v)                                        # verify tags
  --annotate(-a)                                      # annotated tag, needs a message
  --message(-m): string                               # tag message
  --file(-F): path                                    # read message from file
  --trailer: string                                   # add custom trailer(s)
  --edit(-e)                                          # force edit of tag message
  --sign(-s)                                          # annotated and GPG-signed tag
  --cleanup: string                                   # how to strip spaces and #comments from message
  --local-user(-u): string                            # use another key to sign the tag
  --force(-f)                                         # replace the tag if exists
  --create-reflog                                     # create a reflog
  --column                                            # show tag list in columns
  --contains: string                                  # print only tags that contain the commit
  --no-contains: string                               # print only tags that don't contain the commit
  --merged: string                                    # print only tags that are merged
  --no-merged: string                                 # print only tags that are not merged
  --omit-empty                                        # do not output a newline after empty formatted refs
  --sort: string                                      # field name to sort on
  --points-at: string                                 # print only tags of the object
  --format: string                                    # format to use for the output
  --color                                             # respect format colors (optional `=<when>`)
  --ignore-case(-i)                                   # sorting and filtering are case insensitive
]

# Prune all unreachable objects
export extern "git prune" [
  --dry-run(-n)                                       # dry run
  --expire: string                                    # expire objects older than
  --progress                                          # show progress
  --verbose(-v)                                       # report all removed objects
  --exclude-promisor-objects                          # limit traversal to objects outside promisor packfiles
]

# Use binary search to find the commit that introduced a bug
export extern "git bisect" [
  subcommand?: string@"nu-complete git bisect subcommands" # Bisect subcommand
]

# Start a binary search to find the commit that introduced a bug
export extern "git bisect start" [
  bad?: string                 # a commit that has the bug
  good?: string                # a commit that doesn't have the bug
]

# Mark the current (or specified) revision as bad
export extern "git bisect bad" [
]

# Mark the current (or specified) revision as good
export extern "git bisect good" [
]

# Skip the current (or specified) revision
export extern "git bisect skip" [
]

# End bisection
export extern "git bisect reset" [
]

# Show or set the new/old terms used by bisect
export extern "git bisect terms" [
  --term-good                                   # show the term used for the "good" state
  --term-bad                                    # show the term used for the "bad" state
]

# Pick the next commit to test
export extern "git bisect next" []

# Show remaining bisect candidates
export extern "git bisect visualize" []

# Replay a bisection log file
export extern "git bisect replay" [
  logfile: path                                 # the log file to replay
]

# Print the bisection log to stdout
export extern "git bisect log" []

# Bisect by running a test script on each commit
export extern "git bisect run" [
  ...command: string                            # command and arguments to run
]

# Show help for a git subcommand
export extern "git help" [
  command?: string@"nu-complete git subcommands"       # subcommand to show help for
]

# git worktree
export extern "git worktree" [
  subcommand?: string@"nu-complete git worktree subcommands" # Worktree subcommand
  --help(-h)            # display the help message for this command
  ...args
]

# create a new working tree
export extern "git worktree add" [
  path: path            # directory to clone the branch
  branch?: string@"nu-complete git available upstream" # Branch to clone
  --help(-h)            # display the help message for this command
  --force(-f)           # checkout <branch> even if already checked out in other worktree
  -b                    # create a new branch
  -B                    # create or reset a branch
  --detach(-d)          # detach HEAD at named commit
  --checkout            # populate the new working tree
  --lock                # keep the new working tree locked
  --reason              # reason for locking
  --quiet(-q)           # suppress progress reporting
  --track               # set up tracking mode (see git-branch(1))
  --guess-remote        # try to match the new branch name with a remote-tracking branch
  --orphan              # create unborn branch
  --relative-paths      # use relative paths for worktrees
  ...args
]

# list details of each worktree
export extern "git worktree list" [
  --help(-h)            # display the help message for this command
  --porcelain           # machine-readable output
  --verbose(-v)         # show extended annotations and reasons, if available
  --expire              # add 'prunable' annotation to worktrees older than <time>
  -z                    # terminate records with a NUL character
  ...args
]

def "nu-complete worktree list" [] {
  ^git worktree list | to text | parse --regex '(?P<value>\S+)\s+(?P<commit>\w+)\s+(?P<description>\S.*)'
}

# prevent a working tree from being pruned
export extern "git worktree lock" [
  worktree: string@"nu-complete worktree list"
  --reason: string      # reason because the tree is locked
  --help(-h)            # display the help message for this command
  --reason              # reason for locking
  ...args
]

# move a working tree to a new location
export extern "git worktree move" [
  --help(-h)            # display the help message for this command
  --force(-f)           # force move even if worktree is dirty or locked
  --relative-paths      # use relative paths for worktrees
  ...args
]

# prune working tree information
export extern "git worktree prune" [
  --help(-h)            # display the help message for this command
  --dry-run(-n)         # do not remove, show only
  --verbose(-v)         # report pruned working trees
  --expire              # expire working trees older than <time>
  ...args
]

# remove a working tree
export extern "git worktree remove" [
  worktree: string@"nu-complete worktree list"
  --help(-h)            # display the help message for this command
  --force(-f)           # force removal even if worktree is dirty or locked
]

# allow working tree to be pruned, moved or deleted
export extern "git worktree unlock" [
  worktree: string@"nu-complete worktree list"
  ...args
]

# Repair working tree administrative files
export extern "git worktree repair" [
  ...paths: path                                # specific worktrees to repair
  --relative-paths                              # use relative paths for worktrees
]

# clones a repo
export extern "git clone" [
  --help(-h)                    # display the help message for this command
  --local(-l)                   # cloning from the local machine
  --no-local                    # use the git transport mechanism even if cloning from a local path
  --no-hardlinks                # force git to copy files when cloning from the local machine
  --shared(-s)                  # setup .git/objects/info/alternates to share objects with the source local repo
  --reference: string           # setup .git/objects/info/alternates to share objects with the =<reference> local repo
  --reference-if-able: string   # same as --reference, but skips empty folders
  --dissociate                  # borrow objects from the referenced repo (--reference)
  --quiet(-q)                   # suppress progress reporting
  --verbose(-v)                 # be verbose
  --progress                    # report progress unless --quiet
  --server-option: string       # transmit the =<option> to the server
  --no-checkout(-n)             # no checkout of HEAD
  --reject-shallow              # reject shallow repository as source
  --no-reject-shallow           # do not reject shallow repository as source
  --bare                        # make a bare git repo
  --sparse                      # initialize the sparse-checkout file
  --filter: string              # partial clone using the given =<filter-spec>
  --mirror                      # mirror the source repo
  --origin(-o): string          # use <name> as the name for the remote origin
  --branch(-b): string          # point HEAD to <name> branch
  --upload-pack(-u): string     # use <upload-pack> as the path in the other end when using ssh
  --template: string            # use <template-dir> as the templates directory
  --config(-c): string          # set a <key>=<value> config variable
  --depth: int                  # shallow clone <depth> commits
  --shallow-since: string       # shallow clone commits newer than =<date>
  --shallow-exclude: string     # do not clone commits reachable from <revision> (branch or tag)
  --single-branch               # clone commit history from a single branch
  --no-single-Branch            # do not clone only one branch
  --no-tags                     # do not clone any tags
  --recurse-submodules          # clone the submodules. Also accepts paths
  --shallow-submodules          # shallow clone submodules with depth 1
  --no-shallow-submodules       # do not shallow clone submodules
  --remote-submodules           # submodules are updating using their remote tracking branch
  --no-remote-submodules        # do not track submodules remote
  --separate-git-dir: string    # place the clone at =<git dir> and link it here
  --jobs(-j): int               # number of simultaneous submodules fetch
  --checkout                    # opposite of --no-checkout
  --hardlinks                   # opposite of --no-hardlinks
  --recursive                   # alias of --recurse-submodules
  --revision: string            # clone single revision and check out
  --ref-format: string          # specify the reference format to use
  --ipv4(-4)                    # use IPv4 addresses only
  --ipv6(-6)                    # use IPv6 addresses only
  --also-filter-submodules      # apply partial clone filters to submodules
  --bundle-uri: string          # URI for downloading bundles before fetching from origin remote
  ...args
]

# Restores files in working tree or index to previous versions
export extern "git restore" [
  --help(-h)                                    # Display the help message for this command
  --source(-s)                                  # Restore the working tree files with the content from the given tree
  --patch(-p)                                   # Interactively choose hunks to restore
  --worktree(-W)                                # Restore working tree (default if neither --worktree or --staged is used)
  --staged(-S)                                  # Restore index
  --quiet(-q)                                   # Quiet, suppress feedback messages
  --progress                                    # Force progress reporting
  --no-progress                                 # Suppress progress reporting
  --ours                                        # Restore from index using our version for unmerged files
  --theirs                                      # Restore from index using their version for unmerged files
  --merge(-m)                                   # Restore from index and recreate the conflicted merge in unmerged files
  --conflict: string                            # Like --merge but changes the conflict presentation with =<style>
  --ignore-unmerged                             # Restore from index and ignore unmerged entries (unmerged files are left as is)
  --ignore-skip-worktree-bits                   # Ignore sparse checkout patterns and unconditionally restores any files in <pathspec>
  --recurse-submodules                          # Restore the contents of sub-modules in working tree
  --no-recurse-submodules                       # Do not restore the contents of sub-modules in working tree (default)
  --overlay                                     # Do not remove files that don't exist when restoring from tree with --source
  --no-overlay                                  # Remove files that don't exist when restoring from tree with --source (default)
  --pathspec-from-file: string                  # Read pathspec from file
  --pathspec-file-nul                           # Separate pathspec elements with NUL character when reading from file
  ...pathspecs: string@"nu-complete git files"  # Target pathspecs to restore
]

# Print lines matching a pattern
export extern "git grep" [
  --help(-h)                            # Display the help message for this command
  --cached                              # Search blobs registered in the index file instead of worktree
  --untracked                           # Include untracked files in search
  --no-index                            # Similar to `grep -r`, but with additional benefits, such as using pathspec patterns to limit paths; Cannot be used together with --cached or --untracked
  --no-exclude-standard                 # Include ignored files in search (only useful with --untracked)
  --exclude-standard                    # No not include ignored files in search (only useful with --no-index)
  --recurse-submodules                  # Recursively search in each submodule that is active and checked out
  --text(-a)                            # Process binary files as if they were text
  --textconv                            # Honor textconv filter settings
  --no-textconv                         # Do not honor textconv filter settings (default)
  --ignore-case(-i)                     # Ignore case differences between patterns and files
  -I                                    # Don’t match the pattern in binary files
  --max-depth: int                      # Max <depth> to descend down directories for each pathspec. A value of -1 means no limit.
  --recursive(-r)                       # Same as --max-depth=-1
  --no-recursive                        # Same as --max-depth=0
  --word-regexp(-w)                     # Match the pattern only at word boundary
  --invert-match(-v)                    # Select non-matching lines
  -H                                    # Suppress filename in output of matched lines
  --full-name                           # Force relative path to filename from top directory
  --extended-regexp(-E)                 # Use POSIX extended regexp for patterns
  --basic-regexp(-G)                    # Use POSIX basic regexp for patterns (default)
  --perl-regexp(-P)                     # Use Perl-compatible regular expressions for patterns
  --line-number(-n)                     # Prefix the line number to matching lines
  --column                              # Prefix the 1-indexed byte-offset of the first match from the start of the matching line
  --files-with-matches(-l)              # Print filenames of files that contains matches
  --name-only                           # Same as --files-with-matches
  --files-without-match(-L)             # Print filenames of files that do not contain matches
  --null(-z)                            # Use \0 as the delimiter for pathnames in the output, and print them verbatim
  --only-matching(-o)                   # Print only the matched (non-empty) parts of a matching line, with each such part on a separate output line
  --count(-c)                           # Instead of showing every matched line, show the number of lines that match
  --no-color                            # Same as --color=never
  --break                               # Print an empty line between matches from different files.
  --heading                             # Show the filename above the matches in that file instead of at the start of each shown line.
  --show-function(-p)                   # Show the preceding line that contains the function name of the match, unless the matching line is a function name itself.
  --context(-C): int                    # Show <num> leading and trailing lines, and place a line containing -- between contiguous groups of matches.
  --after-context(-A): int              # Show <num> trailing lines, and place a line containing -- between contiguous groups of matches.
  --before-context(-B): int             # Show <num> leading lines, and place a line containing -- between contiguous groups of matches.
  --function-context(-W)                # Show the surrounding text from the previous line containing a function name up to the one before the next function name
  --max-count(-m): int                  # Limit the amount of matches per file. When using the -v or --invert-match option, the search stops after the specified number of non-matches.
  --threads: int                        # Number of grep worker threads to use. Use --help for more information on grep threads.
  -f: string                            # Read patterns from <file>, one per line.
  -e: string                            # Next parameter is the pattern. Multiple patterns are combined by --or.
  --and                                 # Search for lines that match multiple patterns.
  --or                                  # Search for lines that match at least one of multiple patterns. --or is implied between patterns without --and or --not.
  --not                                 # Search for lines that does not match pattern.
  --all-match                           # When giving multiple pattern expressions combined with --or, this flag is specified to limit the match to files that have lines to match all of them.
  --quiet(-q)                           # Do not output matched lines; instead, exit with status 0 when there is a match and with non-zero status when there isn’t.
  --index                               # opposite of --no-index
  --fixed-strings(-F)                   # interpret patterns as fixed strings
  --open-files-in-pager(-O): string     # show matching files in the pager
  --ext-grep                            # allow calling of grep(1) (ignored by this build)
  ...pathspecs: string                  # Target pathspecs to limit the scope of the search.
]

export extern "git" [
  command?: string@"nu-complete git subcommands"   # Subcommands
  --version                                        # Prints the Git suite version that the git program came from
  --help(-h)                                       # Prints the synopsis and a list of the most commonly used commands
  --html-path                                      # Print the path, without trailing slash, where Git's HTML documentation is installed and exit
  --man-path                                       # Print the manpath (see man(1)) for the man pages for this version of Git and exit
  --info-path                                      # Print the path where the Info files documenting this version of Git are installed and exit
  --paginate                                       # Pipe all output into less (or if set, $env.PAGER) if standard output is a terminal
  --no-pager                                       # Do not pipe Git output into a pager
  --no-replace-objects                             # Do not use replacement refs to replace Git objects
  --bare                                           # Treat the repository as a bare repository
]