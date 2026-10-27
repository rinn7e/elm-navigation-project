module WritePageDirectly exposing (openNewPost)

{-| Does not compile: the model holds a `CurrentPage`, so a `Page` cannot be
written into it.
-}

import CurrentPage exposing (CurrentPage, Page(..))
import Page.NewPost as NewPost


openNewPost : { model | page : CurrentPage } -> { model | page : CurrentPage }
openNewPost model =
    { model | page = NewPost NewPost.init }
