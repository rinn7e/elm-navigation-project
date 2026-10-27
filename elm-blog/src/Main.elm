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
        , update = update
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
    changeRouteTo (Route.fromUrl url)
        { key = key
        , user = user
        , posts = BlogPost.all
        , page = NotFound
        }



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
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLogout, _ ) ->
            ( { model | user = Nothing }
            , Cmd.batch [ storeUser Nothing, Route.replaceUrl model.key Route.Home ]
            )

        ( GotLoginMsg subMsg, Login login ) ->
            case Login.update subMsg login of
                ( _, Just user ) ->
                    ( { model | user = Just user }
                    , Cmd.batch [ storeUser (Just user), Route.replaceUrl model.key Route.Home ]
                    )

                ( newLogin, Nothing ) ->
                    ( { model | page = Login newLogin }, Cmd.none )

        ( GotNewPostMsg subMsg, NewPost newPost ) ->
            case NewPost.update subMsg newPost of
                ( _, Just post ) ->
                    ( { model | posts = post :: model.posts }
                    , Route.pushUrl model.key (Route.Post post.slug)
                    )

                ( newNewPost, Nothing ) ->
                    ( { model | page = NewPost newNewPost }, Cmd.none )

        ( _, _ ) ->
            -- A message for a page that is not shown anymore
            ( model, Cmd.none )


{-| Opens the page of the route, the guard first: signed out the new post page
redirects to the login page, signed in the login page redirects home.
-}
changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just (Route.Post slug) ->
            ( { model | page = Post slug }, Cmd.none )

        Just Route.About ->
            ( { model | page = About }, Cmd.none )

        Just Route.Login ->
            if model.user /= Nothing then
                redirectTo Route.Home model

            else
                ( { model | page = Login Login.init }, Cmd.none )

        Just Route.NewPost ->
            if model.user == Nothing then
                redirectTo Route.Login model

            else
                ( { model | page = NewPost NewPost.init }, Cmd.none )


{-| Opens the page of the route and replaces the URL with it. The page is opened
here too: the `UrlChanged` of a `replaceUrl` run from `init` never arrives.
-}
redirectTo : Route -> Model -> ( Model, Cmd Msg )
redirectTo route model =
    let
        ( newModel, cmd ) =
            changeRouteTo (Just route) model
    in
    ( newModel, Cmd.batch [ cmd, Route.replaceUrl model.key route ] )



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
