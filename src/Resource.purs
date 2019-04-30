-- | Implementation of the [bracket][]/[handler][]/[resource][] pattern
-- |
-- | This module provides a safe interface to the pattern.
-- | None of the values in here should make it possible to _easily_ leak
-- | resources (though anything is possible if you try hard enough).
-- | The intent isn't to protect you from yourself,
-- | rather to make it easy to do the right thing.
-- |
-- | [bracket]: https://wiki.haskell.org/Bracket_pattern
-- | [handler]: https://jaspervdj.be/posts/2018-03-08-handle-pattern.html
-- | [resource]: http://www.haskellforall.com/2013/06/the-resource-applicative.html
module Resource (Resource, new, run, with) where

import Prelude

import Effect.Aff as Effect.Aff
import Resource.Unsafe as Resource.Unsafe

-- | The abstraction over safe resource management.
-- |
-- | Any values embeded in this data type will be safely acquired before use,
-- | and released after they're done being used.
-- | Will also release the resources in the face of exceptions.
type Resource = Resource.Unsafe.Resource

-- | A fairly safe way to construct a `Resource _`.
-- |
-- | This function can be easier to use sometimes than the continuation-based
-- | approach.
-- |
-- | Relies on the underlying `Aff _` behavior of `bracket`ing for safety.
new :: forall a. Effect.Aff.Aff a -> (a -> Effect.Aff.Aff Unit) -> Resource a
new = Resource.Unsafe.new

-- | Runs the `Resource _`.
-- |
-- | This cannot leak the resource as it's not known what the resource is.
run :: Resource Unit -> Effect.Aff.Aff Unit
run = Resource.Unsafe.run

-- | Runs the `Resource _` while passing the acquired resource to a callback.
-- |
-- | This cannot leak the resource as the callback cannot return the resource.
with :: forall a. Resource a -> (a -> Effect.Aff.Aff Unit) -> Effect.Aff.Aff Unit
with = Resource.Unsafe.with
