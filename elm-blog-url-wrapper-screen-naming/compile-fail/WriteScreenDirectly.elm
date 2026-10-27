module WriteScreenDirectly exposing (openNewPost)

{-| Does not compile: the model holds a `CurrentScreen`, so a `Screen` cannot be
written into it.
-}

import CurrentScreen exposing (CurrentScreen, Screen(..))
import Screen.NewPost as NewPost


openNewPost : { model | screen : CurrentScreen } -> { model | screen : CurrentScreen }
openNewPost model =
    { model | screen = NewPost NewPost.init }
