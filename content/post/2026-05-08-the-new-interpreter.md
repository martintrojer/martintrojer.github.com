---
title: The new interpreter
date: "2026-05-09T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

[Andrej Karpathy](https://karpathy.ai/) has a useful framing for what shifted. We moved from handwritten code fed to a compiler to context fed to a much more general interpreter. The context window is the program and the AI is the interpreter.

The interpreter is new. The cost of producing plausible programs collapsed because the new interpreter is vastly more general than a compiler.

But if the program is now a prompt and a probabilistic runtime, what artifacts do we keep around?

Here are 3 candidates I can think of:

The prompt is the most obvious. But prompts are vague by default. Can we fix this by turning prompts into detailed specs with proper change control? The problem is that we are now basically writing code again, only with all the ambiguities of natural language.

The generated code is the another. But the generated code is the output of a probabilistic interpreter. The same prompt and the same model can produce different code on different tries. Generated code looks like a deterministic artifact but it really isn't. The code is no longer the program.

The third candidate is the whole journey from intent to landed change: the idea, the spec, rejected proposals, the generated implementation, the review, the tests, the operational evidence, the change record, the sign-off. This is the only one that works.

To summarize the whole series, through the 'new interpreter' lens:

[New expectations](/post/2026-03-28-something-has-changed/) because the interpreter changed. The [bottlenecks moved downstream](/post/2026-04-03-the-bottlenecks-moved-downstream/) because cheap interpretation floods the delivery pipeline. [Proof of use](/post/2026-04-11-new-code-trusted-code-proven-code/) is now more valuable than new interpreter output. [Cognitive debt](/post/2026-04-12-cognitive-debt-is-the-real-tax/) is the failure mode when the interpreter moves faster than our understanding. [Intent](/post/2026-04-18-intent-is-becoming-a-first-class-artifact/) is a first-class artifact because the generated code is not deterministic. The [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/) is the human role that survives. [The hoard](/post/2026-04-25-hoarding-is-a-job-not-a-hobby/) is the new program library we feed the interpreter. [Boring work first](/post/2026-04-26-boring-work-first/) is how you learn to operate it without betting the house. [The divide](/post/2026-05-04-no-pain-no-trust/) is between teams that can increase speed while staying honest.

Karpathy distills it perfectly:

> You can outsource your thinking, but you can't outsource your understanding.

Without understanding, there is no trust.
