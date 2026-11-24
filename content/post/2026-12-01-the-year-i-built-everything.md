---
title: The year I built everything
date: "2026-12-01T00:00:00Z"
draft: true
description: "2026: from typist to builder, and what comes after the clones."
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

2026 was the year where I fully transitioned from typist to builder. Pretty much any idea was a few prompts away from an MVP. Culling these MVPs and turning some of them into actually good software was still hard and time consuming no matter how many tokens were spent.

## Building for an audience of one

... or the era of personalized software.

If you can build pretty much anything, where do you start? One obvious avenue is to scratch your own itches. As a seasoned developer who obsesses about optimizing my workflow, there was plenty to be done.

I can categorize what I did into 3 buckets.

1. Ambitious projects
  - [swayward-wm](https://github.com/swayward-wm/swayward) (of course I had to build my own window manager, I mean who didn't in 2026?)
  - [vtmux](https://github.com/martintrojer/vtmux) (my list of tmux annoyances grew too long)
2. Terminal workflows
  - migrating from working in an editor to reading and commenting on AI output; [mdroots](https://github.com/martintrojer/mdroots), [ramble](https://github.com/martintrojer/ramble) and [debrief](https://github.com/martintrojer/debrief)
3. Building an agent orchestration toolset in which everything else was built
  - [mu-crew](https://github.com/mu-crew)

## Why the ambitious projects worked

My 2 big projects worked because they are tightly bounded by specs written elsewhere.

- vtmux: tmux's CLI, formats, control mode, recorded behaviour (oracle).
- swayward: Wayland protocols, i3/sway IPC, i3's test suite, sway as oracle via [sway-ipc-oracle](https://github.com/swayward-wm/sway-ipc-oracle).

A spec + a live reference turns an open design problem into a convergent search. This is a very effective way of keeping agents on track. I wasn't inventing product and systems engineering at the same time. The product was decided years ago by the tmux and i3/sway folks.

In contrast mu-crew, ramble, debrief have no oracle. There the bottleneck was me: taste, constraints, throwing things away. More rewrites, more experiments, more churn.

## Not all AI code is slop

The AI backlash is real and somewhat justified. But it's too simplistic. "AI slop" now often means "AI was involved", full stop. Disclosing AI use is a credibility tax.

If you read open source project AI policies closely, they're often not about actual AI code, they're about asymmetry: generating plausible code is near-free, refuting it is not.

Most policies converge on one rule: a human who understands the change and stands behind it. I touched on this in [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/).

This is where I sit: my projects push the verification cost onto me, not onto a maintainer. Nobody has to triage my output. That's the opposite of slop.

## Slop vs. AI code

Slop is a property of discipline and ownership, not of who typed the tokens. Slop = unverified, un-dogfooded, nobody home.

vtmux, swayward, mdroots are my counter-examples: oracles, thousands of tests, invariants checked on every push, fuzzing/soak, and I use them all day.

This is the point I made in [New code, trusted code, proven code](/post/2026-04-11-new-code-trusted-code-proven-code/) put into practice: proof of use still wins. If you live inside your compositor, multiplexer and LSP every day, slop doesn't survive the week.

Sceptics can't tell the difference from the outside, and a repo that says "built with AI" is a weak signal. Trusting a project just because it was hand made is equally weak. Trust is earned by the oracle results, the test counts, and the divergence lists. Make it checkable by others.

## What is next: beyond clones

I've proved to myself that a solo engineer can now execute known large systems. A multiplexer, a compositor, an LSP: rebuilt better, to my taste, in weeks.

That's becoming table stakes. The interesting question is what happens when you take the training wheels (external spec + oracle) off.

Now I am looking for serious, big projects that aren't clones but bring genuine novelty to a field. You have to build your own ground truth (formal specs, proofs, benchmarks, real users).

Problem formulation, domain depth and taste become the bottleneck: things you can't outsource. The cost of building known things went to near zero. The cost of knowing what's worth building didn't.

## References

Open source AI policies and the backlash:

- Gentoo: [Council AI policy](https://wiki.gentoo.org/wiki/Project:Council/AI_policy)
- NetBSD: [Commit guidelines](https://www.netbsd.org/developers/commit-guidelines.html) (LLM code is "presumed to be tainted")
- QEMU: [Code provenance](https://www.qemu.org/docs/master/devel/code-provenance.html)
- curl: Daniel Stenberg, [Death by a thousand slops](https://daniel.haxx.se/blog/2025/07/14/death-by-a-thousand-slops/), [The end of the curl bug-bounty](https://daniel.haxx.se/blog/2026/01/26/the-end-of-the-curl-bug-bounty/) and [A new breed of analyzers](https://daniel.haxx.se/blog/2025/10/10/a-new-breed-of-analyzers)
- Ghostty: [AI policy](https://github.com/ghostty-org/ghostty/blob/main/AI_POLICY.md) and [the commit that tightened it](https://github.com/ghostty-org/ghostty/commit/f00de7ee4b9bbc5a0fb5f4c06755780c773a0f5e) ("not an anti-AI stance. This is an anti-idiot stance")
- tldraw: [Stay away from my trash](https://tldraw.dev/blog/stay-away-from-my-trash)
- Jazzband: [Sunsetting Jazzband](https://jazzband.co/news/2026/03/14/sunsetting-jazzband)
- Linux kernel: [AI coding assistants](https://docs.kernel.org/process/coding-assistants.html) (`Assisted-by:`)
- Debian: [General resolution on LLM usage](https://www.debian.org/vote/2026/vote_002_results)
- Overviews: [How OSS contribution policies changed in response to AI slop](https://codenote.net/en/posts/oss-ai-slop-contribution-policy-shift/) and [AI slop is flooding open source](https://openresource.dev/articles/ai-slop-contribution-policy/)

Earlier posts in this series:

- [New code, trusted code, proven code](/post/2026-04-11-new-code-trusted-code-proven-code/)
- [The engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/)
- [The new interpreter](/post/2026-05-08-the-new-interpreter/)
