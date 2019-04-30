-- | Implementation of the [bracket][]/[handler][]/[resource][] pattern
-- |
-- | This module provides the underlying implementation of the pattern.
-- | It is possible to leak resources if you know some tricks about how to do it.
-- | Use these values with caution.
-- |
-- | [bracket]: https://wiki.haskell.org/Bracket_pattern
-- | [handler]: https://jaspervdj.be/posts/2018-03-08-handle-pattern.html
-- | [resource]: http://www.haskellforall.com/2013/06/the-resource-applicative.html
module Resource.Unsafe where

import Prelude

import Codensity as Codensity
import Control.Apply as Control.Apply
import Data.HeytingAlgebra as Data.HeytingAlgebra
import Effect.Aff as Effect.Aff
import Effect.Aff.Class as Effect.Aff.Class
import Effect.Class as Effect.Class

-- | The abstraction over safe resource management.
-- |
-- | Any values embeded in this data type will be safely acquired before use,
-- | and released after they're done being used.
-- | Will also release the resources in the face of exceptions.
newtype Resource a
  = Resource (Codensity.Codensity Effect.Aff.Aff a)

instance applicativeResource :: Applicative Resource where
  pure x = Resource (Codensity.pure x)

instance applyResource :: Apply Resource where
  apply = case _, _ of
    Resource f, Resource x -> Resource (Codensity.apply f x)

instance bindResource :: Bind Resource where
  bind = case _, _ of
    Resource x, f -> Resource (Codensity.bind x \y -> with (f y))

instance booleanAlgebraResource :: (BooleanAlgebra a) => BooleanAlgebra (Resource a)

instance functorResource :: Functor Resource where
  map f = case _ of
    Resource x -> Resource (Codensity.map f x)

instance heytingAlgebraResource :: (HeytingAlgebra a) => HeytingAlgebra (Resource a) where
  conj = Control.Apply.lift2 Data.HeytingAlgebra.conj
  disj = Control.Apply.lift2 Data.HeytingAlgebra.disj
  implies = Control.Apply.lift2 Data.HeytingAlgebra.implies
  not = map Data.HeytingAlgebra.not
  ff = pure Data.HeytingAlgebra.ff
  tt = pure Data.HeytingAlgebra.tt

instance monadResource :: Monad Resource

instance monadAffResource :: Effect.Aff.Class.MonadAff Resource where
  liftAff x = Resource (Codensity.liftAff x)

instance monadEffectResource :: Effect.Class.MonadEffect Resource where
  liftEffect x = Resource (Codensity.liftAff (Effect.Class.liftEffect x))

instance monoidResource :: (Monoid a) => Monoid (Resource a) where
  mempty = pure mempty

instance semigroupResource :: (Semigroup a) => Semigroup (Resource a) where
  append = Control.Apply.lift2 append

instance semiringResource :: (Semiring a) => Semiring (Resource a) where
  add = Control.Apply.lift2 add
  mul = Control.Apply.lift2 mul
  one = pure one
  zero = pure zero

-- | A fairly safe way to construct a `Resource _`.
-- |
-- | This function can be easier to use sometimes than the continuation-based
-- | approach.
-- |
-- | Relies on the underlying `Aff _` behavior of `bracket`ing for safety.
new :: forall a. Effect.Aff.Aff a -> (a -> Effect.Aff.Aff Unit) -> Resource a
new acquire release = Resource (Effect.Aff.bracket acquire release)

-- | An alternative way to construct a `Resource _`.
-- |
-- | This is a synonym for the `Resource` constructor.
new' :: forall a. (forall b. (a -> Effect.Aff.Aff b) -> Effect.Aff.Aff b) -> Resource a
new' = Resource

-- | Runs the `Resource _`.
-- |
-- | This can potentially leak the resource as it's unrestricted what the final
-- | value is and could be the resource itself.
run :: Resource ~> Effect.Aff.Aff
run = case _ of
  Resource f -> f pure

-- | Runs the `Resource _` while passing the acquired resource to a callback.
-- |
-- | This is an abstraction of the [handler][] pattern.
-- |
-- | This can potentially leak the resource as it's unrestricted what the final
-- | value is and could be the resource itself.
with :: forall a b. Resource a -> (a -> Effect.Aff.Aff b) -> Effect.Aff.Aff b
with = case _ of
  Resource g -> g
