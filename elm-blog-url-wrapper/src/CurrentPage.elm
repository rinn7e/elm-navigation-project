module CurrentPage exposing (CurrentPage, Page(..), open, page, setLogin, setNewPost)

{-| The page the app shows. Only a guarded move opens one (`open`), and the only
other change is to the form of the page shown (`setLogin`, `setNewPost`). The
constructor of `CurrentPage` is not exposed, so no other module can write it.
-}

import Guard exposing (Guarded)
import Page.Login as Login
import Page.NewPost as NewPost
import Route


type CurrentPage
    = CurrentPage Page


type Page
    = NotFound
    | Home
    | Post String
    | About
    | Login Login.Model
    | NewPost NewPost.Model


open : Guarded -> CurrentPage
open guarded =
    CurrentPage
        (case Guard.route guarded of
            Nothing ->
                NotFound

            Just Route.Home ->
                Home

            Just (Route.Post slug) ->
                Post slug

            Just Route.About ->
                About

            Just Route.Login ->
                Login Login.init

            Just Route.NewPost ->
                NewPost NewPost.init
        )


page : CurrentPage -> Page
page (CurrentPage current) =
    current


{-| Changes the form of the login page. Any other page is kept as it is.
-}
setLogin : Login.Model -> CurrentPage -> CurrentPage
setLogin login (CurrentPage current) =
    case current of
        Login _ ->
            CurrentPage (Login login)

        _ ->
            CurrentPage current


{-| Changes the form of the new post page. Any other page is kept as it is.
-}
setNewPost : NewPost.Model -> CurrentPage -> CurrentPage
setNewPost newPost (CurrentPage current) =
    case current of
        NewPost _ ->
            CurrentPage (NewPost newPost)

        _ ->
            CurrentPage current
