module Page.Login exposing (Model, Msg, init, update, view)

import Html exposing (Html, button, div, form, h1, input, label, p, text)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onInput, onSubmit)



-- The only account of the app


testAccount : { username : String, password : String }
testAccount =
    { username = "test", password = "testtest" }



-- MODEL


type alias Model =
    { username : String
    , password : String
    , error : Maybe String
    }


init : Model
init =
    { username = "", password = "", error = Nothing }



-- UPDATE


type Msg
    = EnteredUsername String
    | EnteredPassword String
    | SubmittedForm


{-| The second value is the username once the form signs in.
-}
update : Msg -> Model -> ( Model, Maybe String )
update msg model =
    case msg of
        EnteredUsername username ->
            ( { model | username = username }, Nothing )

        EnteredPassword password ->
            ( { model | password = password }, Nothing )

        SubmittedForm ->
            if model.username == testAccount.username && model.password == testAccount.password then
                ( model, Just model.username )

            else
                ( { model | error = Just "Wrong username or password." }, Nothing )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content =
        form [ class "max-w-sm space-y-4", onSubmit SubmittedForm ]
            [ h1 [ class "text-3xl font-bold" ] [ text "Login" ]
            , p [ class "text-sm text-slate-500" ]
                [ text ("Test account: " ++ testAccount.username ++ " / " ++ testAccount.password) ]
            , viewField "Username" "text" model.username EnteredUsername
            , viewField "Password" "password" model.password EnteredPassword
            , case model.error of
                Just error ->
                    p [ class "text-red-600" ] [ text error ]

                Nothing ->
                    text ""
            , button [ class "rounded bg-sky-700 px-4 py-2 text-white hover:bg-sky-800" ] [ text "Sign in" ]
            ]
    }


viewField : String -> String -> String -> (String -> Msg) -> Html Msg
viewField name kind fieldValue toMsg =
    label [ class "block" ]
        [ div [ class "mb-1 text-sm font-medium" ] [ text name ]
        , input
            [ class "w-full rounded border border-slate-300 px-3 py-2"
            , type_ kind
            , value fieldValue
            , onInput toMsg
            ]
            []
        ]
