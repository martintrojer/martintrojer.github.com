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

In many software companies the percentage of AI generated code is going up fast. The code churn is accelerating because of both developer-led features and fully automated AI cleanups and codemods. Many developers feel much more productive and their number of landed changes has gone up a lot. The shipped code seems to work ok, and if not the AI agent can often root cause and fix bugs quickly.

AI makes it much easier to outpace shared understanding of the codebase. What is happening now in many large codebases is that teams keep shipping while quietly losing the plot.

Working code is not the same as understood code. A system can appear to behave. Tests can pass. None of that means the team has a real shared understanding of what the code is doing, why it was written that way, or what will break when it changes.

And new code is not the same as trusted code. Generated code can look clean, sensible and well-structured. It can even survive review. That still does not mean people really trust it. Trust comes from scrutiny, repetition, and seeing how the thing behaves when reality gets involved.

And trusted code is not the same as used code. Used code has survived contact with reality. It has been lived with. That kind of code carries operational memory in a way that fresh output does not.

What concretely is this new cognitive debt that we are sleepwalking into?

- nobody knows why a decision was made anymore, only that the code exists
- nobody really knows how a subsystem behaves until something goes wrong
- review quality drops because nobody has a real mental model of the change
- reviewers start resenting the work because the code was cheap to generate but expensive to properly check
- changes start to feel scary, even when they look small
- teams stop knowing what is genuinely trusted and what merely looks polished
- code starts piling up faster than it is exercised, retained, or understood

Teams can keep shipping while understanding less. Review can keep happening while trust gets weaker. More code can land while less of it is really used, retained, or understood.

The tax does not get paid immediately. At first it looks like speed. The bill comes later. It shows up when small changes start to feel risky. When review becomes performative. When nobody can explain why something works the way it does. When the safe move becomes hesitation, rework, or touching nothing at all.

That is why cognitive debt is the real tax.
