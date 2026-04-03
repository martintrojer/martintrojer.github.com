---
title: The real bottleneck moved downstream
date: "2026-04-03T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

If you ever tried the recent slate of AI agents (post Opus 4.5) you probably went through a mental journey that is remarkably similar for all of us:

> OMG, this thing is incredibly powerful, I can't believe it managed to fix that bug / implement that feature / create this tool that I've been meaning to write for years

Quickly followed by:

> OMG, we (software developers) are all cooked

If you carry on down that path, the next insight is more interesting. Yes, the cost/effort of plausible code generation has collapsed. But, the cost of delivering high quality, well tested and compliant software has not. Corporations rely on their software passing certain quality and legal bars, and none of these have fundamentally changed.

There is an important distinction here: output vs throughput. One engineer can now generate 5 changes in the time the org can safely review, test, approve and absorb 1.

So now that code generation is cheaper, what are the new 'downstream' bottlenecks?

- Verification
    - review
    - tests
    - QA
- Trust
    - release governance (change approval)
    - integration risk
- Accountability
    - operational ownership

All of those are now experiencing increasing pressure. The "wall of diffs" that any code reviewer in a large software company is facing is real. The tension here is clear, code producers feeling empowered and motivated build new "stuff", the rest of the organization pushing back / trying to keep up.

Highly regulated industries like finance live in a complicated legal landscape, with stricter rules around auditability, compliance and sign-off. The missing artifact is often not code but defensible evidence.

The bottleneck moved downstream, it's critical that this is understood and managed. Many firms will mistake partial review automation for solving the problem, when in reality they have only sped up one checkpoint in a much longer trust pipeline.

AI did not eliminate the bottleneck. It made the old bottlenecks impossible to ignore by flooding them with plausible change.
