module Menu.Dropdown exposing
    ( Dropdown
    , open, closed
    , view
    , trigger
    )

{-| Probably the simplest implementation of the dropdown.


# Types

@docs Dropdown


# Operations


## Creation

@docs open, closed


## View

@docs view


## Control

@docs trigger

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (keyCode, on, onBlur, onClick, onFocus, onMouseDown)
import Json.Decode as Decode


{-| Dropdown model
-}
type State
    = Open
    | Closed


type Dropdown
    = Dropdown State


{-| Create a closed dropdown
-}
closed : Dropdown
closed =
    Dropdown Closed


{-| Create an open dropdown
-}
open : Dropdown
open =
    Dropdown Open


toggle : Dropdown -> Dropdown
toggle (Dropdown drop) =
    case drop of
        Closed ->
            open

        Open ->
            closed


{-| View
-}
view : (Dropdown -> msg) -> Dropdown -> List (Attribute msg) -> List (Html msg) -> Html msg
view toMsg (Dropdown drop) attrs children =
    if drop == Open && not (List.isEmpty children) then
        div [ class "drop", style "position" "relative", style "display" "inline-block", onFocusOut <| toMsg closed, onFocusIn <| toMsg open ]
            [ div (style "position" "absolute" :: attrs) children ]

    else
        text ""


{-| This should be attached to the element that will control dropdown opening (button, input for search, ...)
-}
trigger : (Dropdown -> msg) -> Dropdown -> List (Attribute msg)
trigger toMsg drop =
    [ onMouseDown <| toMsg (toggle drop)
    , onFocus <| toMsg (toggle drop)
    , onBlur <| toMsg closed
    ]



-- Events


onFocusIn : msg -> Attribute msg
onFocusIn toMsg =
    on "focusin" (Decode.succeed toMsg)


onFocusOut : msg -> Attribute msg
onFocusOut toMsg =
    on "focusout" (Decode.succeed toMsg)
