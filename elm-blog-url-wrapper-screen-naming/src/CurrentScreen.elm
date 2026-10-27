module CurrentScreen exposing (CurrentScreen, Screen(..), open, screen, setLogin, setNewPost)

{-| The screen the app shows. Only a guarded move opens one (`open`), and the only
other change is to the form of the screen shown (`setLogin`, `setNewPost`). The
constructor of `CurrentScreen` is not exposed, so no other module can write it.
-}

import Destination
import Guard exposing (Guarded)
import Screen.Login as Login
import Screen.NewPost as NewPost


type CurrentScreen
    = CurrentScreen Screen


type Screen
    = NotFound
    | Home
    | Post String
    | About
    | Login Login.Model
    | NewPost NewPost.Model


open : Guarded -> CurrentScreen
open guarded =
    CurrentScreen
        (case Guard.destination guarded of
            Nothing ->
                NotFound

            Just Destination.Home ->
                Home

            Just (Destination.Post slug) ->
                Post slug

            Just Destination.About ->
                About

            Just Destination.Login ->
                Login Login.init

            Just Destination.NewPost ->
                NewPost NewPost.init
        )


screen : CurrentScreen -> Screen
screen (CurrentScreen current) =
    current


{-| Changes the form of the login screen. Any other screen is kept as it is.
-}
setLogin : Login.Model -> CurrentScreen -> CurrentScreen
setLogin login (CurrentScreen current) =
    case current of
        Login _ ->
            CurrentScreen (Login login)

        _ ->
            CurrentScreen current


{-| Changes the form of the new post screen. Any other screen is kept as it is.
-}
setNewPost : NewPost.Model -> CurrentScreen -> CurrentScreen
setNewPost newPost (CurrentScreen current) =
    case current of
        NewPost _ ->
            CurrentScreen (NewPost newPost)

        _ ->
            CurrentScreen current
