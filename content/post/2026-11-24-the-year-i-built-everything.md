---
title: The year I built everything
date: "2026-11-24T00:00:00Z"
draft: false
description: "2026: from typist to builder, and what comes after the clones."
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

2026 was the year where I fully transitioned from typist to builder. Pretty much any idea was a few prompts away from an MVP. Culling these MVPs and turning some of them into solid software was still hard and time consuming no matter how many tokens were spent. The feeling of say 'yes' to every whim was exhilarating.

## Building for an audience of one

We have entered the era of personalized software. Now that you can build pretty much anything, the question is where do you start? One obvious avenue is to scratch your own itches. As a seasoned developer who obsesses about optimizing my workflow, there was plenty to be done.

I can categorize what turned out reasonably well into 3 buckets.

1. Ambitious projects
   - [swayward-wm](https://github.com/swayward-wm/swayward) (an i3/sway-compatible Wayland compositor, built in Rust -- of course I had to build my own window manager, I mean who didn't in 2026?)
   - [vtmux](https://github.com/martintrojer/vtmux) (a drop-in tmux replacement, my list of tmux annoyances grew too long)
2. Migrating from working in an editor to reading and commenting on AI output
   - [mdroots](https://github.com/martintrojer/mdroots) (a zero-config markdown and org language server)
   - [ramble](https://github.com/martintrojer/ramble) (read your notes in the terminal, and follow them wherever they link)
   - [debrief](https://github.com/martintrojer/debrief) (catch up with what your coding agents committed, and answer back)
3. Building an agent orchestration toolset in which everything else was built
   - [mu-crew](https://github.com/mu-crew) (run a crew of coding agents in tmux: Claude Code, Codex, Cursor, Muse Code and pi, mixed as you like)

## Why the ambitious projects worked

My 2 big projects worked because they were tightly bounded by specs written elsewhere.

- vtmux: tmux's CLI, formats, control mode, recorded behaviour (oracle).
- swayward: Wayland protocols, i3/sway IPC, i3's test suite, sway as oracle via [sway-ipc-oracle](https://github.com/swayward-wm/sway-ipc-oracle).

A spec + a live reference turns an open design problem into a convergent search. This is a very effective way of keeping agents on track. I wasn't inventing product and systems engineering at the same time. The product was decided years ago by the tmux and i3/sway folks.

In contrast mu-crew, ramble, debrief have no oracle. There the bottleneck was me: taste, constraints, throwing things away. More rewrites, more experiments, more churn.

## Not all AI code is slop

The AI backlash is real and justified to large degree, but it's too simplistic. "AI slop" is slapped on any project where AI was involved, no matter the quality. Disclosing AI use opens you up to lazy dismissals like 'used AI so must be low quality slop'.

Much have been said about how well-known open source projects handle AI contributions. My take is that if you read these projects' AI policies closely, they're often not about actual AI code, they're about asymmetry: generating plausible code is near-free, refuting it is not. Most policies converge on one rule: a human who understands the change and stands behind it. I touched on this in [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/).

When you writing software for yourself its different. The verification cost are on you, not a maintainer. Nobody has to triage your output. If you try to build high quality software this way, that is not slop, quite the opposite.

## AI code vs. actual slop

Slop is the lack of discipline and ownership. Slop = unverified, un-dogfooded, nobody home. vtmux, swayward, mdroots are my counter-examples: oracles, thousands of tests, invariants checked on every push, fuzzing/soak, and I use them all day.

This is the point I made in [New code, trusted code, proven code](/post/2026-04-11-new-code-trusted-code-proven-code/) put into practice: proof of use still wins. If you live inside your compositor, multiplexer and LSP every day, slop doesn't survive.

Sceptics can't tell the difference from the outside, and a repo that says "built with AI" is a weak signal. Trusting a project just because it was hand made is equally weak. Trust is earned by the oracle results, the test counts, proof of use and the divergence lists. Receipts that can be verified by others.

## What is next

I've proved to myself that a solo engineer can now execute known large systems. A multiplexer, a compositor, an LSP: rebuilt better, to my taste, in weeks. That's becoming table stakes. The interesting question is what happens when you take the training wheels (external spec + oracle) off.

Now I am looking at equally ambitious projects that aren't 'clones' but bring genuine novelty to a field. These kinds of projects have to build their own ground truth (formal specs, proofs, benchmarks, real users). Problem formulation, domain depth and taste become the bottleneck: things you can't outsource.

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
