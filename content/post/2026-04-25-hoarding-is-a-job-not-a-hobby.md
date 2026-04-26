---
title: Hoarding is a job, not a hobby
date: "2026-04-25T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

Simon Willison's great collection of [Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/) includes an excellent post called "Hoard things you know how to do". The short version is that you should collect examples of how to solve problems, in code preferably, so you can show your AI agent later. One line in particular is worth pulling out:

> "The key idea here is that coding agents mean we only ever need to figure out a useful trick once."

That annoying little snippet you wrote two years ago to parse some weird in-house format, or to talk to that one internal API that has the worst docs in the company - it's worth more now than it used to be. Not because you will read it again, you probably won't. But because you can hand it to an agent and say: do it like this. The agent doesn't need to invent anything, it just needs to recombine. Recombination beats generation, and the hoard is what you recombine from.

It looks a bit different when you are not a single hacker with a pile of HTML tools, but an engineer inside a regulated company with thousands of other engineers, decades of legacy, and a controls regime sitting on top of all of it.

**First**, it changes what counts as a good hoard item.

In a personal hoard the bar is "it works." In a bank the bar is higher. Did this thing survive review. Did it pass audit. Did it actually run in production for a year without anyone getting paged at three in the morning. A snippet that worked once on a laptop is mildly interesting. A snippet that went through change control and is still running two years later is gold.

This is just the [trusted code](/post/2026-04-11-new-code-trusted-code-used-code/) idea showing up again. A hoard of clever-but-untested examples is worth less than a smaller hoard of examples that already earned trust. In regulated environments the second kind is what you want to feed to an agent, because it quietly carries "and this is the version that survived contact with the controls." That is a lot of context to hand the model for free.

**Second**, it changes who the hoard belongs to.

A personal hoard is great for personal work, sure. But it doesn't really scale to a place where the same internal integration gets done by twenty different teams across five different business units, and at least three of them are doing it slightly wrong. In that world the useful hoard is the team hoard. Or the org hoard. Approved integration patterns. Evidence templates. Hard-earned test setups that have been paid for in weeks of struggle. Short write-ups of the form "this is how we got X through change control, and here are the snippets that made it past each gate."

Point is, in an actually effective agent-native org, curating the hoard is a real job. Not a side hobby for whoever feels like it. Someone has to own it, someone has to keep it honest. The orgs that figure this out early get a compounding advantage. The ones that don't end up with a pile of plausible snippets and no real idea which ones to trust.

**Third**, it changes what counts as legacy.

Legacy is usually framed as a problem. Hoarding flips that. Legacy knowledge stops being the thing that quietly retires with someone, and starts being an asset you can externalise into something an agent can actually use. That is a real shift. The grizzled engineer who knows how the boundary actually works is not being replaced by the agent. They're the person who makes the agent useful in that part of the system. The agent is the new junior. The grizzled engineer is the senior who knows where the bodies are buried and can point at them on demand.

So the practical move here is small and a bit boring really. Start collecting. Not just code. Patterns. Approved examples. Evidence templates. Short retro notes on how a tricky change actually got through. Anything that captures "this worked and survived." Put it somewhere an agent can read it.

In personal hoards the slogan is "things you know how to do."

In regulated hoards the slogan is sharper.

Things that earned trust.

That is the kind of hoard worth feeding to an agent.

And it is the kind of hoard that turns the legacy nobody wanted to touch into the leverage nobody else has.
