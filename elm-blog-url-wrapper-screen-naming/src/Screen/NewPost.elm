module Screen.NewPost exposing (Model, Msg, init, update, view)

import BlogPost exposing (BlogPost)
import Html exposing (Html, button, div, form, h1, input, label, p, text, textarea)
import Html.Attributes exposing (class, rows, value)
import Html.Events exposing (onInput, onSubmit)



-- MODEL


type alias Model =
    { title : String
    , body : String
    , error : Maybe String
    }


init : Model
init =
    { title = "", body = "", error = Nothing }



-- UPDATE


type Msg
    = EnteredTitle String
    | EnteredBody String
    | SubmittedForm


{-| The second value is the post once the form publishes it.
-}
update : Msg -> Model -> ( Model, Maybe BlogPost )
update msg model =
    case msg of
        EnteredTitle title ->
            ( { model | title = title }, Nothing )

        EnteredBody body ->
            ( { model | body = body }, Nothing )

        SubmittedForm ->
            if String.isEmpty (BlogPost.slugify model.title) then
                ( { model | error = Just "The post needs a title." }, Nothing )

            else
                ( model
                , Just
                    { slug = BlogPost.slugify model.title
                    , title = model.title
                    , date = "just now"
                    , body =
                        String.split "\n\n" model.body
                            |> List.map String.trim
                            |> List.filter (not << String.isEmpty)
                    }
                )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "New post"
    , content =
        form [ class "space-y-4", onSubmit SubmittedForm ]
            [ h1 [ class "text-3xl font-bold" ] [ text "New post" ]
            , p [ class "text-sm text-slate-500" ]
                [ text "Only signed-in users can open this page. The post is kept in memory until the page reloads." ]
            , label [ class "block" ]
                [ div [ class "mb-1 text-sm font-medium" ] [ text "Title" ]
                , input [ class "w-full rounded border border-slate-300 px-3 py-2", value model.title, onInput EnteredTitle ] []
                ]
            , label [ class "block" ]
                [ div [ class "mb-1 text-sm font-medium" ] [ text "Body (an empty line between paragraphs)" ]
                , textarea [ class "w-full rounded border border-slate-300 px-3 py-2", rows 8, value model.body, onInput EnteredBody ] []
                ]
            , case model.error of
                Just error ->
                    p [ class "text-red-600" ] [ text error ]

                Nothing ->
                    text ""
            , button [ class "rounded bg-sky-700 px-4 py-2 text-white hover:bg-sky-800" ] [ text "Publish" ]
            ]
    }
