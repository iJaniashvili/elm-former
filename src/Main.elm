module Main exposing (..)

import Html exposing (Html, div, text, pre, input, textarea)
import Dict exposing (Dict)
import Types exposing (Widget(..), Entry)
import Decoders exposing (decodeDeclaration)
import Encoders exposing (encodeJson)
import Views exposing (jsonView)
import Widget.Input
import Widget.Textarea
import Widget.Checkbox


-- MODEL


type alias Model =
    Dict String Widget


json : String
json =
    """
[
    {
        "widget": "input",
        "key": "username",
        "placeholder": "Username"
    },
    {
        "widget": "input",
        "key": "password",
        "placeholder": "Password"
    },
    {
        "widget": "textarea",
        "key": "about",
        "placeholder": "About me"
    },
    {
        "widget": "checkbox",
        "key": "agreed",
        "placeholder": "I agree"
    }
]
    """


init : ( Model, Cmd Msg )
init =
    Dict.empty ! []



-- UPDATE


type Msg
    = Update String Widget


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update key value ->
            Dict.update key (always <| Just value) model
                ! []



-- VIEW


widget : Entry -> Html Msg
widget entry =
    case entry.widget of
        Input data ->
            let
                update value =
                    Update entry.key (Input value)
            in
                Widget.Input.view update entry

        Textarea data ->
            let
                update value =
                    Update entry.key (Textarea value)
            in
                Widget.Textarea.view update entry

        Checkbox data ->
            let
                update value =
                    Update entry.key (Checkbox value)
            in
                Widget.Checkbox.view update entry


widgets : Result String (List Entry) -> Html Msg
widgets declaration =
    div [] <|
        case declaration of
            Ok d ->
                List.map widget d

            Err e ->
                [ text <| "Error parsing json: " ++ e ]


view : Model -> Html Msg
view model =
    let
        declaration =
            decodeDeclaration json

        encodedJson =
            encodeJson model
    in
        div []
            [ widgets <| declaration
            , jsonView "Output JSON" <| encodedJson
            , jsonView "Schema JSON" <| json
            ]



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
