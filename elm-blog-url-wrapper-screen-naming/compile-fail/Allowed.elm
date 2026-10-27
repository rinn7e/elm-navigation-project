module Allowed exposing (openNewPost)

{-| Compiles: the only way to open a screen is through the guard.
-}

import CurrentScreen exposing (CurrentScreen)
import Destination
import Guard


openNewPost : Maybe String -> CurrentScreen
openNewPost user =
    CurrentScreen.open (Guard.guard user (Just Destination.NewPost))
