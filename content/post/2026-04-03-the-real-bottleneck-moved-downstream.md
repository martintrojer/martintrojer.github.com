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

If you have spent time with the recent slate of AI agents (post Opus 4.5) you probably went through roughly the same mental journey as the rest of us:

> OMG, this thing is incredibly powerful, I can't believe it managed to fix that bug / implement that feature / create this tool that I've been meaning to write for years

Quickly followed by:

> OMG, we (software developers) are all cooked

If you keep going down that path, the next insight is the interesting one though. Yes, the cost of plausible code generation has collapsed. But the cost of delivering high quality, well tested and compliant software has not. Big companies still need software to clear a bunch of quality and legal bars, and none of that has really changed.

There is an important distinction here: output vs throughput. One engineer can now generate five changes in the time the org can safely review, test, approve and absorb one.

So now that code generation is cheaper, what are the downstream bottlenecks?

- Verification
  - review
  - tests
  - QA
- Trust
  - release governance (change approval)
  - integration risk
- Accountability
  - operational ownership

All of those are now under more pressure. The wall of diffs that any reviewer in a large software company is facing is real. The tension is pretty obvious: code producers feel newly powerful and start building more stuff, while the rest of the org pushes back or just tries to keep up.

Highly regulated industries like finance live in a complicated legal landscape, with stricter rules around auditability, compliance and sign-off. The missing artifact is often not code, it's defensible evidence.

The bottleneck moved downstream. That needs to be understood and managed. A lot of firms will mistake partial review automation for solving the problem, when really they have only sped up one checkpoint in a much longer trust pipeline.

AI did not eliminate the bottleneck. It made the old bottlenecks impossible to ignore by flooding them with plausible change.
