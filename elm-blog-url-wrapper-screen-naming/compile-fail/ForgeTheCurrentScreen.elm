module ForgeTheCurrentScreen exposing (openNewPost)

{-| Does not compile: `CurrentScreen` does not expose its own constructor.
-}

import CurrentScreen exposing (CurrentScreen, Screen(..))
import Screen.NewPost as NewPost


openNewPost : CurrentScreen
openNewPost =
    CurrentScreen.CurrentScreen (NewPost NewPost.init)
