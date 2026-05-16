---
title: Cognitive debt is the real tax
date: "2026-04-12T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

In many software companies the percentage of AI generated code is steadily increasing. This accelerating code churn is driven by human-in-the-loop AI agents but also fully automated AI cleanups and codemods. Many developers feel more productive and their number of landed changes has gone up. The shipped code seems to work ok, and if not, the AI agent can often root cause and fix bugs quickly.

However, the increased velocity made possible by AI is often inversely proportional to the team's understanding of the codebase. What's happening right now in many large codebases is that teams keep shipping while quietly losing the plot.

Working code isn't the same as understood code. A system can appear to behave. Tests can pass. None of that means the team has a real shared understanding of what the code is doing, why it was written that way, or what will break when it changes. "Context is king" for both AI and humans: the less we have, the less effective we are.

And new code isn't the same as trusted code. Generated code can look clean, sensible and well-structured. It can even survive real review. But there is only so much that can be caught in a review anyway. Trust comes from seeing how the thing behaves when reality gets involved.

And trusted code isn't the same as proven code. Proven code has survived contact with reality. It has been lived with. That kind of code carries operational memory in a way that fresh output doesn't.

So what is this new cognitive debt that we are sleepwalking into?

- nobody knows why a decision was made
- nobody really knows how a subsystem behaves until something goes wrong
- review quality drops because nobody has a real mental model of the change
- reviewers start resenting the work because the code was cheap to generate but expensive to properly check
- changes start to feel scary, even when they look small
- teams stop knowing what is genuinely trusted and what merely looks polished
- code starts piling up faster than it is exercised or understood

Teams can keep shipping while understanding less. Review can keep happening while trust gets weaker. More code can land while less of it is understood.

You do not pay the tax immediately. At first it looks like speed. The bill comes later. It shows up when review becomes performative. When nobody can explain why something works the way it does.

Cognitive debt is the real tax.
