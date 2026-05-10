---
title: The interpreter changed
date: "2026-05-09T00:00:00Z"
description: ""
tags:
  - ai
  - software
  - productivity
categories:
  - software
---

[Andrej Karpathy](https://karpathy.ai/) has a useful framing for what shifted. We moved from handwritten code fed to a compiler to context fed to a much more general interpreter. The context window *is* the program, and the LLM is the interpreter.

That is the cleanest name I have heard for what changed. The interpreter is new. The cost of producing a plausible program collapsed because the new interpreter is wildly more general than a compiler.

But this leaves a question. If the program is now a prompt and the runtime is probabilistic, what is the durable, defensible thing? What is the artifact you can show an auditor a year from now and stand behind?

Three candidates, and only one of them really survives.

The prompt is the most obvious candidate, because the prompt is now part of the program. But prompts are disposable by default. They live in chat sessions, in scratch files, in agent memory that gets garbage-collected. They have no versioning, no review, no retention. You can fix this — turn prompts into checked-in spec artifacts with proper change control — but the moment you do, you are basically writing code again, just in English, with all the ambiguities of natural language.

The generated code is the next candidate, because the code is what runs. But the generated code is the output of a probabilistic interpreter from a probabilistic input. The same prompt and the same model can produce different code on different days. The code has the shape of a deterministic artifact, but the path that produced it does not. You can pin the model, pin the prompt, vendor the dependencies — but you are now defending the code, not the program. The program is still the prompt above it.

The third candidate is the path from intent to trusted change. The whole journey: the intent, the spec, the generated implementation, the review, the tests, the operational evidence, the change record, the accountable owner. It is the only candidate that already has the governance, evidence and accountability. The new interpreter didn't kill it. It just made it cheaper to feed.

So the whole series, refracted through that interpreter shift:

The [baseline changed](/post/2026-03-28-the-baseline-changed/) because the interpreter changed. The [bottleneck moved downstream](/post/2026-04-03-the-real-bottleneck-moved-downstream/) because cheap interpretation is not cheap delivery. [Regulation](/post/2026-04-11-new-code-trusted-code-proven-code/) did not change but the pressure on it did. [Cognitive debt](/post/2026-04-12-cognitive-debt-is-the-real-tax/) is the natural failure mode when the interpreter moves faster than your understanding. [Intent](/post/2026-04-18-intent-is-becoming-a-first-class-artifact/) is a first-class artifact because the prompt is now part of the program. The [engineer of trusted change](/post/2026-04-19-the-engineer-of-trusted-change/) is the human role that survives the shift. The [hoard](/post/2026-04-25-hoarding-is-a-job-not-a-hobby/) is the regulated-systems version of the program library the new interpreter implies. [Boring work first](/post/2026-04-26-boring-work-first/) is how you learn to operate it without betting the release. [The divide](/post/2026-05-04-no-pain-no-trust/) is between teams that can increase speed without losing the back-pressure that kept the codebase honest.

Karpathy himself put the closing line on it.

> **You can outsource your thinking, but you can't outsource your understanding.**

Without understanding, there is no trust.
