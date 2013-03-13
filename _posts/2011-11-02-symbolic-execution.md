---
layout: post
title: "Symbolic Execution"
description: ""
category: software
tags: [klee, llvm, sat, symbolic execution]
---
{% include JB/setup %}

A while back I worked with a colleague (Philippe Gabriel) on a research project looking into automating defect finding and improving over-all test coverage. The main defect of concern at that particular time was null pointer dereferences, which could cause system wide crashes. We looked at many different strategies and tools (both free and commercial). What really spiked my interest was a field of research called "Symbolic Execution". Here's the elevator pitch; what if you had a tool that automatically found "nasty bugs" by analysing your source code, with very little or no false positives, and produced the input stimuli to provoke that bug?

[Dawson Engler](http://www.stanford.edu/~engler/) at Stanford along with [Patrice Godefroid](http://research.microsoft.com/en-us/um/people/pg/) at Microsoft Research have made great contributions to this field of research. Their detailed papers are a thrilling read.

This article contains some background information about what symbolic execution is, and in future posts I'll explain how this can be applied in practice (using frameworks such as <a href="http://llvm.org/">LLVM</a> and <a href="http://klee.llvm.org/">klee</a>).

### Introduction
Static Code Analysis has made a lot of progress in recent years, and can now be applied to large real-world code bases and generate valid results. One of the key metrics is the ratio between actual defects to the false positives. Optimizing this ratio is a very hard problem to solve in includes a lot of heuristics, optimization and tweaking. One of the biggest benefits of Static Code Analysis is that it is done by analyzing the source code itself. There is no requirement to build, link and run the code in question, analyzing “snippets” of code perfectly valid.

Unlike a Static Code Analysis tools, a symbolic executor executes the code under test in a “sandbox” or virtual machine. The main difference with normal execution is that some input are treated as symbolic (allowed to be “anything”), and for the code dependent on symbolic input the symbolic executor builds up boolean expressions (path constraints) used to force the code down previously unexplored paths.

### Symbolic Execution
With Symbolic Execution, the program is "executed" in an abstracted manner. Let’s describe this process, with the following code fragment;
<script src="https://gist.github.com/1698165.js?file=example1.c"> </script>
Say we want to insure that func always returns a valid (non-null) pointer.

### Control Flow Graph
The first step in symbolic execution is to generate a Control Flow Graph or CFG. A CFG is an abstracted representation of the code in the form of a directed graph. Each node is a "basic block" terminated in a conditional (here an if statement). Each edge is a boolean "truth value" for the condition.
<p align="center"><img src="/assets/images/symbolic/cfg.png"></p>

Once the code is expressed in this way it is easier to see the paths of execution. Note that CFGs are not specific to Symbolic Execution; any compiler generates a CFG when building the code, as this representation lends itself well to optimization techniques.

### Analysing the CFG with symbolic values
With Symbolic execution we are interested in finding feasible paths which result in "bad things" happening. In this case we are interested in finding path(s) that lead to returning p without being allocated. We are interested to understand how the value of p changes, so taking the same CFG we state the value of p at each node. Or more precisely, we state the symbolic value of p, we do not actually care about which specific memory location p points to. Instead we only care whether p is null or non-null.
<p align="center"><img src="/assets/images/symbolic/cfg-annotated.png"></p>

Note that we also draw implicit code path, as they lead to different symbolic value of p. Now with the CFG rewritten like this, it is trivial to see that there is indeed a path that leads to returning p without prior initialization. This simple example illustrates in practice 2 basic techniques;
* Transformation to CFG
* Reasoning on symbolic values

### Scalability and Accuracy
Anyone designing a "symbolic tool" is faced with many hard problems. At a very high level, the problems can be put in one of these 2 categories;
* Scalability / speed of analysis, because any non trivial function has a large number of paths.<br />Ideally we want the tool to finish before the end of the universe.
* Accuracy, because not all these paths are actually feasible and any defect reported along an infeasible path is a false positive.

If you look a much simpler "lint" tool, it's usability is greatly reduced by the cheer&nbsp;amount&nbsp;of "garbage" it produces. An ideal tool will only report "real" errors, and as you will see further on, test vectors that triggers the error.

### Scalability and Inter-Procedural analysis
The scalability problem is compounded by the fact that for any non trivial analysis, we cannot limit the analysis to the paths contained within a single function. For instance, in the previous example, it doesn't matter that func returns a null pointer if any code that calls func actually checks for this. For a meaningful analysis we need to follow the path until the pointer is actually used. In order to check that, we need to analyse paths going in and out of the function (inter-procedural analysis). The upside of doing inter-procedural analysis is that it increases the accuracy. The downside is that it&nbsp;exponentially&nbsp;increases the number of paths to analyse. Taking into account inter-procedural analysis, a real life a CFG is more likely to look like:
<p align="center"><img src="/assets/images/symbolic/cfg-real.png"></p>

A symbolic execution engine that would naively enumerate paths exhaustively through this CFG would never complete. Knowing how to prune the CFG and identifying the small number of "interesting" paths is a very lively domain of academic research and a large bibliography exists on the topic. Heuristics to limit the path explosion problem come from either graph theory or are based on inferring more information from the context of execution.

### Accuracy
An added complication that comes from having to analyze long path for actually finding anything interesting is that the "Path Conditions" along the paths are non satisfiable. Let's examine this fact in greater detail, as this leads us to introducing another big idea that underlines symbolic execution.

### Path Condition
Let's revisit our previous example and explain what path conditions are. We now rewrite the CFG with the truth value for all the conditions that we encountered along given paths. The path condition is the boolean equation that synthesises the truth values for conditional expressions we encountered at each node.
<p align="center"><img src="/assets/images/symbolic/cfg-annotated2.png"></p>

Here for the path of interest (leading to a null p), this expression is: ```x*y==0 && y!=0```. Hence we can now associate a set of Boolean equations with each edges along a given path. In the example above, we can now state,  ```x*y==0 && y!=0``` implies that ```p==0```

### Inter-Procedural analysis and Path Condition
Now that we know what path conditions are, let's see how we use these to solve the accuracy problem. We need to find out whether the path that is feasible in the narrow context of this function is actually valid in the larger context of a program, (i.e. when you perform interprocedural analysis). For instance, we might find that on all the paths containing call to this function, prior to the call there is a ASSERT statement that checks: ```x!=0```
<script src="https://gist.github.com/1698165.js?file=example2.c"> </script>
The path condition has become: ```x*y!=0 && y!=0 && x!=0```. It is clear to see that this Boolean equation cannot be solved, or according to the lingo there is no assignment of Boolean terms that satisfy this equation. This is otherwise known as the <a href="http://en.wikipedia.org/wiki/Boolean_satisfiability_problem">Boolean Satisfiability Problem</a>.

### Boolean SAT applied to Symbolic Execution
Now, there's good news and bad news...

The bad news is that this is an NP Complete problem, or in other words a fiendishly complex problem to solve, with not upper limit to it's running complexity. This is not really apparent in this simple example, but any non-trivial path will be summarized by a Path Condition with 100s of terms, which means that simply iterating through possible assignment for Boolean variables would never complete.

The good news is that there are solutions for it. Most notably, solving Boolean equation with large number of terms is something that the VLSI industry has been doing for years and have developed fairly efficient software along the way, aka SAT solvers. In fact there is a surprisingly large number of people constantly refining algorithms for their SAT solvers to solve ever larger boolean equation ever faster who race them every year.<br />
As a result all modern symbolic execution engines can now incorporate them. A boolean SAT solver would tell you in no time that ```x*y!=0 && y!=0 && x!=0``` is indeed unsatisfiable and that there is no point reporting such a defect which is clearly a false positive.