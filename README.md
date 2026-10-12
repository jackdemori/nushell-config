# Nushell Config

Personal [nushell](https://www.nushell.sh/) setup for macOS: modules, completions, prompt, and environment, plus a one-command installer for a brand-new Mac. **macOS only.**

## Install on a new Mac

Open Terminal and run:

```sh
curl -fsSL https://raw.githubusercontent.com/jackdemori/nushell-config/main/install.sh | bash
```

Enter your password when asked (Homebrew, `/etc/shells`, and `chsh` need it). When it finishes, **open a new terminal window** — it starts in nushell with everything loaded.

The installer, in order:

1. Installs [Homebrew](https://brew.sh/) if it isn't there (this also installs the Xcode Command Line Tools).
2. Installs `nushell` and `alerter` (macOS notifications) with brew.
3. Downloads this repo into `~/.config/nushell/`.
4. Runs `setup.nu`, which:
   - adds `source ~/.config/nushell/init.nu` to nushell's `config.nu` (`~/Library/Application Support/nushell/`), creating it if needed;
   - writes an auto-generated block into `env.nu` with fuzzy completions, no banner, `EDITOR`, `PATH` (built from `/etc/paths`, `/etc/paths.d/*`, and `brew shellenv`, like a fresh zsh login), and `.NET` variables if dotnet is installed;
   - makes nu your default login shell (adds it to `/etc/shells` and runs `chsh` for your user only).

Every step is idempotent — re-running the installer is safe and skips anything already done.

### Bringing over your apps

The installer only sets up the shell. To copy your Homebrew packages and apps from another Mac:

```nu
brew export ~/Brewfile     # on the old Mac
brew import ~/Brewfile     # on the new Mac, after installing
```

Optional tools such as `fnm` or `dotnet` aren't installed by default. Their modules stay quiet when the tool is missing and light up once it's installed (`brew install fnm`, then open a new terminal). After installing something that adds a `PATH` entry (e.g. the .NET installer), run `self update` or `nu ~/.config/nushell/setup.nu` to refresh the environment block.

## Updating

From nushell:

```nu
self update
```

This pulls the latest files (`git pull` if `~/.config/nushell` is a git checkout, otherwise a fresh tarball mirrored over the old one) and re-runs `setup.nu`. Re-running the `curl … | bash` one-liner from any shell does the same, and also installs anything new the installer requires.

## What you get

**Prompt** — right-side prompt with last exit code, git branch and change count, and the current date/time.

**Completions** for `brew`, `docker`, `dotnet`, `fnm`, and `git`: every subcommand and flag, with descriptions, instant (no CLI calls on `<TAB>`).

**Commands**

| Command | What it does |
| --- | --- |
| `self update` | Update this config and refresh the environment |
| `reload` | Restart nushell in place to pick up config changes |
| `brew export [path]` / `brew import [path]` | Save / restore your Homebrew packages as a Brewfile |
| `git authors` | Per-author commit and line stats for a branch |
| `git history [n]` / `git histogram [n]` | Recent commits as a table / commit counts per author |
| `git diff-copy [base] [target]` | Copy a diff between two refs to the clipboard |
| `git clear [--ignore …]` | Delete local branches except main, the current one, and any you list |
| `dotnet purge list \| dry-run \| remove` | Inspect and remove installed .NET SDKs/runtimes |
| `notify "Title" [msg]` / `notify "Title" { cmd }` | Native macOS notification; the block form times a command and reports how it went |
| `notify list` / `notify cancel` | Manage pending notifications |
| `finder` / `reveal` / `preview` | Open in Finder, reveal a file, Quick Look a file |
| `world-time <city…>` | Current time in one or more timezones |
| `random ulid` / `parse ulid` | Generate / decode ULIDs |

**fnm** — when installed, nushell switches Node versions automatically when you `cd` into a folder with `.nvmrc`, `.node-version`, or `package.json`.

## Layout

```
install.sh        bootstrap for a new Mac (curl | bash)
setup.nu          wires the config into nushell and sets the default shell
init.nu           loaded on every shell launch: modules + prompt
tests.nu          test runner — runs modules/*/tests.nu
modules/
  brew/           completions + brew export/import
  docker/         completions
  dotnet/         completions + dotnet purge
  fnm/            completions + auto version switching on cd
  git/            completions + git authors/history/histogram/diff-copy/clear
  macos/          notify, finder, reveal, preview
  self/           self update
  ui/             shared output helpers (spinner, status lines, has-command)
  ulid/           ULID generate/parse
  world-time/     world clock
```

## Development

### Completions conventions

- **Static subcommand lists.** Completers like `nu-complete brew subcommands` return a literal list of `{value, description}` records instead of calling the CLI, so `<TAB>` is instant and never falls back to file completion.
- **Every flag.** Each `export extern` lists every flag the CLI accepts, with a `# description` shown in the menu. Optional-value flags (`--X[=<value>]`) are declared as bare switches; giving them `: string` would make nu require a value and break `--X | next-command`.
- **Detecting binaries.** Use `has-command <name>` (from `modules/ui`), not `which`: `which` also matches our own `extern` declarations and reports a CLI as installed when it isn't.

### Tests

Each completion module has a `tests.nu` that parses the installed CLI's `--help` output and checks that every advertised flag and subcommand is covered. Modules whose CLI isn't installed are skipped.

```nu
nu tests.nu                 # all modules (382 tests, ~30s)
nu modules/git/tests.nu     # one module
```

When a CLI update adds flags or commands, these tests fail and list what's missing.

## Uninstalling

```sh
chsh -s /bin/zsh
rm -rf ~/.config/nushell
```

Then remove the `source ~/.config/nushell/init.nu` line and the auto-generated block from `~/Library/Application Support/nushell/config.nu` and `env.nu`.
