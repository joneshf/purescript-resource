let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/9f4d289897cdb16e193097b1cb009714366cebe2/src/packages.dhall sha256:710b53c085a18aa1263474659daa0ae15b7a4f453158c4f60ab448a6b3ed494e
in  upstream
  with spec =
    { dependencies =
      [ "aff"
      , "ansi"
      , "avar"
      , "console"
      , "exceptions"
      , "foldable-traversable"
      , "fork"

      , "now"
      , "pipes"
      , "prelude"
      , "strings"
      , "transformers"
      ]
    , repo = "https://github.com/fsoikin/purescript-spec.git"
    , version = "28c9c6627777cbdd73a67894657b8b711ef003ca"
    }
