---
categories:
- software
date: "2011-10-30T00:00:00Z"
description: ""
tags:
- sicp
title: What is software?
---
{% include JB/setup %}

Having gained experience through numerous software projects and collaborations with diverse individuals, I've observed a recurring issue: a lack of understanding regarding the nature and process of software development. Surprisingly, even among developers, there persists a belief that seniority alone enables one to design and plan a problem, leaving less experienced developers to implement it. Some individuals still equate software development to assembly line production in the automotive industry.


In chapter 1 of "Structure and Interpretation of Computer Programs" [SICP](http://mitpress.mit.edu/sicp/), Abelsson and Sussman describe a concept they call the "sorcerer's spirit"

> A computational process is indeed much like a sorcerer's idea of a spirit. It cannot be seen or touched. It is not composed of matter at all. However, it is very real. It can perform intellectual work. It can answer questions. It can affect the world by disbursing money at a bank or by controlling a robot arm in a factory. The programs we use to conjure processes are like a sorcerer's spells. They are carefully composed from symbolic expressions in arcane and esoteric _programming languages_ that prescribe the tasks we want our processes to perform.

Years ago, I encountered an enlightening presentation by [Brian Cantrill](http://dtrace.org/blogs/bmc/), who was then a DTrace developer at Sun Microsystems. Although the entire presentation is captivating (DTrace is truly remarkable, by the way), the initial "philosophical" segment left a lasting impression and shed light on the essence of software. Here is a transcript of the first part, and the full presentation can be found at [link](http://www.youtube.com/watch?v=TgmA48fILq8&feature=gv)

> Software is really different, it's unique. It is different from everything else that we (as humans) have made. And when we try to draw analogies between software and other things we built, those analogies always come apart, the are always loaded with fallacies. So what is it that makes software so special? <...>

> Here's the paradox; is software information or is software machine? The answer is that it's both. Like nothing else, in software the blueprints are the machine. In software, once you designed the thing you've built it, it is the machine. That's why the waterfall model is fundamentally flawed. This idea that you can design the design before you design it, which is what the waterfall model is essentially saying, is flawed. <...>

> This is a point that was hit home to me when I (Brian) first came to Sun, and helped develop the ZFS file systems with Jeff Bonwick. We are in Jeff's office and we had the source code up in one window and the debugger up in another. And all of a sudden Jeff steps away from his keyboard and says "Does it bother you what none of this actually exists? Where are looking at the source code over there, and the debugger there, and we think that we are looking at a thing. But we are not looking at a thing, we see an representation of an abstraction." This (the software in the debugger) does not exist anymore that your name exists. "Your name doesn't exist, we just made it up, doesn't it bother you?" <...>

> We can't see software, what does running software look like? It doesn't look like anything. It doesn't emit heat, it doesn't attract mass, it's not physical. It's a mathematical machine. And that is the problem with all the thinking about software engineering has come from the gentlemanly per suits of of civil engineering. Men in top hats and suits would employ millions to build bridges and dams. It's very romantic but has no analogy in software. That is not the way software is built. Software is more like a bunch of people sitting around trying to prove theorems.
