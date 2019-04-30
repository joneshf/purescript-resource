# purescript-resource

Safe resource handling

## Motivation

Dealing with scarce resources is not an easy thing to do.
If we're not careful, we can very easily run out of them, run out of memory, run out of CPU, or something else equally unfun.
This package exists to make dealing with resources an easier thing to do.

Generally speaking, managing scarce resources has three parts: acquiring the resource, using the resource, and releasing the resource.
The first two parts happen all the time; the last part is sometimes forgotten.
Assuming you use the safe values in this package, the last part will happen automatically.

## How To: Forget about resource bugs

Let's say you wanted to use the `Node.Readline` module.
Looking at version `4.0.0`, you might write something like:

```PureScript
module Main (main) where

import Prelude

import Effect as Effect
import Effect.Console as Effect.Console
import Node.Readline as Node.Readline

main :: Effect.Effect Unit
main = do
  interface <- Node.Readline.createConsoleInterface Node.Readline.noCompleter
  interface # Node.Readline.question "What do you think of PureScript" \answer ->
    Effect.Console.log ("Thank you for your valuable feedback: " <> answer)
```

That example might work, and it might be fine in a contrived example like this.
But, there's an issue with that code: the `Interface` is not closed.
Once that contrived example is built upon, frustrating bugs or bad things can happen.

To solve this problem, we could wrap the acquisition/releasing of the `Interface` in a `Resource` and let it deal with remembering to close the `Interface`:

```PureScript
module Main (main) where

import Prelude

import Effect as Effect
import Effect.Console as Effect.Console
import Node.Readline as Node.Readline
import Resource as Resource

main :: Effect.Effect Unit
main = 
  Resource.with (createConsoleInterface Node.Readline.noCompleter) \interface ->
    interface # Node.Readline.question "What do you think of PureScript" \answer ->
      Effect.Console.log ("Thank you for your valuable feedback: " <> answer)

createConsoleInterface :: 
  Node.Readline.Completer ->
  Resource.Resource Node.Readline.Interface
createConsoleInterface completer =
  Resource.new 
    (Node.Readline.createConsoleInterface completer)
    Node.Readline.close
```

Ideally, the `createConsoleInterface` would be tucked away in some resource-safe module that wrapped `Node.Readline` so it would be harder to misuse.
For example:

```PureScript
module Resource.Readline
  ( createConsoleInterface
  , question
  ) where

import Prelude

import Effect as Effect
import Effect.Class as Effect.Class
import Node.Readline as Node.Readline
import Resource as Resource

createConsoleInterface :: 
  Node.Readline.Completer ->
  Resource.Resource Node.Readline.Interface
createConsoleInterface completer =
  Resource.new 
    (Node.Readline.createConsoleInterface completer)
    Node.Readline.close

question ::
  String ->
  (String -> Effect.Effect Unit) ->
  Node.Readline.Interface ->
  Resource.Resource Unit
question query callback interface =
  Effect.Class.liftEffect (Node.Readline.question query callback interface)
```

Then, using it from `Main` would look more like:

```PureScript
module Main (main) where

import Prelude

import Effect as Effect
import Effect.Console as Effect.Console
import Node.Readline as Node.Readline
import Resource as Resource
import Resource.Readline as Resource.Readline

main :: Effect.Effect Unit
main = Resource.run do
  interface <- Resource.Readline.createConsoleInterface Node.Readline.noCompleter
  interface # Resource.Readline.question "What do you think of PureScript" \answer ->
    Effect.Console.log ("Thank you for your valuable feedback: " <> answer)
```

That looks very similar to the initial code, but it has fewer bugs!

## Inspiration

This package is greatly influenced by the [bracket][]/[handler][]/[resource][] pattern.
The ideas here are not original, but they are still useful.
There are many slightly different implementations in Haskell: [acquire][], [managed][], [resourcet][]

[acquire]: https://hackage.haskell.org/package/acquire
[bracket]: https://wiki.haskell.org/Bracket_pattern
[handler]: https://jaspervdj.be/posts/2018-03-08-handle-pattern.html
[managed]: https://hackage.haskell.org/package/managed
[resource]: http://www.haskellforall.com/2013/06/the-resource-applicative.html
[resourcet]: https://hackage.haskell.org/package/resourcet
