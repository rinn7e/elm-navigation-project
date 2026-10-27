module Destination exposing (Destination(..), fromUrl, href, pushUrl, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string, top)



-- DESTINATIONS


type Destination
    = Home
    | Post String
    | About
    | Login
    | NewPost


parser : Parser (Destination -> a) a
parser =
    oneOf
        [ Parser.map Home top
        , Parser.map Post (s "post" </> string)
        , Parser.map About (s "about")
        , Parser.map Login (s "login")
        , Parser.map NewPost (s "new")
        ]



-- PUBLIC HELPERS


href : Destination -> Attribute msg
href targetDestination =
    Attr.href (destinationToString targetDestination)


pushUrl : Nav.Key -> Destination -> Cmd msg
pushUrl key destination =
    Nav.pushUrl key (destinationToString destination)


replaceUrl : Nav.Key -> Destination -> Cmd msg
replaceUrl key destination =
    Nav.replaceUrl key (destinationToString destination)


fromUrl : Url -> Maybe Destination
fromUrl url =
    Parser.parse parser url



-- INTERNAL


destinationToString : Destination -> String
destinationToString destination =
    "/" ++ String.join "/" (destinationToPieces destination)


destinationToPieces : Destination -> List String
destinationToPieces destination =
    case destination of
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
