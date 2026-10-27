**English** | [Français](CONTRIBUTING.fr.md)

# Contributing to OmsyServer

Thanks for your interest! OmsyServer is still in development, so any help is welcome: bug reports, ideas, fixes and documentation.

## Report a problem

Open an issue and include:

- your system and version (macOS or Ubuntu),
- the command you ran,
- the full error message,
- the relevant logs from `share/logs/`.

## Propose a change

1. Fork the repository and clone your fork.
2. Create a branch: `git checkout -b my-change`
3. Make your changes and test them.
4. Commit with a clear message.
5. Push and open a pull request explaining what you changed and why.

Small, focused pull requests are easier to review.

## Test safely

The scripts modify the system (see the Warning section of the [README](README.md)). Always test on a virtual machine or a throwaway machine, and mention in your pull request which system you tested (macOS, Ubuntu or both).

## Guidelines

- Install scripts live in `source/`. Start from `model.sh` and use the helpers in `common.sh` (such as `download_source`).
- Shell scripts start with `set -e` and should work on both macOS and Ubuntu.
- Never commit personal paths, passwords or generated files. Use `PATH_ROOT` instead of a fixed path.
- Keep the C tools (`omsyctl`, `omsyd`) portable between Linux and macOS.
- If your change touches the system (new package, file outside the project folder, port, user), add it to the Warning section of both READMEs.
- Update `README.md` and `README.fr.md` together. If you only write one language, say so in your pull request and the maintainers will translate.