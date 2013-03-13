---
layout: post
title: "Parsing with Matches and Banana Clips"
description: ""
category: f#
tags: [f#]
---
{% include JB/setup %}

I find myself working with DSLs quite a bit, and thus I write a few parsers. Some languages are better than others for parsers and pattern matching is a technique that makes writing parsers a true joy. I will not go over the <a href="http://msdn.microsoft.com/en-us/library/dd547125.aspx">basics of pattern matching</a> here, rather show how F#'s <a href="http://msdn.microsoft.com/en-us/library/dd233248.aspx">active patterns</a> can be used to take pattern matching to the next level.

The traditional steps of a "parser" are roughly lexical analysis (tokenizer), syntactic analysis (parser) and then evaluator (interpreter). In this post we'll focus on the parsing step of a simple DSL. A parser typically consume a list of tokens and produces an Abstract Syntax Tree (AST), ready to be passed on the evaluator/interpreter.

You can think of the main bulk of a parser being a loop containing a switch of the tokens types. It looks for some predefined patterns (syntax) in the token list. Some are valid and some are not (syntax error). This sounds like a perfect "match" :-) for pattern matching! And indeed it is.

Let's say we have a simple DSL made up of a list of fields. Each field has a type and a name;
<pre>int32   version
myAlias data
</pre>
As you can see there are two kinds of types; we'll call them atomic types and alias types (myAlias is an pre-defined alias for some other atomic type). The main "switch" in the parser (using pattern matching) can look something like this;
<script src="https://gist.github.com/1694986.js?file=match-step1.fs"> </script>
This function takes a list of tokens and returns a Field and the rest of the tokens. An outer loop would run this repeatedly until the token list is empty. The "T" types are tokens, and "Field" is the resulting type ready for the evaluator.

Now let's say we want to make some fields optional, they should only be present if a specific condition holds true. We extend the syntax like so;
<pre>int32   version
int16   dodgy       if? version &gt; 2
myAlias data
</pre>
This means we have to extend our switch to handle all cases;
<script src="https://gist.github.com/1694986.js?file=match-step2.fs"> </script>
We just doubled the number of cases. It's still kind of nice and clear, but as a F# developer, this level of duplication is already making me a bit nauseous. Let's say we extend the DSL even more, we want each field for have a set of options;
<pre>hidden     int32   version
deprecated int16   dodgy       if? version &gt; 2
           myAlias data
</pre>
This doubles the number of cases again, the level of duplication is now pretty much unbearable :-) Thankfully, F# active patterns come to the rescue! Active patterns can be thought of as a way to impose a structure onto some of set of data (such as a list), and reason about these structures (treating said list as a binary heap for example). This can remove duplication and make code more easy to read and maintain.

Let's start and tackle the newly introduced options, by defining a couple of active patterns;
<script src="https://gist.github.com/1694986.js?file=match-step3.fs"> </script>
The "(|" brace is called a banana clip and is used for active patterns. In this case we have defined a partial active pattern "ValidFieldOption" which only matches on 2 types of tokens. The "FieldOptions" pattern is recursive and builds up an returns a set of valid options. It easts one token at a time and if that token satisfies the ValidFieldOption pattern it's added to the set (and the pattern calls itself with the rest of the tokens for another round of matching).

Our main switch can thus be simplified;
<script src="https://gist.github.com/1694986.js?file=match-step4.fs"> </script>
One interesting thing to note here is that in the same line as the active pattern is triggered, we also match (on the sub pattern) of the result list from FieldOptions. I.e. in the first case the "TAtomic(t) :: TString.." is another pattern that is matched on FieldOption's returned list!<br />

Let's try to simplify the duplication for the two field types;
<script src="https://gist.github.com/1694986.js?file=match-step5.fs"> </script>
Which gives a cleaner "switch" like so;
<script src="https://gist.github.com/1694986.js?file=match-step6.fs"> </script>
And finally we can "banana clip up" the condition expressions;
<script src="https://gist.github.com/1694986.js?file=match-step7.fs"> </script>
Which leaves us with our final version of the main parser switch;
<script src="https://gist.github.com/1694986.js?file=match-step8.fs"> </script>

### Conclusion
Pattern matching is very powerful and useful in many circumstances. F#'s addition of active patterns makes it even better. It is easier to break the patterns apart and avoid duplication, thus making the code easier to read and maintain. Pattern matching is available in some other languages (ML, Erlang, Haskell etc) and we will look at Scala and Clojure in future posts. Clojure solves pattern matching the "Lisp way", by using macros, and this can be extended do something like Active Patterns as well.
