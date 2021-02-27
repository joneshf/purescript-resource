let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20210226/packages.dhall sha256:7e973070e323137f27e12af93bc2c2f600d53ce4ae73bb51f34eb7d7ce0a43ea

in  upstream
  with spec =
    { dependencies =
      [ "aff"
      , "ansi"
      , "console"
      , "exceptions"
      , "foldable-traversable"
      , "generics-rep"
      , "pipes"
      , "prelude"
      , "strings"
      , "transformers"
      ]
    , repo = "https://github.com/purescript-spec/purescript-spec.git"
    , version = "v3.1.1"
    }
