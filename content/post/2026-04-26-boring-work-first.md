---
title: Boring work first
date: "2026-04-26T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

The all-or-nothing stance that dominates AI debates is not helpful. Neither of the extreme positions "we don't use AI here" and "we let Claude YOLO all our code" is productive. Both avoid having to think about the actual problem: how to use this powerful new tool without breaking the codebase with hundreds of invested man-years?

Turns out the answer is obvious: start with the work that is boring, low-risk and easy to review.

Low-risk is not the same as low-value. Low-risk here means tedious. Conceptually simple. Small blast radius. Easy to review. If the AI does the work badly, you notice immediately and nothing burns.

This is almost the opposite of low-value. Churning through all those boring tickets that have been sitting in the backlog for years is enormously valuable. A dependency bump that finally removes unsupported version warnings. A refactor that moves a legacy module from 12% to 70% test coverage. None of it is glamorous.

Some more good starting points:

- refactors and renames
- cleanup and dead-code removal
- test scaffolding
- documentation and change summaries
- internal tooling that nobody really owns
- upgrades of deprecated dependencies

This is also where the org-level [hoard](/post/2026-04-25-hoarding-is-a-job-not-a-hobby/) gets seeded. The boring work is the work that produces the small, well-understood, already-survived examples that an agent can recombine from later. You build it by letting the tool do the boring stuff first, and keeping the bits that worked.

Starting small is how review muscles get stronger before they have to deal with high-stakes diffs. It's how the team actually finds out what the tools are good at on its own systems, instead of guessing based on someone else's blog post. Skip this step and you risk ending up in one of the two common failure modes: frozen or flooded.

One more benefit that is not obvious. The boring work is where downstream bottlenecks like review, audit and approval are least under pressure. Mistakes get caught by the existing processes without anyone having to invent new ones. And the whole exercise builds muscle memory that makes more ambitious work easier.

Boring work is the cheapest way to end up with a real sense of where the tools help and where they don't. And a seeded hoard that can start compounding.

Boring first.

Brave later.
