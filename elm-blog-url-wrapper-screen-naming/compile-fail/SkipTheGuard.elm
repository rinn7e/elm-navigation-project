module SkipTheGuard exposing (openNewPost)

{-| Does not compile: `CurrentScreen.open` takes a `Guarded`, not a destination.
-}

import CurrentScreen exposing (CurrentScreen)
import Destination


openNewPost : CurrentScreen
openNewPost =
    CurrentScreen.open (Just Destination.NewPost)
