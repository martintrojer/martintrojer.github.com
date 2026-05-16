---
title: No pain, no trust
date: "2026-05-04T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

Agents don't feel pain. Humans do. This insight, pointed out by [Mario Zechner](https://mariozechner.at/), turns out to be quite profound.

Pain in a codebase is a signal. It's a feeling that senior developers have spent decades calibrating to say "no, we don't need that". It's the thing that triggers a large refactor even though it will not add any new features to the next release. Pain is what kept the size and shape of systems honest.

Agents don't feel any of this. They will say yes to everything. They will add a defensive recovery branch for every possible failure mode. They will not get tired of carrying around the weight of the last six accidental abstractions, because they don't carry it. They just poke at it.

Looking through this lens, I'd see roughly three groups of developers right now.

The first group still feels the pain, but they don't use the tools, or they use them grudgingly. They are not wrong about the risks. They are just slowly being outpaced by people who found a way to run faster without ignoring the pain they feel.

The second group outsourced the work. The problem is that they outsourced the pain as well. The codebase quietly rots and nobody notices, because they stopped understanding the diffs. Any friction got removed so the agents could run unencumbered, and the part that asked "are you sure" got removed with it. They look fast but the bill is accumulating.

The third group found a way to use the tools and keep feeling the pain. They use agents on the work where it pays — boring stuff, cleanup, scaffolding, drafts of evidence, tedious migrations — and they keep attention on the parts where pain is the only reliable signal. They deliberately keep the friction. They still say no.

This is who the [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/) is. Not the loudest advocate, not the most stubborn skeptic. The person who still feel the pain. The person whose back-pressure is intact even though their throughput is up.

Ask yourself this: what does your team currently have in place to feel pain when the codebase rots? When nobody really cares about half of the PRs? When the friction is slipping away because it slows down the agents?

If you can name those things, you are probably good.

If you can't, the codebase will eventually tell you.
