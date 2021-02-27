-- | An implementation of the right Kan-extension.
module Ran where

import Prelude

import Control.Applicative as Control.Applicative
import Control.Bind as Control.Bind
import Control.Comonad as Control.Comonad
import Data.Functor as Data.Functor
import Effect as Effect
import Effect.Aff as Effect.Aff
import Effect.Aff.Class as Effect.Aff.Class
import Effect.Class as Effect.Class

type Ran ::
  (Type -> Type) ->
  (Type -> Type) ->
  Type ->
  Type
type Ran f g a
  = forall b. (a -> f b) -> g b

apply :: forall a b f g. (g ~> f) -> Ran f g (a -> b) -> Ran f g a -> Ran f g b
apply hoist = case _, _ of
  f', x' -> \g ->
    f' \f ->
      hoist (x' (g <<< f))

bind :: forall a b f g. (g ~> f) -> Ran f g a -> (a -> Ran f g b) -> Ran f g b
bind hoist = case _, _ of
  x', f -> \g ->
    x' \x ->
      hoist $ f x g

lift :: forall f g h. Functor h => (forall a. h (f a) -> g a) -> h ~> Ran f g
lift f x = \g -> f (Data.Functor.map g x)

lift' :: forall f g. Control.Comonad.Comonad f => Functor g => g ~> Ran f g
lift' = lift (Data.Functor.map Control.Comonad.extract)

liftAff ::
  forall f g.
  Effect.Aff.Class.MonadAff f =>
  (f ~> g) ->
  Effect.Aff.Aff ~> Ran f g
liftAff hoist x = hoist <<< Control.Bind.bind (Effect.Aff.Class.liftAff x)

liftEffect ::
  forall f g.
  Effect.Class.MonadEffect f =>
  (f ~> g) ->
  Effect.Effect ~> Ran f g
liftEffect hoist x = hoist <<< Control.Bind.bind (Effect.Class.liftEffect x)

lower :: forall a f g h. (h ~> Ran f g) -> h (f a) -> g a
lower f x = f x \y -> y

lower' :: forall f g. Applicative f => Ran f g ~> g
lower' = case _ of
  f -> f Control.Applicative.pure

map :: forall a b f g. (a -> b) -> Ran f g a -> Ran f g b
map f = case _ of
  g -> \h ->
    g \x ->
      h (f x)

pure :: forall a f g. (f ~> g) -> a -> Ran f g a
pure hoist x = \f -> hoist (f x)
