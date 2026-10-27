module Screen.Post exposing (view)

import BlogPost exposing (BlogPost)
import Destination
import Html exposing (Html, a, article, h1, p, text)
import Html.Attributes exposing (class)


view : String -> List BlogPost -> { title : String, content : Html msg }
view slug posts =
    case BlogPost.find slug posts of
        Just post ->
            { title = post.title
            , content =
                article []
                    [ h1 [ class "text-3xl font-bold" ] [ text post.title ]
                    , p [ class "mb-6 text-sm text-slate-500" ] [ text post.date ]
                    , Html.div [ class "space-y-4 text-lg text-slate-800" ]
                        (List.map (\paragraph -> p [] [ text paragraph ]) post.body)
                    , a [ class "mt-8 inline-block text-sky-700 hover:underline", Destination.href Destination.Home ]
                        [ text "Back to all posts" ]
                    ]
            }

        Nothing ->
            { title = "Post not found"
            , content = p [] [ text ("There is no post named " ++ slug ++ ".") ]
            }
