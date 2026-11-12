---
layout: page
title: Projects
header: Projects & writeups
group: navigation
date: "2026-11-12"
menus:
  - main
weight: 5
---

I build terminal tools to sharpen my workflow, and keep tinkering with a
Wayland compositor until it works exactly the way I want. Clojure and Scala
in a former life.

## Terminal & compositor

- **[vtmux](https://github.com/martintrojer/vtmux)** — Drop-in tmux
  replacement. Modern stack, better rendering, live upgrades.

- **[swayward-wm](https://github.com/swayward-wm)** — An i3/sway-compatible
  Wayland compositor (and [screen locker](https://github.com/swayward-wm/swaywardlock))
  on smithay, plus [sway-ipc-oracle](https://github.com/swayward-wm/sway-ipc-oracle)
  conformance tests.

- **[mu-crew](https://github.com/mu-crew)** — A persistent crew of pi agents
  across all my machines. Control plane, shared agent state, remote jobs,
  and an append-only session archive.

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

## Other tools

- **[klik](https://github.com/martintrojer/klik)** — A typing-speed TUI
  that adapts to *you* — analyzes per-character miss rate and timing,
  then targets your weakest letters with practice words. Fork of `thokr`.

- **[parakeet-writer](https://github.com/martintrojer/parakeet-writer)** —
  Push-to-talk transcription using NVIDIA's Parakeet v3 model. Hold the
  hotkey, speak, release — the transcription gets typed (or copied) into
  whatever window has focus. Local model, no API.

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
## Other tools         - misc standalone tools
## Older projects      - still works, but not actively developed

Each entry: bold link + 1-3 sentence description. Keep it scannable; lead
with what it *is*, not what it *does*.
-->
