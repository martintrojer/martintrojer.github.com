---
layout: page
title: Projects
header: Projects & writeups
group: navigation
date: "2026-04-26"
menus:
  - main
weight: 5
---

A curated list of things I've built or written that live outside the regular
blog post stream.

## Developer tools

- **[vecgrep](https://github.com/martintrojer/vecgrep)** — Semantic grep:
  like ripgrep, but searches by meaning instead of substring. Local-first
  (the embedding model ships inside the binary, no API keys, code stays on
  your machine), with an interactive TUI, an HTTP server for IDE plugins,
  and optional hybrid lexical+semantic ranking. The one I reach for daily.

- **[carddown](https://github.com/martintrojer/carddown)** — A CLI flashcard
  system with spaced repetition (SM2/SM5/Simple8) that lives in your
  markdown notes. Cards are identified by content hash so they survive
  edits and file moves; per-vault SQLite state, no cloud, no sync.

- **[klik](https://github.com/martintrojer/klik)** — A typing-speed TUI
  that adapts to *you* — analyzes per-character miss rate and timing,
  then targets your weakest letters with practice words. Detailed
  analytics, session deltas, and historical comparison. Fork of `thokr`.

## Neovim plugins

A small family of plugins that bring vim-fugitive's "the workflow is the UI"
ergonomics to non-git VCSes, plus a shared review engine.

- **[jj-fugitive](https://github.com/martintrojer/jj-fugitive)** — A
  fugitive-style plugin for [Jujutsu](https://github.com/jj-vcs/jj). Log
  view as the primary hub, bookmark management, rebase/squash from the
  log, side-by-side diffs, annotate/blame, divergence protection — the
  full surface, native to jj's model.

- **[sl-fugitive](https://github.com/martintrojer/sl-fugitive)** — Same
  idea, but for [Sapling](https://sapling-scm.com/). Smartlog as the hub,
  stack-aware mutations (rebase, split, fold, absorb, restack), interactive
  rebase, amend-to.

- **[redline.nvim](https://github.com/martintrojer/redline.nvim)** — The
  shared review-capture engine behind both plugins above. Press `cR` in any
  diff buffer to capture lines into a structured markdown packet, then
  paste the whole thing into the AI agent of your choice for review. Works
  with mini.git, vim-fugitive, and Neovim 0.12+ `:DiffTool`.

## Voice & writing helpers

Hotkey-triggered Rust tools for Linux (Wayland) and macOS that sit between
your keyboard and whatever you're typing into.

- **[parakeet-writer](https://github.com/martintrojer/parakeet-writer)** —
  Push-to-talk transcription using NVIDIA's Parakeet v3 model. Hold the
  hotkey, speak, release — the transcription gets typed (or copied) into
  whatever window has focus. Local model, no API.

- **[improve-writing](https://github.com/martintrojer/improve-writing)** —
  Select text, press a hotkey, and a local Ollama model rewrites it
  in-place. Separate hotkeys for "improve text" and "generate shell
  command from natural language description."

## Tutorials

- **[Sway School](/sway-school/)** — A tree-first tutorial for beginners
  learning the [sway](https://swaywm.org/) Wayland compositor. Explains
  the i3/sway layout tree from the ground up with worked examples.

## Older projects

- **[frinj](https://github.com/martintrojer/frinj)** — A unit-of-measure
  calculator DSL for Clojure/ClojureScript, inspired by the
  [Frink](http://futureboy.us/frinkdocs/) project. Tracks units through
  every calculation, ships with a large unit database, supports live feeds
  for currency conversion. Circa 2013, but still does what it says on the
  tin. Browser demo lives [here](/frinj-demo/).

<!--
Add new entries above. Group conventions:

## Developer tools     - standalone CLIs
## Neovim plugins      - editor extensions
## Voice & writing helpers - hotkey-triggered desktop tools
## Tutorials           - standalone HTML tutorials in static/
## Older projects      - still works, but not actively developed

Each entry: bold link + 1-3 sentence description. Keep it scannable; lead
with what it *is*, not what it *does*.
-->
