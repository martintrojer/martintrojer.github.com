---
categories:
- software
date: "2011-11-10T00:00:00Z"
description: ""
tags:
- clang
- klee
- llvm
- sat
- symbolic execution
- valgrind
title: Applied Symbolic Execution with KLEE/LLVM
---

This article serves as a follow-up to my previous post on symbolic execution, which can be found [here]({{< ref "2011-11-02-symbolic-execution.md" >}}). In this article, we will delve deeper into the details of KLEE and LLVM, discussing a potential practical application for a symbolic executor. We will also address some limitations and drawbacks associated with this approach.

If you're interested in the changes we made for KLEE and LLVM, you can find them on [GitHub](https://github.com/martintrojer/symbolic-execution).

One limitation of symbolic execution, as well as dynamic code analysis in general, is that the code under analysis needs to be buildable and linkable. Consequently, it is more challenging to analyze subsystems or code snippets compared to using a [lint tool](http://en.wikipedia.org/wiki/Lint_(software)). Another complication arises from the fact that the symbolic executor's virtual machine must also comprehend and model the system calls used by the code. This makes the tool OS-dependent, as it requires emulating all calls that "escape" the executor. Cadar, Dunbar, and Engler explain how this can be achieved for Linux by analyzing GNU coreutils in \[1\].

### Overview
KLEE is built on the LLVM Compiler infrastructure, which defines a language-independent intermediate code representation known as LLVM-IR. KLEE features an LLVM-IR interpreter (executor) capable of executing any program in LLVM-IR format. Additionally, KLEE allows for marking certain areas of memory as symbolic, thereby modifying the execution to cover previously unexplored code. At a high level, KLEE creates an internal state for each execution instance, representing a unique path. The creation of new states (forks) typically occurs at branching points where the condition is symbolic.

At any given time, KLEE can calculate concrete values for symbolic memory, thereby directing the code along a specific path. This technology can be used to generate a set of test vectors that drive full test coverage for any given piece of code.

In its current implementation, KLEE also checks for erroneous memory references and division by zero defects. When such a defect is found, KLEE generates the concrete values that caused the defect. As a result, the set of defects discovered by KLEE contains no false positives.

For a large program, a significant number of states can be created, leading to the CFG (Control Flow Graph) path explosion problem. This is one of the limitations of a symbolic executor.

KLEE heavily utilizes a component called STP \[2\], a purpose-built constraint solver used to evaluate the accumulated path constraints for symbolic data. Solving the path constraints (and the Boolean SAT problems they are converted into) is an NP-complete problem. The time required to find a solution is unbounded. However, research in theorem provers and SAT solvers is actively progressing, and STP has proven to be highly effective, combining a state-of-the-art SAT solver with numerous heuristics and optimizations tailored for executing code.

Finally, while executing a program and generating a large set of states, KLEE needs to determine the next state to "schedule." Employing an optimized searcher (in KLEE terminology) is crucial for finding the correct path and solving the desired problem. KLEE provides a wide range of different searchers, each optimized for different use cases, such as achieving maximum code coverage.

### Usage
The first step in analyzing code with KLEE is to generate a single LLVM-IR executable that includes the code you want to test and the required libraries. Currently, there are two compilers available for generating LLVM-IR: llvm-gcc and clang. llvm-gcc supports all GCC front-ends (e.g., C, C++), while clang offers support for C and Objective-C (with ongoing support for C++).

Once you have compiled all your code and libraries into LLVM-IR, you need to link them together into a single file using the llvm-link command. KLEE can then execute and analyze the code within this binary.

However, in most cases, this will result in normal code execution, as KLEE needs to be informed about the parts of memory to treat as symbolic. Additionally, the code of interest is often not reachable from the default main() function in the binary. In such cases, modifications to the code are necessary. Fortunately, marking variables, arrays, etc., as symbolic is straightforward and only requires adding a single line to your code. Making the code of interest reachable can be more challenging. Typically, you will need to call into the APIs/functions of the code of interest. If you already have a test suite, it can serve as a good starting point. Otherwise, you will need to write at least a portion of it. It is worth noting that once a test suite exists, KLEE becomes a powerful tool for regression testing, automatically covering and searching for specific defects in new code.

The manual aspects of setting up code for analysis are among the drawbacks of symbolic executors like KLEE, as they limit the level of automation that can be applied. However, certain aspects of this manual work can be simplified \[6, 7\].

It is important to compile all libraries into LLVM-IR alongside the code you want to test. The KLEE interpreter relies on calling "the environment" (i.e., the runtime/operating system) for any unresolved symbols in the LLVM-IR binary. While this is suitable for normal execution, KLEE cannot make calls outside the LLVM-IR binary with symbolic arguments. Such calls would terminate the execution state.

As a general rule, it is advisable to minimize calls outside the LLVM-IR environment to the lowest possible level (e.g., system calls). KLEE includes a model for the 40 most common Linux system calls and can handle calls to them, as this model understands the semantics of the desired actions well enough to generate the necessary constraints. By creating the model at this level, the size of the model is limited, and the rest of the library and runtimes are executed as usual by the KLEE interpreter.

### How we altered KLEE and LLVM
During our study, we primarily focused on addressing the CFG path explosion problem. The fundamental challenge is to decide (using a searcher) which execution state to select in order to reach the desired code section. Randomly selecting a state or employing a depth-first search is likely to get lost in the combinatorial explosion of possible paths within large codebases.

Based on the assumption that we would already know several areas of interest within the code under test, we developed a solution. Let's imagine an "Oracle" that identifies these areas of interest within the code, such as a Static Code Analysis tool like Coverity, CodeScanner, Lint, or even manual code review.

In this case, KLEE can be used to verify the findings of these Oracles, eliminating false positives and generating test cases for true defects. It can also help answer questions about the circumstances under which a particular part of the code is executed.

Given a set of areas of interest (identified by file names and line numbers) and an LLVM-IR binary of the code, we created an LLVM analysis pass that performs the following steps:

1. Translates the file name and line number tuples to LLVM-IR basic blocks. This translation maps the potential problems identified by an Oracle (in the form of file name and line number) to specific basic blocks within the IR. The goal for the KLEE searcher is then to "hit" that block and determine if it contains a defect.
2. Generates a set of N unique paths between the entry point and the basic block identified in step 1. To aid the searcher in finding a path, the set of basic blocks from step 1 is not sufficient. Additional hints about potential basic blocks leading to the target are required. We used a simple graph theory approach to generate numerous paths connecting the root block to the target block. Many of these paths may be infeasible, so it remains a rough approximation.

The execution time of this operation depends on the complexity of the code.

We also developed a new searcher to be used when executing the same LLVM-IR binary in KLEE. This searcher selects states by matching them to the pre-generated paths and terminates when all the desired basic blocks have been covered.

### Areas of improvement
A particularly hard problem for symbolic executors is how to reason with symbolic pointer dereferences. In its current implementation, KLEE does an exhaustive search for each symbolic pointer dereference. This implies checking if any solution of the pointer's path constraint lies outside any allocated memory area. Though being correct, this is very expensive and will lead to a massive increase of states in a big program. There are suggested solutions to this problem; one that looks particularly promising is described in \[4\].

The annotation of the code to mark memory areas as symbolic (i.e. mechanically inserting the klee_make_symbolic) can be automated. See DART \[6\] for API analysis, or KleeNet \[7\] for ANTLR solution.

For supporting big real-world programs, more aggressive pruning of execution paths must be done. One very good way to do this is the record actual execution paths during program execution. This is done in both GodeFroid Dart \[3\] and [Bitblaze](http://bitblaze.cs.berkeley.edu/). They both use a emulated environment for non-symbolic execution (to track actual execution paths) which can then be fed into the symbolic executor for further analysis. Bitblaze uses [QEMU](http://wiki.qemu.org/Main_Page) for this purpose, and is a nice practical hybrid of VMs and [Valgrind](http://valgrind.org/) VEX-IR. [Avalanche](http://code.google.com/p/avalanche/wiki/Avalanche) is a simpler solution relying solely on Valgrind.

### References

1. Cadar, Dunbar, Engler 2008 - KLEE: Unassisted and Automatic Generation of High-Coverage Tests for Complex Systems Programs
1. Cadar, Ganesh, Pawlowski, Dill, Engler 2006 - EXE: Automatically Generating Inputs of Death
1. GodeFroid, Nori, Rajamani, Tetali 2010 - Compositional May-Must Program Analysis: Unleashing The Power of Alternation
1. Godefroid, Elkarablieh, Levin 2009 - Precise Pointer Reasoning for Dynamic Test Generation
1. Godefroid, Levin, Molnar 2008 - Automated Whitebox Fuzz Testing
1. Godefroid, Klarlund, Sen 2005 - DART: Directed Automated Random Testing
1. Sasnauskas, Link, Alizai, Wehrle 2008 - Bug Hunting in Sensor Network Applications
