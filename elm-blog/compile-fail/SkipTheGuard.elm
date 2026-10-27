module SkipTheGuard exposing (openNewPost)

{-| Does not compile: `CurrentPage.open` takes a `Guarded`, not a route.
-}

import CurrentPage exposing (CurrentPage)
import Route


openNewPost : CurrentPage
openNewPost =
    CurrentPage.open (Just Route.NewPost)
