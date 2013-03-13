---
layout: post
title: "Applied Symbolic Execution with KLEE/LLVM"
description: ""
category:
tags: [clang, klee, llvm, sat, symbolic execution, valgrind]
---
{% include JB/setup %}

This is a follow up article to my <a href="http://martinsprogrammingblog.blogspot.com/2011/11/symbolic-execution.html">previous post</a> on symbolic execution. Here we look at <a href="http://klee.llvm.org/">KLEE</a> and <a href="http://llvm.org/">LLVM</a> in more detail, and present a potential practical application for a symbolic executor. We also discuss some of the limitations and drawbacks with this approach.

Our changes for KLEE and LLVM can be<a href="https://github.com/martintrojer/symbolic-execution">&nbsp;found on github</a>.

One limitation of symbolic execution (and dynamic code analysis in general) is that the code under analysis needs to be buildable and linkable. Thus, its harder to analyse sub systems (or snippets) than with a <a href="http://en.wikipedia.org/wiki/Lint_(software)">lint</a> tool. Another complication is that the symbolic executor’s virtual machine also needs to understand / model the system calls that the code uses. This makes the tool OS dependant, since you have to emulate all calls that "escapes" the executor. Cadar, Dunbar and Engler explains how this can be done for Linux analysing GNU coreutils in \[1\].

### Overview
KLEE is built on the LLVM Compiler infrastructure . LLVM defines a language independent intermediate code representation called LLVM-IR. KLEE contains a LLVM-IR interpreter (executor) capable of executing any program in LLVM-IR format. Further, KLEE allows you to mark certain areas of memory as symbolic, altering the execution to cover previously untouched code. At a very high level, KLEE creates an internal state for each instance of execution that runs a unique path. The points at which new states are created (forked) are typically branches where the condition is symbolic.

At any given time, KLEE can calculate concrete values for the symbolic memory that forces the code down a particular path. So, this technology can be used to generate a set for test vectors to drive full test coverage of any given piece of code.

In its current implementation, KLEE also checks for erroneous memory references and division by zero defects. &nbsp;Whenever a defect like this is found, KLEE will generate the concrete values that caused this defect. This means that in the set of defects KLEE finds, there will be no false positives.

As you can imagine, for a big program, a potential huge amount of states can be created, due to the CFG path explosion problem. This is one of the limitations of a symbolic executor.

KLEE makes heavy use of a component called STP \[2\], a purpose built constraint solver to evaluate the accumulated path constraints for the symbolic data. Solving the path constraints (and the Boolean SAT that they are converted to) is in fact a NP-complete problem, so the time it takes to find a solution in unbound. Fortunately the area of theorem provers and SAT solvers are under heavy research and progress is steady. STP is a combination of best in class SAT solver and many heuristics and optimizations tailored for the kind of constrains you see from executing code. It has been proven to be very effective.

Finally, while executing a program and building up a big set of states, KLEE has to determine which state to “schedule” next. Using an optimized searcher (KLEE terminology) is crucial to find the correct path and solving the problem you are interested in. KLEE provides a wide range of different searchers, optimized for different use cases like accomplishing maximum code coverage etc.

### Usage
The first step in analysing code with KLEE is to generate a single LLVM-IR executable containing the code you want to test, and the libraries it depends on. At the time of writing, there are 2 compilers available of generating LLVM-IR; llvm-gcc and clang . With llvm-gcc you can use all gcc front-ends (i.e. C, C++ etc) whereas clang offers support for C and objective-C (however, support for C++ is being worked on).

When you have compiled all your code (and supporting libraries) into LLVM-IR, you need to link them together into a single file (the command llvm-link can be used for this). KLEE can now execute and analyze the code in this binary.

However, in most cases this will only result in a normal execution of your code, since KLEE has to be told what parts of memory to treat as symbolic. It is also very likely that the code you are interested in is not reachable for the default main() function in this binary. More often than not, you will need to edit your code to remedy these issues. Fortunately, marking variables, arrays etc as symbolic is very easy, and only requires one added line to your code. Making the code of interest reachable is potentially harder. Basically you will need to call into the APIs/functions etc of the code of interest. If you have an existing test-suite, that’s a very good starting point, if not you need to write at least parts of it. It is also worthwhile to note that once a test suite exists, KLEE is a very powerful tool to be part of the regression testing, in order to automatically cover and look for certain defects in new code.

These manually aspects of setting up code for analysis is one of the drawbacks of symbolic executors like KLEE, limiting the level of automation you can apply. However, certain aspects of this manual work can be simplified \[6, 7\].

It is important that you compile all libraries into LLVM-IR alongside the code you want to test. The KLEE interpreter will resort to calling into “the environment” (i.e. the runtime / operating system) for all unresolved symbols in the LLVM-IR binary. This is fine for normal execution; however, KLEE cannot make calls outside the LLVM-IR binary with symbolic arguments. That will result in the termination of the execution state.

As a general rule, you only want to resort to calling outside the LLVM-IR environment at as a low level as possible (i.e. system calls). KLEE contains a model of the 40 most common linux systems calls, and can cope with calls to them since this model understand the semantics of the desired action well enough to generate the desired constraints. By creating your model at this level, you also limit the size of the model, and can keep the rest of the library and runtimes executed as normal by the KLEE interpreter.

### How we altered KLEE and LLVM
We mainly focused on the CFG path explosion problem during our study. The basic problem is to decide (using a searcher) what execution state to pick in order to reach the part of the code you are interested in. Picking a state by random or doing depth first search is very likely to “get lost” in the combinatorial explosion of possible paths in a large piece of code.

Depending of what your objective of running KLEE is, several approaches can he taken. If the goal is to maximize the code coverage, picking an execution state that will most likely lead to new code being covered can be taken. KLEE comes with a searcher that picks a state that is “closest” to uncovered code.

During our study we used the assumption that we would already know (several) areas of interests in the code under test. Let’s say we have an “Oracle” pin-pointing out areas of interest in code. This Oracle could for instance be a Static Code Analysis tool like Coverity, CodeScanner, Lint or even manual code review.

In this case, KLEE can be used to verify the findings of these Oracles, removing false positives and generating test cases for the true defects. It can also help answer the question under which circumstances a particular part of the code is executed.

Given a set of areas of interest (in the form of file names and line numbers) and a LLVM-IR binary of the code, we created a LLVM analysis pass that does the following;

1. Translates the file name, line number tuples to LLVM-IR basic blocks. _Explanation_; Given a number of potential problems given by an Oracale (in the form of filename and line number), the LLVM pass tries to map this to a specific basic block in the IR. The goal for the Klee searcher is now to "hit" that block and see whether it contains a defect.
2. Generates at set of N unique paths between the entry point the basic block from 1. _Explanation_; The set of basic blocks from 1/ is not enough information for the searcher to find a path. It also needs hints on potential basic blocks leading towards it. We used a naive approach using graph theory to generate a large number of paths connecting the root block to the block of interest. Most of these paths will probably be impossible, so it is still a rough approximation.

Dependant of the complexity of the code, this operation can take a long time.

We wrote a new searcher to be used when executing the same LLVM-IR binary in KLEE. This searcher selects states by matching them to the set of pre-generated paths and terminates when the all basic blocks of interest have been covered.

### Areas of improvement
A particularly hard problem for symbolic executors is how to reason with symbolic pointer dereferences. At its current implementation KLEE does an exhaustive search for each symbolic pointer deference. This implies checking if any solution of the pointer’s path constraint lies outside any allocated memory area. Though being correct, this is very expensive, and will lead to massive increase of states in a big program. There are suggested solutions to this problem; one that looks particularly promising is described in \[4\].

The annotation of the code to mark memory areas as symbolic&nbsp;(i.e. mechanically inserting the klee_make_symbolic) can be automated. See DART \[6\] for API analysis, or KleeNet \[7\] for ANTLR solution.

For supporting big real-world programs, more aggressive pruning of execution paths must be done.&nbsp;One very good way to do this is the record actual execution paths during program execution. This is done in both GodeFroid Dart \[3\] and <a href="http://bitblaze.cs.berkeley.edu/">Bitblaze</a>. They both use a emulated environment for non-symbolic execution (to track actual execution paths) which can then be fed into the symbolic executor for further analysis. Bitblaze uses <a href="http://wiki.qemu.org/Main_Page">QEMU</a> for this purpose, and is a nice practical hybrid of VMs and <a href="http://valgrind.org/">Valgrind</a> VEX-IR. <a href="http://code.google.com/p/avalanche/wiki/Avalanche">Avalanche</a> is a simpler solution relying solely on Valgrind.

### References
<ol>
<li>Cadar, Dunbar, Engler 2008<br />KLEE: Unassisted and Automatic Generation of High-Coverage Tests for Complex Systems Programs</li>
<li>Cadar, Ganesh, Pawlowski, Dill, Engler 2006<br />EXE: Automatically Generating Inputs of Death</li>
<li>GodeFroid, Nori, Rajamani, Tetali 2010<br />Compositional May-Must Program Analysis: Unleashing The Power of Alternation</li>
<li>Godefroid, Elkarablieh, Levin 2009<br />Precise Pointer Reasoning for Dynamic Test Generation</li>
<li>Godefroid, Levin, Molnar 2008<br />Automated Whitebox Fuzz Testing</li>
<li>Godefroid, Klarlund, Sen 2005<br />DART: Directed Automated Random Testing</li>
<li>Sasnauskas, Link, Alizai, Wehrle 2008<br />Bug Hunting in Sensor Network Applications</li>
</ol>
