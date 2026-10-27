module ForgeTheGuard exposing (openNewPost)

{-| Does not compile: `Guard` does not expose the constructor of `Guarded`.
-}

import CurrentPage exposing (CurrentPage)
import Guard
import Route


openNewPost : CurrentPage
openNewPost =
    CurrentPage.open (Guard.Guarded (Just Route.NewPost))
