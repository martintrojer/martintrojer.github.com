---
categories:
- clojure
date: "2011-11-20T00:00:00Z"
description: ""
tags:
- .net
- clojure
- fsharp
- jvm
- scala
title: Tail Calls in F#, Clojure and Scala
---

I recently looked into Tail Call Optimisation/Elimination (TCO) and the implications for 3 modern languages, namely F#, Clojure and Scala. In this post I share my my findings.&nbsp;If you're new to the subject or just looking into some of these languages I hope this post can be of some use to you. I will mix code snippets in the 3 languages freely (and without warning! :)

TCO is a well documented topic in books and articles about functional programming and the TCO in .NET and the lack their of in the JVM has been debated "to death" on various programmer's boards. I don't indend to add any fuel to the fire here, rather some background and practical implications.

### Background
Recursion is a fundamental corner stone of programming and is particularly emphasised in functional programming. It is the idiomatic way to loop over sequences in languages like Clojure. Here's a classic example of a function calculating the sum of all natural number less or equal to n.

```fsharp
let rec sum n =
  if n = 0 then 0
  else n + sum(n-1)
```

This implementation is both very easy to understand and correct, so what's the problem? Well, this implementation is not "tail recursive". A tail recursive function has the recursive call at it's tail and noting else (immediately returning the result of the call). In this case the result of the recursive function is used in an addition, and the result of the addition is returned. The practical implication of this is that during execution we are building up a chain of call-stacks, which cannot be freed until we reach n=0 and the results "bubble up".

{{< figure src="/assets/images/tailcalls/recur1.png" >}}

When n is large this will lead to a “Stack Overflow” exception

```
fsi> sum 1000000;;
Process is terminated due to StackOverflowException.
```

Every functional programmer have two handy tools in his toolbox to solve this problem; re-write using accumulators (folding) and continuation passing style.

If we look at the sum function's loop, and think how we would implement this using imperative programming, we would probably write a for loop like so;

```scala
def sumImperative(n:Int):Int = {
  var res = 0
  for (i <- n to(0, -1)) {
    res = res + i
  }
  res
}
```

The recursive variant of this will look like this;

```scala
def sum2(acc:Int, n:Int):Int = {
  if (n==0) acc
  else sum2((n+acc),(n-1))
}
```

By passing around the result we have a tail recursive solution.

Continuation passing style is a bit more tricky to understand, but basically instead of passing the result as parameter we are passing a calculation (or continuation). This continuation will be a chain of closures which can be completely resolved when we reach the end of the recursion. Here is an example;

```clojure
(defn sum3[k n]
  (if
    (= n 0) (k 0)
    (sum3 (fn [m] (k (+ n m))) (dec n))))

(sum3 identity 10)
```

If we call it with the id function as shown above, result of the "closure-chain" will be the result we are looking for. As you can see, this is also a tail recursive solution.

### Clever compilers
We have now converted our simple example to a tail recursive version, so now it should run with very big n-s without any problem right? Well, not always. To understand why we need to dig into how our compiler and runtimes work (in this case .NET and JVM).

If we look at what the F# compiler produces for a accumulator-tail-recursive sum function above we'll see this (de-compiled into C# with [ILSpy](http://wiki.sharpdevelop.net/ILSpy.ashx)).

```csharp
public static int sum(int acc, int n) {
  while (n != 0) {
    int arg_12_0 = n + acc;
    n--;
    acc = arg_12_0;
  }
}
```

That's is great, the compiler has realised that the tail recursion can be converted to a while loop and removed any recursive calls. The Scala compiler does the same (de-compiled to java with [Java Decompiler](http://java.decompiler.free.fr/))

```java
public int sum2(int acc, int n) {
    while (true) {
      if (n == 0)
        return acc;
      n -= 1; acc = n + acc;
    }
  }
```

However, Clojure does not! The clojure compiler require an explicit form to convert "mundane" recursion into a non-recurisve loop (Scala also support explicit tail call checking with the @tailrec annotation). This is the loop/recur form;

```clojure
(defn sum2[acc n]
  (if
    (= n 0) acc
    (recur (+ n acc) (dec n))))
```

Awesome, problem solved, what's all this fuss about TCO then?<br />

### TCO
Let's say we have two functions a and b calling each other recursively;

```fsharp
let a (f:int->int) n =
   f (n + 1)

let rec b n =
   a b (n + 1)
```

This is called mutual recursion, and are commonly used in functional implementations of finite state machines. Even though the a+b functions are tail recursive, we cannot convert to while loops but must proceed with the recursive calls. Quite naturally this will blow up with stack overflow quite quickly. Steele and Sussman realised in their famous [lambda papers](http://library.readscheme.org/page1.html) back in the 70's, that a tail-recursive functions' stack resources can be freed as soon as the call is made, there is not point of keeping that stack frame around.

{{< figure src="/assets/images/tailcalls/recur2.png" >}}

For a tail recursive sum example, with TCO we don't build up a chain of stacks and can thus handle summations of any depth (value of n).

The "dealloc-on-call" functionality is something the runtime have to support, which .NET does. If we look at the byte code for the function "b" above (compiled with tailcall-optimization on) we see;

```
 IL_0000: nop
 IL_0001: newobj instance void Program/b@12::.ctor()
 IL_0006: ldarg.0
 IL_0007: ldc.i4.1
 IL_0008: add
 IL_0009: tail.
 IL_000b: call int32 Program::a(class [FSharp.Core]Microsoft.FSharp.Core.FSharpFunc`2<int32, int32="">, int32)
 IL_0010: ret
 ```

Please note the "tail." op code, that's the secret sauce! The F# compiler has found a tail call and inserted the "tail." op code. This tells the .NET runtime to destroy the caller's resources and proceed "in" the callee's stack. This allows the a/b example above to run indefinitely without any stack overflows.

So what about the JVM? The bad news is that there is no "tail." java byte code (even if experimental implementations do [exist](http://blogs.oracle.com/jrose/entry/tail_calls_in_the_vm)). Here is a what the Clojure compiler produced for the b function (the invokeinterface is the recursive call to a);

```
 0 getstatic #27 <app stack$b.const__0="">
 3 invokevirtual #54 <clojure lang="" var.getrawroot="">
 6 checkcast #56 <clojure ifn="" lang="">
 9 getstatic #31 <app stack$b.const__1="">
12 invokevirtual #54 <clojure lang="" var.getrawroot="">
15 aload_1
16 aconst_null
17 astore_1
18 lconst_1
19 invokestatic #62 <clojure lang="" numbers.add="">
22 invokeinterface #65 <clojure ifn.invoke="" lang=""> count 3
27 areturn
```

Clojure solves the mutual recursion problem with a "trampoline". The idea is that instead of a and b calling each other directly, they return a closure (or a thunk) containing that call. The trampoline will then run those closures in it's own stack-frame eliminating the stack build up.

```clojure
(defn a[f n]
  #(f (inc n)))

(defn b[n]
  #(a b (inc n)))

(trampoline b 0)
```

Similar examples exist for Scala, a trampoline is infact trivial to implement.

### Conclusion
General TCO is always best, so F# and .NET has the upper hand here. However Clojure and Scala are still fit for use, even if you follow a "strict" functional paradigm with lots of recursion. You have to be more explicit in the JVM languages and be careful to remember trampolines in cases of mutual recursion (this is especially true for FSMs that change state slowly and can act as time bombs for your program). Being explicit about tail calls is not necessarily a bad thing, it shows the programmer have thought about his code, and highlighted the behaviour.

_Update_; I should point that using Continuation Passing Style in Clojure, although being tail recursive, still suffers from the TCO problem. You will get Stack Overflows when the "closure chain" gets too big.

_Update 2_; A clever compiler can convert mutual recursion into while loops. The a/b example above can be transformed into something like this;

```java
bool inA = true;
while (true) {
  if (inA) {
  // do A stuff
  inA = false;
  }
  else {
  // do B stuff
  inA = true;
  }
}
```

However, I don't know of any compiler that does this!
