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

Agents don't feel pain. Humans do. That asymmetry, pointed out by [Mario Zechner](https://mariozechner.at/), turns out to be quite profound.

Pain in a codebase is a signal. It's the thing that makes you finally rip out the half-baked abstraction. It's the thing that makes a senior engineer say "no, we don't need that". It's the thing that drives refactoring before the next change becomes scary. Pain is what kept the size and shape of systems honest, even when nobody had time to write down why.

Agents don't feel any of this. They will say yes to everything. They will add a defensive recovery branch for every theoretically-possible failure mode. They will not get tired of carrying around the weight of the last six accidental abstractions, because they don't carry it. They don't experience the codebase. They just look at it.

Looking through this lens, I'd see roughly three groups of developers right now.

The first group still feels the pain, but refuses the lever. They don't use the tools, or they use them grudgingly. They are not wrong about the risks. They are just slowly being outpaced by people who found a way to run faster without ignoring the same risks they care about. Pain alone, without leverage, doesn't keep you safe.

The second group reached for the leverage and outsourced the work. Which would have been fine, except they outsourced the pain channel along with it. The codebase quietly rots and nobody notices, because the people who would have noticed have stopped reading the diffs. The friction got removed so the agents could run autonomously and in parallel, and the part of the system that asked "are you sure" got removed with it. They look fast. The bill is accumulating.

The third group used the leverage and kept the pain channel open. They use agents on the work where it pays — boring stuff, cleanup, scaffolding, drafts of evidence, tedious migrations — and they keep human attention on the parts where pain is still the only reliable signal. They put the friction back where the agents removed it carelessly. They notice when the codebase starts to get heavier. They still say no.

This is who the [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/) actually is. Not the fastest typer, not the loudest tool advocate, not the most stubborn skeptic. The person whose pain signal still works. The team whose back-pressure is intact even though their throughput is up. The scarce resource was never code. It was trusted change.

So the question to leave with isn't "are you using AI yet". It isn't "adapt or die" either.

What does your team currently have in place to feel pain when the codebase rots? When nobody really cares about the change? When the friction quietly went away because the agents needed it to be gone?

If you can name those mechanisms, you are probably in the third group.

If you can't, the codebase will tell you. Eventually.
