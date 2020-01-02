module Menu.FocusList exposing
    ( FocusList, Item(..), Msg
    , update, view
    , trigger, onSelect, onKeyDown
    )

{-| Manage focus on the list of sibilings.


# Types

@docs FocusList, Item, Msg


# TEA

@docs update, view


# Events

@docs trigger, onSelect, onKeyDown

-}

import Browser.Dom
import Html exposing (Attribute, Html, a, button, div, text)
import Html.Attributes exposing (class, href, id, style, tabindex, type_, value)
import Html.Events exposing (keyCode, on, onClick, onFocus, preventDefaultOn)
import Json.Decode as D exposing (Decoder)
import Task exposing (Task)


{-| Internal module messages.
-}
type Msg
    = SetFocus (Maybe String)
    | SelectFirst


{-| List item types. Html link or button.
-}
type Item msg
    = Anchor ( String, List (Attribute msg), List (Html msg) )
    | Button ( String, List (Attribute msg), List (Html msg) )


{-| The only value needed to be stored is the unique identifier used to set focus.
-}
type alias FocusList =
    String


makeId : String -> Int -> String
makeId name i =
    name ++ "-" ++ String.fromInt i


itemToLink : String -> Int -> Item msg -> Html msg
itemToLink name i item =
    case item of
        Anchor ( url, attrs, children ) ->
            Html.a ([ id (makeId name i), tabindex -1, href url, style "display" "block" ] ++ attrs) children

        Button ( url, attrs, children ) ->
            button ([ id (makeId name i), tabindex -1, type_ "button", value url, style "width" "100%" ] ++ attrs) children


{-| Renders the list.
-}
view : FocusList -> List (Item msg) -> List (Html msg)
view name children =
    List.indexedMap (itemToLink name) children


selectionDecoder : String -> Decoder String
selectionDecoder prefix =
    D.field "id" D.string
        |> D.andThen
            (\id ->
                if String.startsWith prefix id then
                    D.oneOf [ D.field "value" D.string, D.field "href" D.string ]

                else
                    D.field "parentNode" (selectionDecoder prefix)
            )


{-| Catches the selection.
-}
onSelect : (String -> msg) -> FocusList -> Attribute msg
onSelect toMsg name =
    on "click" (D.field "target" (selectionDecoder <| name ++ "-") |> D.map toMsg)


{-| Standard update function.
-}
update : Msg -> FocusList -> Cmd Msg
update msg name =
    case msg of
        SetFocus (Just target) ->
            Task.attempt (\_ -> SetFocus Nothing) (Browser.Dom.focus target)

        SetFocus Nothing ->
            Cmd.none

        SelectFirst ->
            Task.attempt (\_ -> SetFocus Nothing) (Browser.Dom.focus <| makeId name 0)



-- Key managment


type Key
    = UpArrow
    | DownArrow
    | Escape


toKey : Int -> Decoder Key
toKey key =
    case key of
        38 ->
            D.succeed UpArrow

        40 ->
            D.succeed DownArrow

        27 ->
            D.succeed Escape

        _ ->
            D.fail "not interested in"


{-| Html.Attribute that causes the selection of the first elment in the list.
-}
trigger : (Msg -> msg) -> Attribute msg
trigger toMsg =
    preventOnArrows (isKey DownArrow (toMsg SelectFirst))


{-| Html.Attribute to handle navigation keys.

    div [ onKeyDown FocusListMsg ]
        [ FocusList.view list children
        ]

-}
onKeyDown : String -> (Msg -> msg) -> Attribute msg
onKeyDown name toMsg =
    preventOnArrows (nextFocusDecoder name >> D.map (SetFocus >> toMsg))


preventOnArrows : (Key -> Decoder msg) -> Attribute msg
preventOnArrows decoder =
    D.andThen toKey keyCode
        |> D.andThen
            (\key -> decoder key |> D.map (\msg -> ( msg, key == DownArrow || key == UpArrow )))
        |> preventDefaultOn "keydown"


isKey : Key -> msg -> Key -> Decoder msg
isKey pattern tagger key =
    if pattern == key then
        D.succeed tagger

    else
        D.fail "not my key"


nextFocusDecoder : String -> Key -> Decoder (Maybe String)
nextFocusDecoder name key =
    case key of
        DownArrow ->
            D.at [ "target", "nextSibling", "id" ] (D.nullable D.string)

        UpArrow ->
            D.at [ "target", "previousSibling", "id" ] (D.nullable D.string)

        Escape ->
            D.succeed (Just name)
