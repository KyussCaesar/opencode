---
name: opencode
description: |
  An overview and index of information about OpenCode.
  The Agent SHALL invoke this Skill prior to using the `opencode` CLI or answering any user questions about the `opencode` CLI or debugging such issues.
---

[OpenCode](https://opencode.ai/) is an open source AI coding agent.
It’s available as a terminal-based interface, desktop app, or IDE extension.

## Basic Usage

Open the TUI (presents a chat-style interface, similar to Claude Code, Gemini CLI, Codex, et al.

```bash
opencode
```

Start `opencode` and instruct it to do something; like `claude --p`:

```bash
opencode run 'do something'
```

Configure model: (provider/name format)

```bash
opencode --model opencode/kimi-k2.5-free
```

Discover available/configured models:

```bash
opencode models
```

## Finding more information

The Agent can find more information about OpenCode by at the links in the below index of on-line documentation.

> [!NOTE]
> This index provides brief descriptons of each page, but these descriptions are *informational, not authoritative*.
> The Agent SHALL treat the below descriptions as *hints about when to read the page*.
> The authoritative reference for information about OpenCode *is retrieved from the relevant on-line source* and NOT from these descriptions.
>
> If The Agent notices that these descriptions are inaccurate or incomplete then The Agent SHOULD notify The User about the staleness and recommend what changes should be made.
> The Agent SHALL provide quotations of relevant reference material as supporting evidence of the recommended changes.

> [!NOTE]
> The Agent should notice the below links to `*.md` files: these are documentation files rendered in Markdown instead of HTML for the express purpose of token-efficient reading and in being friendly for LLMs to read and understand.
> When directing The User to 

**Getting Started**: https://opencode.ai/docs/index.md (NOTE: at the time of writing on 2026-0131 this page doesn't actually have an index of available pages, despite the name `index.md`).
- Covers OpenCode pre-requisites, installation, configuring an LLM provider, initialising OpenCode in a project (creating initial AGENTS.md), and asking OpenCode questions, and publicly sharing conversations.

**Configuring OpenCode**: https://opencode.ai/docs/config.md
- Explains the format and locations of OpenCode's JSON configuration file.
- OpenCode supports a hierarchical configuration system whereby all relevant configuration files are *merged* (not replaced) according to a defined precedence order.
  - The precedence order includes "remote", "global" (user `~/.config/opencode` directory), "custom", "project", `.opencode` directories, and "inline" configuration sources.
- The configuration schema covers the following areas: TUI, Server, Tools, Models, Themes, Agents, Default agent, Sharing, Commands, Keybinds, Autoupdate, Formatters, Permissions, Compaction, Watcher, MCP servers, Plugins, Instructions, Disabled providers, Enabled providers, and Experimental.

**OpenCode Providers**: https://opencode.ai/docs/providers.md
- Providers are the abstraction that OpenCode uses to talk about the various possible LLM inference providers that OpenCode may use.
- The document briefly explains more detail about how providers are configured generally.
- The document also includes a directory of the providers currently supported by OpenCode and how to set them up.

**Models and model selection**: https://opencode.ai/docs/models.md
- The User can use `/model` to switch models, or `--model` on the command line using `provider/modelName` format.
- The User can set the default model and set per-model configurations in their OpenCode configuration file.
- Variants: Many models support multiple variants with different configurations. OpenCode ships with built-in default variants for popular providers.

**OpenCode Agent Rules**: https://opencode.ai/docs/rules.md
- Generalised behaviour of OpenCode agents is instructed via `AGENTS.md` files.
- You can specify custom instruction files in your `opencode.json` configuration file, and/or the global `~/.config/opencode/opencode.json`. This allows you and your team to reuse existing rules rather than having to duplicate them to `AGENTS.md`.

**OpenCode Agent Tools**: https://opencode.ai/docs/tools.md
- Tools allow the *assistant* (the amorphous machine spirit we render unto reality with each nascent output token) to make requests of the *agent* (the harness, the program orchestrating LLM API calls and user input).
- There exists the usual set of tools: bash, edit, write, read, grep, glob, list, lsp, patch, skill, todowrite, todoread, webfectch, question.

**OpenCode Agent Skills**: https://opencode.ai/docs/skills.md
- Skills allow the agent to dynamically load knowledge on-demand.
- They live at `~/.config/opencode/skills/<name>/SKILL.md` (user-global) and `./.opencode/skills/<name>/SKILL>md` (project-based).

**OpenCode Agent... Agents**: https://opencode.ai/docs/agents.md
- Defines "primary" (user-interactive) and "subagent" (background subtask) agent types.
- Explains Build (the default agent; primary -- for standard development work), Plan (primary -- for planning/analysing codebases and creating implementation plans thereof), General (subagent -- for running parallel sub-tasks), and Explore (subagent -- for exploring codebases).

**OpenCode Commands**: https://opencode.ai/docs/commands.
- User-defined custom slash-commands: `/my-command`.
- Created for user-global scope in `~/.config/opencode/commands/<my-command>`, at project-scope in `./.opencode/commands/<my-command>`, or in any OpenCode JSON configuration file.

**Permissions**: https://opencode.ai/docs/permissions.md
- Describes OpenCode's permissions model and how to configure it.

**LSP Support**: https://opencode.ai/docs/lsp.md
- Describes OpenCode's LSP support and configuration.

**Customising OpenCode**:
- Themes: https://opencode.ai/docs/themes.md
- Keybindings: https://opencode.ai/docs/keybinds.md

**OpenCode Formatters**: https://opencode.ai/docs/formatters.md
- OpenCode automatically formats files after they are written or edited. OpenCode uses language-specific formatters for this purpose, identified by file extension (e.g. `*.go` for `go fmt`).
- A handful of formatters have built-in support: `go fmt`, `ruff`, `rustfmt`, `zig fmt`, `rubocop`, `terraform fmt`, and others (see doc)
- Editorial: This is neat, but I struggle to see why agent-level support is needed for this. I guess, anything you can remove from needing to spend tokens to achieve is good.

**Network**: https://opencode.ai/docs/network.md
- Explains how to configure OpenCode to use proxies and custom certificates.

**Troubleshooting**: https://opencode.ai/docs/troubleshooting.md
- Places to look for additional information when debugging issues with OpenCode, e.g. where logs, session data, and other application data are stored.
- Also contains an index of common issues and possible resolutions.

