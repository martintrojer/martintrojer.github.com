---
layout: page
title: Projects
header: Projects & writeups
group: navigation
date: "2026-11-24"
menus:
  - main
weight: 5
---

I build terminal tools to sharpen my workflow, and keep tinkering with a
Wayland compositor until it works exactly the way I want. Clojure and Scala
in a former life.

## Terminal & compositor

- **[vtmux](https://github.com/martintrojer/vtmux)** — Drop-in tmux
  replacement. Modern stack, better rendering, live upgrades. Checked
  against 449 scenarios recorded from real tmux 3.8.

- **[swayward-wm](https://github.com/swayward-wm)** — An i3/sway-compatible
  Wayland compositor (and [screen locker](https://github.com/swayward-wm/swaywardlock))
  on smithay, plus [sway-ipc-oracle](https://github.com/swayward-wm/sway-ipc-oracle)
  conformance tests. Started as a fork of [niri](https://github.com/YaLTeR/niri).

- **[mu-crew](https://github.com/mu-crew)** — A persistent crew of pi agents
  across all my machines:
  - [mu](https://github.com/mu-crew/mu) — the control plane: agents in tmux
    panes, a task DAG, review gates, delegated checks.
  - [murmur](https://github.com/mu-crew/murmur) — agent state across every
    machine, in one tmux HUD.
  - [mule](https://github.com/mu-crew/mule) — fire remote jobs down a
    private ssh channel nothing else can contend with.
  - [muzzle](https://github.com/mu-crew/muzzle) — a slot queue that stops the
    agents' builds and test suites from eating the machine.
  - [museum](https://github.com/mu-crew/museum) — append-only archive of
    every agent session from every machine, searchable by agents.
  - [tmux-session-picker](https://github.com/mu-crew/tmux-session-picker) —
    one fzf popup for sessions, with agent state from murmur.

## Notes

- **[mdroots](https://github.com/martintrojer/mdroots)** — A zero-config
  markdown (and org) language server and Rust library.

- **[ramble](https://github.com/martintrojer/ramble)** — Read your notes in
  the terminal, and follow them wherever they link.

- **[debrief](https://github.com/martintrojer/debrief)** — Catch up with what
  your coding agents committed, and answer back.

- **[carddown](https://github.com/martintrojer/carddown)** — Spaced repetition
  for your markdown notes. Cards are identified by content hash so they
  survive edits and file moves; per-vault SQLite state, no cloud.

- **[vecgrep](https://github.com/martintrojer/vecgrep)** — Semantic grep:
  like ripgrep, but searches by meaning. Local-first embedding model inside
  the binary, interactive TUI, optional hybrid lexical+semantic ranking.

## Maintaining

- **[tuicr](https://github.com/agavra/tuicr)** — A human-in-the-loop code
  review TUI for AI-generated changes, by Almog Gavra. I help maintain
  it: triaging issues and merging PRs (mostly agent-written, as the
  project encourages), with agents doing the first pass.

## Other tools

- **[klik](https://github.com/martintrojer/klik)** — A typing-speed TUI
  that adapts to *you* — analyzes per-character miss rate and timing,
  then targets your weakest letters with practice words. Fork of `thokr`.

- **[parakeet-writer](https://github.com/martintrojer/parakeet-writer)** —
  Push-to-talk transcription using NVIDIA's Parakeet v3 model. Hold the
  hotkey, speak, release — the transcription gets typed (or copied) into
  whatever window has focus. Local model, no API.

- **[improve-writing](https://github.com/martintrojer/improve-writing)** —
  Select text, press a hotkey, get an improved version typed back. Local
  model via Ollama, Wayland and macOS.

- **[tmux-fingers-rs](https://github.com/martintrojer/tmux-fingers-rs)** —
  Copy paths, URLs, SHAs and friends from a tmux pane with letter hints.
  Rust port of [tmux-fingers](https://github.com/Morantron/tmux-fingers);
  your config keeps working.

- **[hexclack](https://github.com/martintrojer/hexclack)** — Drives the
  Elgato Stream Deck Mini directly over USB and replaces the Elgato app.

## Older projects

- **[frinj](https://github.com/martintrojer/frinj)** — A unit-of-measure
  calculator DSL for Clojure/ClojureScript, inspired by the
  [Frink](http://futureboy.us/frinkdocs/) project. Tracks units through
  every calculation, ships with a large unit database, supports live feeds
  for currency conversion. Circa 2013, but still does what it says on the
  tin. Browser demo lives [here](/frinj-demo/).

<!--
Add new entries above. Group conventions:

## Terminal & compositor - vtmux, swayward, mu-crew
## Notes               - markdown / note-taking CLIs
## Maintaining         - other people's projects I maintain
## Other tools         - misc standalone tools
## Older projects      - still works, but not actively developed

Each entry: bold link + 1-3 sentence description. Keep it scannable; lead
with what it *is*, not what it *does*.
-->
