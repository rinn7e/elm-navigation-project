module Route exposing (Route(..), fromUrl, href, pushUrl, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string, top)



-- ROUTING


type Route
    = Home
    | Post String
    | About
    | Login
    | NewPost


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Post (s "post" </> string)
        , Parser.map About (s "about")
        , Parser.map Login (s "login")
        , Parser.map NewPost (s "new")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (routeToString route)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString route =
    "/" ++ String.join "/" (routeToPieces route)


routeToPieces : Route -> List String
routeToPieces route =
    case route of
        Home ->
            []

        Post slug ->
            [ "post", slug ]

        About ->
            [ "about" ]

        Login ->
            [ "login" ]

        NewPost ->
            [ "new" ]
