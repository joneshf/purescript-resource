-- | An implementation of Codensity.
-- |
-- | Codensity is the right Kan-extension of some data type along itself.
-- | As suchh, most of the values here are type restricted version of the values
-- | in the `Ran` module.
module Codensity where

import Prelude

import Control.Comonad as Control.Comonad
import Effect as Effect
import Effect.Aff as Effect.Aff
import Effect.Aff.Class as Effect.Aff.Class
import Effect.Class as Effect.Class
import Ran as Ran

type Codensity ::
  (Type -> Type) ->
  Type ->
  Type
type Codensity f a
  = Ran.Ran f f a

apply :: forall a b f. Codensity f (a -> b) -> Codensity f a -> Codensity f b
apply = Ran.apply \x -> x

bind :: forall a b f. Codensity f a -> (a -> Codensity f b) -> Codensity f b
bind = Ran.bind \x -> x

lift :: forall f g. Functor g => (forall a. g (f a) -> f a) -> g ~> Codensity f
lift = Ran.lift

lift' :: forall f. Control.Comonad.Comonad f => f ~> Codensity f
lift' = Ran.lift'

liftAff :: forall f. Effect.Aff.Class.MonadAff f => Effect.Aff.Aff ~> Codensity f
liftAff = Ran.liftAff \x -> x

liftEffect :: forall f. Effect.Class.MonadEffect f => Effect.Effect ~> Codensity f
liftEffect = Ran.liftEffect \x -> x

lower :: forall a f g. (g ~> Codensity f) -> g (f a) -> f a
lower = Ran.lower

lower' :: forall f. Applicative f => Codensity f ~> f
lower' = Ran.lower'

map :: forall a b f. (a -> b) -> Codensity f a -> Codensity f b
map = Ran.map

pure :: forall a f. a -> Codensity f a
pure = Ran.pure \x -> x
