port module Main exposing (main)

import BlogPost exposing (BlogPost)
import Browser
import Browser.Navigation as Nav
import Destination exposing (Destination)
import Html exposing (Html, a, button, div, header, main_, nav, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Screen.About as About
import Screen.Home as Home
import Screen.Login as Login
import Screen.NewPost as NewPost
import Screen.Post as Post
import Url exposing (Url)



-- MAIN


{-| The flags are the user signed in before the page loaded, from localStorage.
-}
main : Program (Maybe String) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = updateWithUrl
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


port storeUser : Maybe String -> Cmd msg



-- MODEL


type alias Model =
    { key : Nav.Key
    , user : Maybe String
    , posts : List BlogPost
    , screen : Screen
    }


type Screen
    = NotFound
    | Home
    | Post String
    | About
    | Login Login.Model
    | NewPost NewPost.Model


init : Maybe String -> Url -> Nav.Key -> ( Model, Cmd Msg )
init user url key =
    let
        urlDestination =
            Destination.fromUrl url

        bootModel =
            { key = key
            , user = user
            , posts = BlogPost.all
            , screen = NotFound
            }

        model =
            openScreen (guard bootModel urlDestination) bootModel
    in
    ( model, bootUrlCmd urlDestination model )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | ClickedLogout
    | GotLoginMsg Login.Msg
    | GotNewPostMsg NewPost.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.screen ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( navigate (Destination.fromUrl url) model, Cmd.none )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( navigate (Destination.fromUrl url) model, Cmd.none )

        ( ClickedLogout, _ ) ->
            ( navigate (Just Destination.Home) { model | user = Nothing }
            , storeUser Nothing
            )

        ( GotLoginMsg subMsg, Login login ) ->
            case Login.update subMsg login of
                ( _, Just user ) ->
                    ( navigate (Just Destination.Home) { model | user = Just user }
                    , storeUser (Just user)
                    )

                ( newLogin, Nothing ) ->
                    ( { model | screen = Login newLogin }, Cmd.none )

        ( GotNewPostMsg subMsg, NewPost newPost ) ->
            case NewPost.update model.posts subMsg newPost of
                ( _, Just post ) ->
                    ( navigate (Just (Destination.Post post.slug)) { model | posts = post :: model.posts }
                    , Cmd.none
                    )

                ( newNewPost, Nothing ) ->
                    ( { model | screen = NewPost newNewPost }, Cmd.none )

        ( _, _ ) ->
            -- A message for a screen that is not shown anymore
            ( model, Cmd.none )



-- NAVIGATION


{-| A move to the destination, through the guard. The destination shown already
is dropped, so the screen keeps its state.
-}
navigate : Maybe Destination -> Model -> Model
navigate maybeDestination model =
    let
        destination =
            guard model maybeDestination
    in
    if destination == destinationOf model then
        model

    else
        openScreen destination model


{-| Signed out the new post screen redirects to the login screen, signed in the
login screen redirects home.
-}
guard : Model -> Maybe Destination -> Maybe Destination
guard model maybeDestination =
    case maybeDestination of
        Just Destination.Login ->
            if model.user /= Nothing then
                Just Destination.Home

            else
                maybeDestination

        Just Destination.NewPost ->
            if model.user == Nothing then
                Just Destination.Login

            else
                maybeDestination

        _ ->
            maybeDestination


openScreen : Maybe Destination -> Model -> Model
openScreen maybeDestination model =
    case maybeDestination of
        Nothing ->
            { model | screen = NotFound }

        Just Destination.Home ->
            { model | screen = Home }

        Just (Destination.Post slug) ->
            { model | screen = Post slug }

        Just Destination.About ->
            { model | screen = About }

        Just Destination.Login ->
            { model | screen = Login Login.init }

        Just Destination.NewPost ->
            { model | screen = NewPost NewPost.init }


{-| Where the app is, read from the screen shown (it is not stored a second time).
-}
destinationOf : Model -> Maybe Destination
destinationOf model =
    case model.screen of
        NotFound ->
            Nothing

        Home ->
            Just Destination.Home

        Post slug ->
            Just (Destination.Post slug)

        About ->
            Just Destination.About

        Login _ ->
            Just Destination.Login

        NewPost _ ->
            Just Destination.NewPost



-- URL


{-| The root `update`, wrapped once: after every step the URL follows the
destination, so `update` never writes it.
-}
updateWithUrl : Msg -> Model -> ( Model, Cmd Msg )
updateWithUrl msg model =
    let
        ( newModel, cmd ) =
            update msg model
    in
    ( newModel, Cmd.batch [ urlCmd msg model newModel, cmd ] )


{-| A change of destination pushes an entry, the same destination writes
nothing. An entry the guard would now redirect (the login screen after a login) is
replaced instead. A back or forward of the browser (`UrlChanged`) has its entry
already: it is corrected with a replace only when the app shows another
destination (the guard redirected it). Elm also sends `UrlChanged` for the URL
written here: it is the destination shown, so it writes nothing.
-}
urlCmd : Msg -> Model -> Model -> Cmd Msg
urlCmd msg model newModel =
    case ( msg, destinationOf newModel ) of
        ( _, Nothing ) ->
            -- The not found screen writes no URL: no link of the app leads to it
            Cmd.none

        ( UrlChanged url, Just destination ) ->
            if Destination.fromUrl url == Just destination then
                Cmd.none

            else
                Destination.replaceUrl newModel.key destination

        ( _, Just destination ) ->
            if destinationOf model == Just destination then
                Cmd.none

            else if guard newModel (destinationOf model) /= destinationOf model then
                -- The guard would redirect the destination before
                Destination.replaceUrl newModel.key destination

            else
                Destination.pushUrl newModel.key destination


{-| The URL the app booted on is corrected with a replace when the guard
redirected it.
-}
bootUrlCmd : Maybe Destination -> Model -> Cmd Msg
bootUrlCmd urlDestination model =
    case destinationOf model of
        Just destination ->
            if urlDestination == Just destination then
                Cmd.none

            else
                Destination.replaceUrl model.key destination

        Nothing ->
            Cmd.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        { title, content } =
            viewScreen model
    in
    { title = title ++ " - Elm Blog"
    , body =
        [ div [ class "mx-auto max-w-2xl px-4 py-8 text-slate-900" ]
            [ viewHeader model
            , main_ [] [ content ]
            ]
        ]
    }


viewScreen : Model -> { title : String, content : Html Msg }
viewScreen model =
    case model.screen of
        NotFound ->
            { title = "Not found", content = text "There is no page here." }

        Home ->
            Home.view model.posts

        Post slug ->
            Post.view slug model.posts

        About ->
            About.view

        Login login ->
            mapContent GotLoginMsg (Login.view login)

        NewPost newPost ->
            mapContent GotNewPostMsg (NewPost.view newPost)


mapContent : (msg -> Msg) -> { title : String, content : Html msg } -> { title : String, content : Html Msg }
mapContent toMsg { title, content } =
    { title = title, content = Html.map toMsg content }


viewHeader : Model -> Html Msg
viewHeader model =
    header [ class "mb-8 flex items-center justify-between border-b border-slate-200 pb-4" ]
        [ a [ class "text-xl font-bold", Destination.href Destination.Home ] [ text "Elm Blog" ]
        , nav [ class "flex items-center gap-4" ]
            (viewNavLink model Destination.Home "Posts"
                :: viewNavLink model Destination.About "About"
                :: viewNavLink model Destination.NewPost "Write"
                :: (case model.user of
                        Just user ->
                            [ span [ class "text-sm text-slate-500" ] [ text ("Signed in as " ++ user) ]
                            , button [ class "text-sky-700 hover:underline", onClick ClickedLogout ] [ text "Log out" ]
                            ]

                        Nothing ->
                            [ viewNavLink model Destination.Login "Login" ]
                   )
            )
        ]


viewNavLink : Model -> Destination -> String -> Html msg
viewNavLink model destination label =
    a
        [ class
            (if isActive model.screen destination then
                "font-semibold text-sky-700"

             else
                "text-slate-600 hover:text-sky-700"
            )
        , Destination.href destination
        ]
        [ text label ]


isActive : Screen -> Destination -> Bool
isActive screen destination =
    case ( screen, destination ) of
        ( Home, Destination.Home ) ->
            True

        ( About, Destination.About ) ->
            True

        ( Login _, Destination.Login ) ->
            True

        ( NewPost _, Destination.NewPost ) ->
            True

        _ ->
            False
