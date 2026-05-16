---
title: The bottlenecks moved downstream
date: "2026-04-03T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

If you have spent some time with the recent slate of AI agents (post Opus 4.5) you probably went through roughly the same mental journey as the rest of us:

> This thing is incredibly powerful, I can't believe it managed to fix that bug / implement that feature / create this tool that I've been meaning to write for years

Quickly followed by:

> We (software developers) are all cooked

If you keep going down that path, the next couple of insights are more interesting. Yes, everyone (including non devs) has a code-gun now and can produce large amounts of plausible-looking code. But while it looks like really good code, with large amounts of tests, it probably doesn't work, at least not in the way that you would expect if it was written by hand. If you start using it, you will quickly find many problems with it.

Another way of putting this is that while the cost of code generation has collapsed, the cost of delivering high quality, well tested and compliant software has not.

There is an important distinction here: output vs throughput. One engineer can now generate five changes in the time the org can safely review, test, approve and land one.

What are some of these downstream bottlenecks that are now much more obvious?

- Verification (review, tests, QA)
- Trust (release governance, change approval, integration risk)
- Accountability (ownership)

All of those are now under more pressure. The 'wall of diffs' that any reviewer in a large software company is facing is a real problem. The tension is pretty obvious: devs start building more stuff, while the rest of the org pushes back or just tries to keep up.

It's a common mistake to think that adding partial review automation to your CI solves the problem, when really you have only sped up one checkpoint in a much longer pipeline. The bottlenecks moved downstream, and there are plenty of them.

Take highly regulated industries like finance for example. They live in a complicated legal landscape, with stricter rules around auditability and compliance. How do they deal this wave of clanker slop? Somebody still has to sign off on these products, with real legal exposure.

AI did not eliminate the bottlenecks.

It made the old bottlenecks impossible to ignore by flooding them with plausible-looking diffs.
