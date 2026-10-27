module Screen.Home exposing (view)

import BlogPost exposing (BlogPost)
import Destination
import Html exposing (Html, a, article, div, h1, h2, p, text)
import Html.Attributes exposing (class)


view : List BlogPost -> { title : String, content : Html msg }
view posts =
    { title = "Posts"
    , content =
        div []
            [ h1 [ class "mb-6 text-3xl font-bold" ] [ text "Posts" ]
            , div [ class "space-y-4" ] (List.map viewPreview posts)
            ]
    }


viewPreview : BlogPost -> Html msg
viewPreview post =
    article [ class "rounded-lg border border-slate-200 p-4 hover:border-slate-400" ]
        [ a [ Destination.href (Destination.Post post.slug) ]
            [ h2 [ class "text-xl font-semibold text-sky-700" ] [ text post.title ]
            , p [ class "text-sm text-slate-500" ] [ text post.date ]
            , p [ class "mt-2 text-slate-700" ]
                [ text (List.head post.body |> Maybe.withDefault "") ]
            ]
        ]
