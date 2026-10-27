module Screen.About exposing (view)

import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (class)


view : { title : String, content : Html msg }
view =
    { title = "About"
    , content =
        div [ class "space-y-4 text-lg text-slate-800" ]
            [ h1 [ class "text-3xl font-bold" ] [ text "About" ]
            , p [] [ text "A small blog written in Elm, to compare two ways of handling navigation." ]
            , p [] [ text "The posts are hard-coded, there is no server. Sign in with the test account to write a new post." ]
            ]
    }
