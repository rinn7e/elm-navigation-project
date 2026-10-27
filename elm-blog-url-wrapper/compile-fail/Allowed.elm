module Allowed exposing (openNewPost)

{-| Compiles: the only way to open a page is through the guard.
-}

import CurrentPage exposing (CurrentPage)
import Guard
import Route


openNewPost : Maybe String -> CurrentPage
openNewPost user =
    CurrentPage.open (Guard.guard user (Just Route.NewPost))
