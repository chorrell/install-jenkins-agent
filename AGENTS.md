# AGENTS.md

A bash script that installs a Jenkins permanent agent (`agent.jar`) on a Linux
node and registers it as a systemd service.

## Project Layout

```text
.
├── install-jenkins-agent.sh   # Main script (must be run with sudo)
├── README.md
├── LICENSE
├── .pre-commit-config.yaml
├── .markdownlint.yaml
└── .github/workflows/
    ├── shellcheck.yml
    └── markdownlint.yml
```

## Usage

```bash
sudo ./install-jenkins-agent.sh \
  -n AGENT_NAME -s SECRET -j JENKINS_URL -w WORK_DIR [-u USER]
```

Flags: `-j` Jenkins URL, `-n` agent name, `-s` secret, `-u` service user
(default `root`), `-w` working directory (required), `-h` help.

## Code Style

- Bash with `set -euo pipefail` and `IFS=$'\n\t'` (strict mode).
- Always quote variables.
- Must pass ShellCheck and shfmt (2-space indent, spaces around redirects) —
  enforced via `.pre-commit-config.yaml` and `shellcheck.yml`.
- Markdown must pass markdownlint (`.markdownlint.yaml`).

## CI/CD

- `shellcheck.yml`: lints `install-jenkins-agent.sh` on PRs.
- `markdownlint.yml`: lints Markdown files on PRs.

## Contributing

1. Branch from `main`.
2. Run `pre-commit run --all-files` before committing.
3. Test the script against a real or disposable agent node.
4. Open a PR; CI runs shellcheck and markdownlint.
