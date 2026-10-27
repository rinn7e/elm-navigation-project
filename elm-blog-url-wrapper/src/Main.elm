port module Main exposing (main)

import BlogPost exposing (BlogPost)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, header, main_, nav, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Page.About as About
import Page.Home as Home
import Page.Login as Login
import Page.NewPost as NewPost
import Page.Post as Post
import Route exposing (Route)
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
    , page : Page
    }


type Page
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
            Route.fromUrl url

        bootModel =
            { key = key
            , user = user
            , posts = BlogPost.all
            , page = NotFound
            }

        model =
            openPage (guard bootModel urlDestination) bootModel
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
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( navigate (Route.fromUrl url) model, Cmd.none )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( navigate (Route.fromUrl url) model, Cmd.none )

        ( ClickedLogout, _ ) ->
            ( navigate (Just Route.Home) { model | user = Nothing }
            , storeUser Nothing
            )

        ( GotLoginMsg subMsg, Login login ) ->
            case Login.update subMsg login of
                ( _, Just user ) ->
                    ( navigate (Just Route.Home) { model | user = Just user }
                    , storeUser (Just user)
                    )

                ( newLogin, Nothing ) ->
                    ( { model | page = Login newLogin }, Cmd.none )

        ( GotNewPostMsg subMsg, NewPost newPost ) ->
            case NewPost.update model.posts subMsg newPost of
                ( _, Just post ) ->
                    ( navigate (Just (Route.Post post.slug)) { model | posts = post :: model.posts }
                    , Cmd.none
                    )

                ( newNewPost, Nothing ) ->
                    ( { model | page = NewPost newNewPost }, Cmd.none )

        ( _, _ ) ->
            -- A message for a page that is not shown anymore
            ( model, Cmd.none )



-- NAVIGATION


{-| A move to the destination, through the guard. The destination shown already
is dropped, so the page keeps its state.
-}
navigate : Maybe Route -> Model -> Model
navigate maybeRoute model =
    let
        destination =
            guard model maybeRoute
    in
    if destination == destinationOf model then
        model

    else
        openPage destination model


{-| Signed out the new post page redirects to the login page, signed in the
login page redirects home.
-}
guard : Model -> Maybe Route -> Maybe Route
guard model maybeRoute =
    case maybeRoute of
        Just Route.Login ->
            if model.user /= Nothing then
                Just Route.Home

            else
                maybeRoute

        Just Route.NewPost ->
            if model.user == Nothing then
                Just Route.Login

            else
                maybeRoute

        _ ->
            maybeRoute


openPage : Maybe Route -> Model -> Model
openPage maybeRoute model =
    case maybeRoute of
        Nothing ->
            { model | page = NotFound }

        Just Route.Home ->
            { model | page = Home }

        Just (Route.Post slug) ->
            { model | page = Post slug }

        Just Route.About ->
            { model | page = About }

        Just Route.Login ->
            { model | page = Login Login.init }

        Just Route.NewPost ->
            { model | page = NewPost NewPost.init }


{-| Where the app is, read from the page shown (it is not stored a second time).
-}
destinationOf : Model -> Maybe Route
destinationOf model =
    case model.page of
        NotFound ->
            Nothing

        Home ->
            Just Route.Home

        Post slug ->
            Just (Route.Post slug)

        About ->
            Just Route.About

        Login _ ->
            Just Route.Login

        NewPost _ ->
            Just Route.NewPost



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
nothing. An entry the guard would now redirect (the login page after a login) is
replaced instead. A back or forward of the browser (`UrlChanged`) has its entry
already: it is corrected with a replace only when the app shows another
destination (the guard redirected it). Elm also sends `UrlChanged` for the URL
written here: it is the destination shown, so it writes nothing.
-}
urlCmd : Msg -> Model -> Model -> Cmd Msg
urlCmd msg model newModel =
    case ( msg, destinationOf newModel ) of
        ( _, Nothing ) ->
            -- The not found page keeps the URL it was opened with
            Cmd.none

        ( UrlChanged url, Just route ) ->
            if Route.fromUrl url == Just route then
                Cmd.none

            else
                Route.replaceUrl newModel.key route

        ( _, Just route ) ->
            if destinationOf model == Just route then
                Cmd.none

            else if guard newModel (destinationOf model) /= destinationOf model then
                -- The guard would redirect the destination before
                Route.replaceUrl newModel.key route

            else
                Route.pushUrl newModel.key route


{-| The URL the app booted on is corrected with a replace when the guard
redirected it.
-}
bootUrlCmd : Maybe Route -> Model -> Cmd Msg
bootUrlCmd urlDestination model =
    case destinationOf model of
        Just route ->
            if urlDestination == Just route then
                Cmd.none

            else
                Route.replaceUrl model.key route

        Nothing ->
            Cmd.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        { title, content } =
            viewPage model
    in
    { title = title ++ " - Elm Blog"
    , body =
        [ div [ class "mx-auto max-w-2xl px-4 py-8 text-slate-900" ]
            [ viewHeader model
            , main_ [] [ content ]
            ]
        ]
    }


viewPage : Model -> { title : String, content : Html Msg }
viewPage model =
    case model.page of
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
        [ a [ class "text-xl font-bold", Route.href Route.Home ] [ text "Elm Blog" ]
        , nav [ class "flex items-center gap-4" ]
            (viewNavLink model Route.Home "Posts"
                :: viewNavLink model Route.About "About"
                :: viewNavLink model Route.NewPost "Write"
                :: (case model.user of
                        Just user ->
                            [ span [ class "text-sm text-slate-500" ] [ text ("Signed in as " ++ user) ]
                            , button [ class "text-sky-700 hover:underline", onClick ClickedLogout ] [ text "Log out" ]
                            ]

                        Nothing ->
                            [ viewNavLink model Route.Login "Login" ]
                   )
            )
        ]


viewNavLink : Model -> Route -> String -> Html msg
viewNavLink model route label =
    a
        [ class
            (if isActive model.page route then
                "font-semibold text-sky-700"

             else
                "text-slate-600 hover:text-sky-700"
            )
        , Route.href route
        ]
        [ text label ]


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( About, Route.About ) ->
            True

        ( Login _, Route.Login ) ->
            True

        ( NewPost _, Route.NewPost ) ->
            True

        _ ->
            False
