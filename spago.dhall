{ name = "resource"
, dependencies =
  [ "aff"
  , "console"
  , "control"
  , "effect"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "refs"
  , "spec"
  ]
, packages = ./packages.dhall
, sources =
  [ "src/Codensity.purs"
  , "src/Ran.purs"
  , "src/Resource.purs"
  , "src/Resource/Unsafe.purs"
  , "test/Test/Main.purs"
  ]
}
