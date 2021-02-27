module Test.Main (main) where

import Prelude

import Effect as Effect
import Effect.Aff as Effect.Aff
import Effect.Class as Effect.Class
import Effect.Ref as Effect.Ref
import Resource as Resource
import Test.Spec as Test.Spec
import Test.Spec.Assertions as Test.Spec.Assertions
import Test.Spec.Reporter as Test.Spec.Runner.Repoter
import Test.Spec.Runner as Test.Spec.Runner

main :: Effect.Effect Unit
main = Effect.Aff.launchAff_ spec

spec :: Effect.Aff.Aff Unit
spec = Test.Spec.Runner.runSpec [Test.Spec.Runner.Repoter.specReporter] do
  Test.Spec.describe "Resource" do
    Test.Spec.describe "run" do
      Test.Spec.it "acquires and releases resources in the correct order" do
        results <- Effect.Class.liftEffect (Effect.Ref.new mempty)

        Resource.run do
          _ <- new results "foo"
          _ <- new results "bar"
          _ <- new results "baz"
          _ <- new results "qux"
          mempty

        actual <- Effect.Class.liftEffect (Effect.Ref.read results)
        actual
          `Test.Spec.Assertions.shouldEqual`
            [ acquiring "foo"
            , acquiring "bar"
            , acquiring "baz"
            , acquiring "qux"
            , releasing "qux"
            , releasing "baz"
            , releasing "bar"
            , releasing "foo"
            ]

      Test.Spec.it "releases resources even with an exception" do
        results <- Effect.Class.liftEffect (Effect.Ref.new mempty)

        Test.Spec.Assertions.expectError $ Resource.run do
          _ <- new results "foo"
          _ <- new results "bar"
          Resource.new (Effect.Aff.throwError $ Effect.Aff.error "break") pure
          _ <- new results "baz"
          _ <- new results "qux"
          mempty

        actual <- Effect.Class.liftEffect (Effect.Ref.read results)
        actual
          `Test.Spec.Assertions.shouldEqual`
            [ acquiring "foo"
            , acquiring "bar"
            , releasing "bar"
            , releasing "foo"
            ]

acquiring :: forall a. Show a => a -> String
acquiring x = "Acquiring " <> show x

new :: forall a. Show a => Effect.Ref.Ref (Array String) -> a -> Resource.Resource a
new results x' = Resource.new acquire release
  where
  acquire = do
    Effect.Class.liftEffect (Effect.Ref.modify_ (_ <> [acquiring x']) results)
    pure x'
  release x = do
    Effect.Class.liftEffect (Effect.Ref.modify_ (_ <> [releasing x]) results)

releasing :: forall a. Show a => a -> String
releasing x = "Releasing " <> show x
