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

The all-or-nothing stance that dominates AI discourse is not helpful. Neither of the extreme positions "we don't use AI here" and "we let Claude yolo all our code" are productive.  Both stances are basically positions taken to avoid having to think about the actual problem: how let a powerful new tool into an establish org / codebase without either pretending it doesn't exist or using it and breaking the code with hundreds of invested man-years?

Turns out the answer is obvious, start with the work that is boring, low-risk and easy to review.

And worth being clear what "low-risk" actually means, because it gets confused with "low value" all the time. Low-risk here means tedious. Conceptually simple. Small blast radius. Easy to review. The property you're after is this: if the AI does the work badly, you notice immediately and nothing burns.

Nothing about that is the same as low value. A boring refactor that finally happens after sitting in the backlog for two years is enormously valuable. A first draft of control evidence that a human then sharpens is enormously valuable. A test scaffold that gets a legacy module from 12% coverage to 70% coverage is enormously valuable. None of it is glamorous. All of it moves the org forward.

The concrete starting points are not exotic:

- refactors and renames
- cleanup and dead-code removal
- test scaffolding
- documentation and change summaries
- first drafts of control evidence
- internal tooling that nobody depends on for revenue
- upgrades of deprecated dependencies, after the test coverage has been improved

This is also where the org-level [hoard](/post/2026-04-25-hoarding-is-a-job-not-a-hobby/) gets seeded, almost as a side effect. The boring work is the work that produces the small, well-understood, already-survived examples that an agent can recombine from later. You can't really build that hoard out of thin air. You build it by letting the tool do the boring stuff first, and keeping the bits that worked.

None of this is cowardice though, and it's worth saying that out loud because the "start small" framing usually gets dismissed as it. It isn't. It's how review muscles get stronger before they have to deal with high-stakes diffs. It's how the org actually finds out what the tools are good at on its own systems, with its own conventions, against its own controls — instead of guessing based on someone else's blog post. Skip this step and you end up in one of the two failure modes from the top of the post. Frozen, or flooded.

One more benefit that is not obvious. The boring work is also where downstream bottlenecks like review, audit and approval are *least* under pressure. Cheap iterations on cheap work. Mistakes get caught by the existing processes without anyone having to invent new ones. And the whole exercise builds the kind of evidence trail that makes the harder adoption conversations later much easier. "We tried it here first, here is what happened, here is what we kept, here is what we threw away".

So starting at the edges isn't a retreat. It's the cheapest way to learn.

The teams that get good at this don't end up timid. They end up with a real sense of where the tools help and where they don't. And with the proof to show the people who weren't in the room. And a seeded hoard that can start compounding.

Boring first.

Brave later.
