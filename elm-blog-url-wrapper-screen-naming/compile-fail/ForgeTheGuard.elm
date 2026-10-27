module ForgeTheGuard exposing (openNewPost)

{-| Does not compile: `Guard` does not expose the constructor of `Guarded`.
-}

import CurrentScreen exposing (CurrentScreen)
import Destination
import Guard


openNewPost : CurrentScreen
openNewPost =
    CurrentScreen.open (Guard.Guarded (Just Destination.NewPost))
