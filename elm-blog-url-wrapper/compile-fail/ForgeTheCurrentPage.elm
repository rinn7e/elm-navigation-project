module ForgeTheCurrentPage exposing (openNewPost)

{-| Does not compile: `CurrentPage` does not expose its own constructor.
-}

import CurrentPage exposing (CurrentPage, Page(..))
import Page.NewPost as NewPost


openNewPost : CurrentPage
openNewPost =
    CurrentPage.CurrentPage (NewPost NewPost.init)
