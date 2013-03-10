---
layout: post
title: "What is software?"
description: ""
category:
tags: [sicp, software]
---
{% include JB/setup %}

Having worked on many software projects and with a lot of different people, one thing that strikes me is the lack of understanding of what software is and how it's created. Even among us developers, there's is still this belief lurking, that if you senior enough, you can design and size a problem, before you hand it over to some less senior developers to implement. (Some) people still believe that building software is the same as building cars on an assembly line.

Abelsson and Sussman speaks about a "sorcerer's spirit" in chapter 1 of [SICP](http://mitpress.mit.edu/sicp/);

> A computational process is indeed much like a sorcerer's idea of a spirit. It cannot be seen or touched. It is not composed of matter at all. However, it is very real. It can perform intellectual work. It can answer questions. It can affect the world by disbursing money at a bank or by controlling a robot arm in a factory. The programs we use to conjure processes are like a sorcerer's spells. They are carefully composed from symbolic expressions in arcane and esoteric programming languages that prescribe the tasks we want our processes to perform.

Some years back I say the great presentation by [Brian Cantrill](http://dtrace.org/blogs/bmc/) (then DTrace developer at Sun). The whole presentation is really interesting (DTrace is awesome btw), but the first "philosophical" part really stuck with me, and goes some ways to explain what software is. Here's a transcript of the first part, and the full presentation is [here](http://www.youtube.com/watch?v=TgmA48fILq8&feature=gv).

> Software is really different, it's unique. It is different from everything else that we (as humans) have made. And when we try to draw analogies between software and other things we built, those analogies always come apart, the are always loaded with fallacies. So what is it that makes software so special? <...>

> Here's the paradox; is software information or is software machine? The answer is that it's both. Like nothing else, in software the blueprints are the machine. In software, once you designed the thing you've built it, it is the machine. That's why the waterfall model is fundamentally flawed. This idea that you can design the design before you design it, which is what the waterfall model is essentially saying, is flawed. <...>

> This is a point that was hit home to me when I (Brian) first came to Sun, and helped develop the ZFS file systems with Jeff Bonwick. We are in Jeff's office and we had the source code up in one window and the debugger up in another. And all of a sudden Jeff steps away from his keyboard and says "Does it bother you what none of this actually exists? Where are looking at the source code over there, and the debugger there, and we think that we are looking at a thing. But we are not looking at a thing, we see an representation of an abstraction." This (the software in the debugger) does not exist anymore that your name exists. "Your name doesn't exist, we just made it up, doesn't it bother you?" <...>

> We can't see software, what does running software look like? It doesn't look like anything. It doesn't emit heat, it doesn't attract mass, it's not physical. It's a mathematical machine. And that is the problem with all the thinking about software engineering has come from the gentlemanly per suits of of civil engineering. Men in top hats and suits would employ millions to build bridges and dams. It's very romantic but has no analogy in software. That is not the way software is built. Software is more like a bunch of people sitting around trying to prove theorems.
