# Nushell Config

Personal [nushell](https://www.nushell.sh/) configuration. This includes modules, the prompt, and environment setup, accompanied by a single-step installer for fresh Macs. **macOS only** — the installer bails out on other platforms.

## Install

Prerequisites: [Homebrew](https://brew.sh/) and nushell (`brew install nushell`).

Then:

`
curl -fsSL https://raw.githubusercontent.com/jackdemori/nushell-config/main/install.sh | bash
`

That is all. The command downloads the repository tarball into `~/.config/nushell/`, then delegates to `setup.nu`. This script wires the components into the primary nushell configuration directory and establishes nu as the default login shell.

## What gets set up

**`install.sh`** downloads the files (avoiding the need for a full git clone) and invokes:

**`setup.nu`**, which:

1. Appends `source ~/.config/nushell/init.nu` to the primary `config.nu` (located at `$nu.config-path`), ensuring nushell loads this portable configuration upon every shell launch.
2. Writes an auto-generated block into the primary `env.nu`, configuring:
   - Shell preferences (fuzzy completions, banner disabled)
   - `EDITOR`
   - `.NET` (`DOTNET_ROOT` resolved via `which dotnet`, telemetry disabled), skipped cleanly if dotnet is not installed
   - `PATH` (composed via `brew shellenv` and the macOS `path_helper`, allowing it to pick up `/etc/paths` and `/etc/paths.d/*` without hardcoding)
3. Adds nu to `/etc/shells` (requiring sudo) and executes `chsh` to set it as the default login shell.

All steps are idempotent; executing the script multiple times is entirely safe.

## Layout

```
install.sh        single-step bootstrap fetched via curl | bash
setup.nu          wires the downloaded files into the system
init.nu           sourced from the primary config.nu on every shell launch
tests.nu          top-level test runner — discovers modules/*/tests.nu
modules/
  brew/           brew completions + export/import Brewfile helpers
  docker/         docker completions
  dotnet/         dotnet completions + dotnet uninstall-all
  fnm/            fnm completions + automatic version switching on cd
  git/            git completions + right prompt + log/histogram helpers
  macos/          macOS utilities
  self/           self update + self config
  ui/             shared output helpers (colours, spinner, status icons)
  ulid/           ULID generator
  world-time/     world-clock helpers
```

## Completions

The five CLI modules (`brew`, `docker`, `dotnet`, `fnm`, `git`) declare nushell `export extern` signatures so tab completion shows subcommands and flags with one-line descriptions inline. Two conventions keep the experience consistent and fast:

- **Static subcommand completers on every parent.** A completer like `nu-complete brew subcommands` returns a literal list of `{value, description}` records — no live `^brew commands` invocation. This is what prevents `brew <TAB>` from falling back to filesystem completion and keeps tab response instant.
- **Comprehensive per-command flags.** Each leaf extern lists every long flag the CLI accepts, with the `# description` comment surfaced in the completion menu. Optional-value flags (those documented as `--X[=<value>]`) are declared as bare switches — declaring them with `: string` would force nu's parser to require a value and break `--X | next-pipe` usage.

## Tests

Each completion module has a `tests.nu` next to its `completions.nu`. Tests parse the live CLI's `--help` output and assert every flag the CLI advertises is in our extern, plus subcommand discovery to catch new commands that future CLI releases add.

Run the full suite:

```nu
nu tests.nu
```

…or a single module:

```nu
nu modules/git/tests.nu
```

Each test result prints `✓` / `✗` per command. The suite currently exercises 376 tests across the five completion modules in ~30s.

## Regenerating the environment block

Executing `setup.nu` again rewrites the auto-generated section of `env.nu` in place. State outside of this section remains untouched. This behaviour is useful when a newly installed tool adds an entry to `/etc/paths.d/`, or if you have modified the generated values and wish to restore the defaults.

```sh
nu ~/.config/nushell/setup.nu
```

## Updating

Two equivalent ways to pull the latest version. Both inspect `~/.config/nushell/` first and choose the right strategy:

- If the directory is a **git checkout** (i.e. `~/.config/nushell/.git/` exists), they run `git pull --ff-only origin main`.
- Otherwise (a tarball install, or no directory at all), they download a fresh tarball from GitHub and rsync it into place.

In both cases, `setup.nu` is executed at the end to refresh the generated block in `env.nu`.

**From within nushell** (preferred):

```nu
self update
```

**From a plain shell**, re-run the installation one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/jackdemori/nushell-config/main/install.sh | bash
```

Both paths fully mirror the repository: files renamed or removed upstream are removed locally as well. Local-only state (`.git/`, `.claude/`, `.DS_Store`) is preserved.

## Uninstalling

```sh
rm -rf ~/.config/nushell
```

Subsequently, open `~/Library/Application Support/nushell/config.nu` and `env.nu`, and remove the `source ~/.config/nushell/init.nu` directive, alongside the generated environment block.
